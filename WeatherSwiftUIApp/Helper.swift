//
//  Helper.swift
//  WeatherApp
//
//  Created by Azharuddin 1 on 22/05/23.
//

import Foundation
class Helper{
    static   func convertDataToJsonString(data: Data) -> String? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Failed to convert data to JSON string: \(error)")
        }
        
        return nil
    }
}
