//
//  File.swift
//  PolyPrep
//
//  Created by Дмитрий Григорьев on 10.05.2025.
//

import Foundation
import UIKit

func HandleNetwork(_ request: URLRequest) -> Data?
{
    var tmp_data: Data?
    URLSession.shared.dataTask(with: request){ data, response, error in
        print("Network request: ", request.url?.absoluteString ?? "")
        guard let httpResponse = response as? HTTPURLResponse else {
            print( NSError(domain: "Invalid response", code: 0))
            return
        }
        print("Status code:", httpResponse.statusCode)
        print("Response:", String(data: data ?? Data(), encoding: .utf8) ?? "")
        if (httpResponse.statusCode != 200)
        {
            showAlert(title: "Error " + String(httpResponse.statusCode), message: String(data: data ?? Data(), encoding: .utf8) ?? "")
        }
        tmp_data = data
    }.resume()
    while tmp_data == nil {}
    return tmp_data
}

func HandleNetwork(_ url: URL) -> Data?
{
    var tmp_data: Data?
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        print("Network request: ", url.absoluteString)
        guard let httpResponse = response as? HTTPURLResponse else {
            print( NSError(domain: "Invalid response", code: 0))
            return
        }
        print("Status code:", httpResponse.statusCode)
        print("Response:", String(data: data ?? Data(), encoding: .utf8) ?? "")
        if (httpResponse.statusCode != 200)
        {
            showAlert(title: "Error", message: String(data: data ?? Data(), encoding: .utf8) ?? "")
        }
        tmp_data = data
    }.resume()
    
    while tmp_data == nil {}
    return tmp_data
}

func showAlert(title: String, message: String) {
    // Создаем контроллер
    let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert
    )
    
    // Добавляем кнопку
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    
    // Показываем alert
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
        return
    }
    
    rootViewController.present(alert, animated: true)
}
