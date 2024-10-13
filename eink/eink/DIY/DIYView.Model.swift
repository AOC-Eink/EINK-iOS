//
//  DIYView.Model.swift
//  eink
//
//  Created by Aaron on 2024/9/21.
//

import Foundation

extension DIYView {
    
    @Observable
    class Model {
        
        let device:Device
        var colors:[String]
        let diyName:String
        let initFavorite:Bool
        
        init(_ device: Device, name:String = "", colors:[String] = [], favorite:Bool = false) {
            self.device = device
            self.diyName = name
            self.colors = colors == [] ? Array(repeating: "DBDBDB", count: device.inkCounts) : colors
            self.initFavorite = favorite
        }
        
        let panelColors = [("green", "497A64"),
                           ("yellow", "DFBE24"),
                           ("blue", "2B78B9"),
                           ("black", "3F384A"),
                           ("red", "A45942"),
                           ("off", "DBDBDB")
        ]
        
        var hGirds:Int {
            device.deviceType.shape[0]
        }
        var vGirds:Int {
            device.deviceType.shape[1]
        }
        
        var itemWidth:CGFloat {
            device.inkStyle.itemWidth
        }
        
        var hexString:String {
            colors.joined(separator: ",")
        }
        
        
        
        func clearDesgin() {
            colors = Array(repeating: "DBDBDB", count: device.inkCounts)
        }
        
        func saveDesgin(_ name:String, _ isFavorite:Bool) {
            debugPrint("\(name)\":\"\(hexString)")
            let design = Design(deviceId: device.indentify,
                               vGrids: vGirds,
                               hGrids: hGirds,
                               name: name,
                               colors: hexString,
                               favorite: isFavorite,
                               category: "custom")
            
            CoreDataStack.shared.insetOrUpdateDesign(
                name: name,
                item: design
            )
            
            if isFavorite {
                CoreDataStack.shared.insetFavoriteDesign(item: design)
            } else {
                try? CoreDataStack.shared.deleteDesignWithNameAndId(name: name, deviceId: device.indentify)
            }
        }
        
        
        
        
        
        var randonName:String {
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" // 包含大小写字母
                return String((0..<8).map { _ in letters.randomElement()! })
        }
        
        func applay() async {
            //showToast.toggle()
            
            await device.deviceFuction?.sendColors(device, colors: colors)
        }
        
        
    }
}
