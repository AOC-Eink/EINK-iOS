//
//  StringExtension.swift
//  eink
//
//  Created by Aaron on 2024/9/15.
//

import Foundation

extension String {
    func toModel<T: Codable>() -> T? {
        guard let data = self.data(using: .utf8) else {
            print("Failed to convert string to data")
            return nil
        }
        let decoder = JSONDecoder()
        do {
            let model = try decoder.decode(T.self, from: data)
            return model
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
    }
}

extension Encodable {
    func toJSONString(encoding: String.Encoding = .utf8) -> String? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: encoding) {
                return jsonString
            }
        } catch {
            print("Failed to encode model to JSON: \(error)")
        }
        return nil
    }
}
