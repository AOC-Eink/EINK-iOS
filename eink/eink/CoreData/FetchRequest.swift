//
//  FetchRequest.swift
//  eink
//
//  Created by Aaron on 2024/9/17.
//

import Foundation
import CoreData

extension InkDevice {
    static let deviceRequest: NSFetchRequest<InkDevice> = {
        let request = NSFetchRequest<InkDevice>(entityName: "InkDevice")
        //request.relationshipKeyPathsForPrefetching = []
        request.sortDescriptors = [.init(key: "createTimestamp", ascending: false)]
        request.returnsObjectsAsFaults = false
        return request
    }()

    static let disableRequest: NSFetchRequest<InkDevice> = {
        let request = NSFetchRequest<InkDevice>(entityName: "InkDevice")
        request.sortDescriptors = [.init(key: "createTimestamp", ascending: false)]
        request.predicate = .init(value: false)
        return request
    }()
}

extension FavoriteDesign {
    static func designRequest(forDeviceId deviceId: String) -> NSFetchRequest<FavoriteDesign> {
        let request = NSFetchRequest<FavoriteDesign>(entityName: "FavoriteDesign")
        
        // 设置排序规则
        request.sortDescriptors = [.init(key: "createTimestamp", ascending: false)]
        
        // 设置过滤条件 (根据 deviceId)
        request.predicate = NSPredicate(format: "deviceId == %@", deviceId)
        
        // 设置返回对象不作为 faults
        request.returnsObjectsAsFaults = false
        
        return request
    }

    static let disableRequest: NSFetchRequest<FavoriteDesign> = {
        let request = NSFetchRequest<FavoriteDesign>(entityName: "FavoriteDesign")
        request.sortDescriptors = [.init(key: "createTimestamp", ascending: false)]
        request.predicate = .init(value: false)
        return request
    }()
}

extension InkDesign {
    static func designRequest(forDeviceId deviceId: String) -> NSFetchRequest<InkDesign> {
        let request = NSFetchRequest<InkDesign>(entityName: "InkDesign")
        
        // 设置排序规则
        request.sortDescriptors = [.init(key: "createTimestamp", ascending: false)]
        
        // 设置过滤条件 (根据 deviceId)
        request.predicate = NSPredicate(format: "deviceId == %@", deviceId)
        
        // 设置返回对象不作为 faults
        request.returnsObjectsAsFaults = false
        
        return request
    }

    static let disableRequest: NSFetchRequest<InkDesign> = {
        let request = NSFetchRequest<InkDesign>(entityName: "InkDesign")
        request.sortDescriptors = [.init(key: "createTimestamp", ascending: false)]
        request.predicate = .init(value: false)
        return request
    }()
}
