import CoreNFC
import BLECommunicator


@Observable
class NFCCommunicator: NSObject, NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        
    }
    
    private var session: NFCTagReaderSession?
    private var completionHandler: ((Result<String, Error>) -> Void)?
    
    static let shared = NFCCommunicator()
    
    enum NFCError: Error {
        case unsupportedTag
        case readError
        case writeError
        case invalidResponse
    }
    
    func beginSession() {
        // 支持三种类型
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        session?.alertMessage = "请将iPhone靠近NFC标签"
        session?.begin()
    }
    
    func stopSession(message: String? = nil) {
        session?.alertMessage = message ?? "会话已结束"
        session?.invalidate()
        session = nil
    }
    
    func updateSessionAlertMessage(_ message: String) {
        session?.alertMessage = message
    }
    
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let firstTag = tags.first else {
            session.invalidate(errorMessage: "未检测到标签")
            return
        }

        // 只允许单标签
        if tags.count > 1 {
            session.alertMessage = "检测到多个标签，请只保留一个"
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                session.restartPolling()
            }
            return
        }

        switch firstTag {
        case .miFare(let miFareTag):
            session.connect(to: firstTag) { error in
                if let error = error {
                    session.invalidate(errorMessage: "连接Mifare失败: \(error.localizedDescription)")
                    return
                }
                // 这里可以操作miFareTag
                // 例如读取NDEF或自定义命令
                session.alertMessage = "连接标签成功，正在读取数据..."
                
                self.readTag(tag: miFareTag, session: session)
                
            }
        default:
            session.invalidate(errorMessage: "未知标签类型")
        }
    }
    
    private func readTag(tag: NFCMiFareTag, session: NFCTagReaderSession) {
        let ndefTag = tag as NFCNDEFTag
        ndefTag.queryNDEFStatus { status, capacity, error in
            if status == .notSupported {
                session.invalidate(errorMessage: "该标签不支持NDEF")
                return
            }
            ndefTag.readNDEF { message, error in
                if let message = message {
                    // 处理NDEF消息
                    for record in message.records {
                        let payloadData = record.payload
                        Logger.shared.log("NDEF类型: \(record.typeNameFormat)")
                        Logger.shared.log("NDEF类型: \(record.type)")
                        Logger.shared.log("NDEF标识符: \(record.identifier)")
                        Logger.shared.log("NDEF负载: \(payloadData.base64EncodedString())")
              
                        guard let statusByte = payloadData.first else {
                            // 处理错误
                            return
                        }
                        let langCodeLen = Int(statusByte & 0x3F)
                        let textData = payloadData.dropFirst(1 + langCodeLen)
                        let text = String(data: textData, encoding: .utf8) ?? ""
                        Logger.shared.log("NDEF内容: \(text)")
                        //假设 text = "38360A01C15B,54,64,3,BWRYGB, 1,0,0,0" 获取 38360A01C15B
                        let components = text.components(separatedBy: ",")
                        if let firstPart = components.first?.trimmingCharacters(in: .whitespaces) {
                            session.alertMessage = "读取成功: \(firstPart) 准备连接蓝牙"
                            self.completionHandler?(.success(firstPart))
                        } else {
                            session.invalidate(errorMessage: "无法解析NDEF内容")
                            self.completionHandler?(.failure(NFCError.invalidResponse))
                        }
                        
                    }
                    //session.invalidate()
                } else {
                    session.invalidate(errorMessage: "读取NDEF失败")
                    self.completionHandler?(.failure(NFCError.invalidResponse))
                }
            }
        }
        
    }
    
    


//    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
//        // 会话失效时的处理
//        self.session = nil
//    }
    

    func startSession(completion: @escaping (Result<String, Error>) -> Void) {
        guard NFCTagReaderSession.readingAvailable else {
            completion(.failure(NFCError.unsupportedTag))
            return
        }
        self.completionHandler = completion
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        session?.alertMessage = "请将iPhone靠近NFC标签"
        session?.begin()
    }

//    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
//        guard let tag = tags.first else {
//            session.invalidate(errorMessage: "未检测到NFC标签")
//            return
//        }
//        session.alertMessage = "正在连接到NFC标签..."
//        session.connect(to: tag) { error in
//            if let error = error {
//                session.invalidate(errorMessage: "连接错误: \(error.localizedDescription)")
//                return
//            }
//            session.alertMessage = "连接成功，正在读取数据..."
//            self.readType2Tag(tag: tag, session: session)
//        }
//    }

    private func readType2Tag(tag: NFCTag, session: NFCTagReaderSession) {
        guard case .miFare(let miFareTag) = tag else {
            session.invalidate(errorMessage: "Unsupported tag type")
            return
        }
        // Read pages 0 to 5 (24 bytes, adjust as needed)
        let pagesToRead = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05]
        var resultData = Data()
        let group = DispatchGroup()
        var readError: Error?

        for page in pagesToRead {
            group.enter()
            let command: [UInt8] = [0x30, UInt8(page)]
            miFareTag.sendMiFareCommand(commandPacket: Data(command)) { data, error in
                if let error = error {
                    readError = error
                } else {
                    resultData.append(data.prefix(4))
                }
                group.leave()
            }
            if readError != nil { break }
        }

        group.notify(queue: .main) {
            if let error = readError {
                self.completionHandler?(.failure(error))
                session.invalidate(errorMessage: "Read error: \(error.localizedDescription)")
                return
            }
            // Convert to ASCII string, trim trailing zeros
            if let infoString = String(data: resultData, encoding: .ascii)?.trimmingCharacters(in: .controlCharacters.union(.whitespacesAndNewlines)) {
                self.completionHandler?(.success(infoString))
                session.alertMessage = "Read success"
                session.invalidate()
            } else {
                self.completionHandler?(.failure(NFCError.invalidResponse))
                session.invalidate(errorMessage: "Invalid response data")
            }
        }
    }
    
    
//    private func readTag(tag: NFCTag, session: NFCTagReaderSession) {
//        guard case .miFare(let miFareTag) = tag else {
//            session.invalidate(errorMessage: "Unsupported tag type")
//            return
//        }
//        miFareTag.asNFCNDEFTag { ndefTag in
//            ndefTag.queryNDEFStatus { status, capacity, error in
//                if let error = error {
//                    self.completionHandler?(.failure(error))
//                    session.invalidate(errorMessage: "NDEF status error: \(error.localizedDescription)")
//                    return
//                }
//                guard status == .readOnly || status == .readWrite else {
//                    self.completionHandler?(.failure(NFCError.readError))
//                    session.invalidate(errorMessage: "Tag is not NDEF formatted")
//                    return
//                }
//                ndefTag.readNDEF { message, error in
//                    if let error = error {
//                        self.completionHandler?(.failure(error))
//                        session.invalidate(errorMessage: "Read NDEF error: \(error.localizedDescription)")
//                        return
//                    }
//                    guard let record = message?.records.first else {
//                        self.completionHandler?(.failure(NFCError.invalidResponse))
//                        session.invalidate(errorMessage: "No NDEF records found")
//                        return
//                    }
//                    // Skip NDEF text header (language code length)
//                    let payload = record.payload
//                    let text: String
//                    if record.typeNameFormat == .nfcWellKnown, record.type == Data([0x54]) {
//                        // Text record, skip status byte and language code
//                        let langCodeLen = Int(payload.first ?? 0)
//                        text = String(data: payload.dropFirst(1 + langCodeLen), encoding: .utf8) ?? ""
//                    } else {
//                        text = String(data: payload, encoding: .utf8) ?? ""
//                    }
//                    self.completionHandler?(.success(text))
//                    session.alertMessage = "Read success"
//                    session.invalidate()
//                }
//            }
//        }
//    }


    
    private func readMacAddress(tag: NFCTag, session: NFCTagReaderSession) {
        
        guard case .iso7816(let iso7816Tag) = tag else {
            session.invalidate(errorMessage: "不支持的标签类型")
            return
        }
        
        // 假设读取MAC地址的命令是 0x00, 0xB0, 0x00, 0x00, 0x06
        let apdu = NFCISO7816APDU(instructionClass: 0x00, instructionCode: 0xB0, p1Parameter: 0x00, p2Parameter: 0x00, data: Data(), expectedResponseLength: 6)
        
        iso7816Tag.sendCommand(apdu: apdu) { data, sw1, sw2, error in
            if let error = error {
                self.completionHandler?(.failure(error))
                session.invalidate(errorMessage: "读取错误: \(error.localizedDescription)")
                return
            }
            
            
            guard data.count == 6 else {
                self.completionHandler?(.failure(NFCError.invalidResponse))
                session.invalidate(errorMessage: "无效的响应数据")
                return
            }
            
            let macAddress = data.map { String(format: "%02X", $0) }.joined()
            print("读取到的MAC地址: \(macAddress)")
            self.completionHandler?(.success(macAddress))
            //self.sendCustomCommand(tag: iso7816Tag, session: session, macAddress: macAddress)
        }
    }
    
    private func sendCustomCommand(tag: NFCISO7816Tag, session: NFCTagReaderSession, macAddress: String) {
        let command: [UInt8] = [0x58, 0x54, 0x45, 0x01, 0x08, 0x13, 0x13, 0x00]
        guard let apdu = NFCISO7816APDU(data: Data(command)) else {
            self.completionHandler?(.failure(NSError(domain: "404", code: 4, userInfo: [NSLocalizedDescriptionKey:"操作失败，请重试"])))
            return
        }
        
        tag.sendCommand(apdu: apdu) { data, sw1, sw2, error in
            if let error = error {
                self.completionHandler?(.failure(error))
                session.invalidate(errorMessage: "发送命令错误: \(error.localizedDescription)")
                return
            }
            
            if sw1 == 0x90 && sw2 == 0x00 {
                print("自定义命令发送成功")
                self.completionHandler?(.success(macAddress))
                session.alertMessage = "操作成功完成"
                session.invalidate()
            } else {
                self.completionHandler?(.failure(NFCError.writeError))
                session.invalidate(errorMessage: "命令执行失败: SW1=\(sw1), SW2=\(sw2)")
            }
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        if let completionHandler = completionHandler {
            completionHandler(.failure(error))
        }
        self.completionHandler = nil
    }
}
