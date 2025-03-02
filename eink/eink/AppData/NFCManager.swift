import CoreNFC

class NFCCommunicator: NSObject, NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        
    }
    
    private var session: NFCTagReaderSession?
    private var completionHandler: ((Result<String, Error>) -> Void)?
    
    enum NFCError: Error {
        case unsupportedTag
        case readError
        case writeError
        case invalidResponse
    }
    
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
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "未检测到NFC标签")
            return
        }
        
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "连接错误: \(error.localizedDescription)")
                return
            }
            
            self.readMacAddress(tag: tag, session: session)
        }
    }
    
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
            
            self.sendCustomCommand(tag: iso7816Tag, session: session, macAddress: macAddress)
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
