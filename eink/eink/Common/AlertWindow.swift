//
//  AlertWindow.swift
//  eink
//
//  Created by Aaron on 2024/10/14.
//

import Foundation
import UIKit

final class AlertWindow: UIAlertController {

    // MARK: - static

    // アラート表示（キャンセルのみ）
    static func show(title: String,
                     message: String,
                     cancelButtonTitle: String = "閉じる",
                     onTap: (() -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            let alertController = AlertWindow(title: title,
                                              message: message,
                                              preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { _ in
                onTap?()
            })
            alertController.addAction(cancelAction)
            alertController.presentAsWindow(animated: true, completion: nil)
        }
    }

    // アラート表示（キャンセル・OKボタン）
    static func showOKAndCancel(title: String,
                                message: String,
                                okButtonTitle: String = "OK",
                                cancelButtonTitle: String = "Cancel",
                                onTapOk: (() -> Void)? = nil,
                                onTapCancel: (() -> Void)? = nil
    ) {
        DispatchQueue.main.async {
            let alertController = AlertWindow(title: title,
                                              message: message,
                                              preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: { _ in
                onTapCancel?()
            })
            alertController.addAction(cancelAction)
            
            let okAction = UIAlertAction(title: okButtonTitle, style: .default, handler: { _ in
                onTapOk?()
            })
            alertController.addAction(okAction)
            
            alertController.presentAsWindow(animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - fileprivate
    
    // 表示もとのwindow
    fileprivate var baseWindow: UIWindow?
    
    fileprivate func presentAsWindow(animated: Bool, completion: (() -> Void)?) {
        baseWindow = UIWindow(frame: UIScreen.main.bounds)
        if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            baseWindow?.windowScene = currentWindowScene
        }
        baseWindow?.rootViewController = UIViewController()
        baseWindow?.backgroundColor = .clear
        DispatchQueue.main.async {
            self.baseWindow?.makeKeyAndVisible()
            self.baseWindow?.rootViewController?.present(self, animated: animated, completion: completion)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Window自体をnil
        baseWindow?.isHidden = true
        baseWindow = nil
    }

}

