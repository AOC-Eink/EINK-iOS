//
//  Persistence.swift
//  eink
//
//  Created by Aaron on 2024/9/3.
//

import CoreData

struct CoreDataStack {
    static let shared = CoreDataStack()

    static var preview: CoreDataStack = {
        let result = CoreDataStack(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = InkDevice(context: viewContext)
            newItem.createTimestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "eink")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}


extension CoreDataStack {
    
    func insetOrUpdateDesign(name:String = "", item: Design? = nil) {
        container.performBackgroundTask { context in
            let request = NSFetchRequest<InkDesign>(entityName: "InkDesign")
            let namePredicate = NSPredicate(format: "name = %@", name)
            let deviceIdPredicate = NSPredicate(format: "deviceId = %@", item?.deviceId ?? "")
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, deviceIdPredicate])
            request.fetchLimit = 1
            request.predicate = compoundPredicate
            request.sortDescriptors = [NSSortDescriptor(key: "createTimestamp", ascending: true)]
            let result = try? context.fetch(request).first
            if let hasDesign = result {
                guard let newDesign = item else {
                    return
                }
                hasDesign.name = newDesign.name
                hasDesign.colors = newDesign.colors
                hasDesign.favorite = newDesign.favorite
                try? context.save()
            } else {
                guard let newDesign = item else {
                    return
                }
                
                let desgin = InkDesign(context: context)
                desgin.name = newDesign.name
                desgin.deviceId = newDesign.deviceId
                desgin.colors = newDesign.colors
                desgin.hGrids = Int64(newDesign.hGrids)
                desgin.vGrids = Int64(newDesign.vGrids)
                desgin.favorite = newDesign.favorite
                try? context.save()
            }
        }
    }
    
    func insetFavoriteDesign(item: Design) {
        container.performBackgroundTask { context in
            let request = NSFetchRequest<FavoriteDesign>(entityName: "FavoriteDesign")
            let namePredicate = NSPredicate(format: "name = %@", item.name)
            let deviceIdPredicate = NSPredicate(format: "deviceId = %@", item.deviceId)
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, deviceIdPredicate])
            request.fetchLimit = 1
            request.predicate = compoundPredicate
            request.sortDescriptors = [NSSortDescriptor(key: "createTimestamp", ascending: true)]
            let result = try? context.fetch(request).first
            if let hasDesign = result {

                hasDesign.name = item.name
                try? context.save()
            } else {

                
                let desgin = FavoriteDesign(context: context)
                desgin.name = item.name
                desgin.deviceId = item.deviceId
                try? context.save()
            }
        }
    }
    
    func deleteDesignWithNameAndId(name: String, deviceId:String) throws {
        container.performBackgroundTask { context in
            let request = NSFetchRequest<FavoriteDesign>(entityName: "FavoriteDesign")
            let namePredicate = NSPredicate(format: "name = %@", name)
            let deviceIdPredicate = NSPredicate(format: "deviceId = %@", deviceId)
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, deviceIdPredicate])
            request.predicate = compoundPredicate
            do {
                if let result = try context.fetch(request).first {
                    context.delete(result)
                    try context.save()
                }
            } catch let error as NSError {
                print("Error in deleting object: \(error), \(error.userInfo)")
            }
        }
    }
    
    func deleteDesignWithName(name: String) throws {
        container.performBackgroundTask { context in
            let request = NSFetchRequest<InkDesign>(entityName: "InkDesign")
            request.predicate = NSPredicate(format: "name = %@", name)
            do {
                if let result = try context.fetch(request).first {
                    context.delete(result)
                    try context.save()
                }
            } catch let error as NSError {
                print("Error in deleting object: \(error), \(error.userInfo)")
            }
        }
    }
    
    
    func insetOrUpdateDevice(name:String, item: Device) {
        let context = container.viewContext
        let request = NSFetchRequest<InkDevice>(entityName: "InkDevice")
        //let namePredicate = NSPredicate(format: "name = %@", name)
        let deviceIdPredicate = NSPredicate(format: "mac = %@", item.indentify)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [deviceIdPredicate])
        request.predicate = compoundPredicate
        request.fetchLimit = 1
        request.sortDescriptors = [NSSortDescriptor(key: "createTimestamp", ascending: true)]
         do {
             if let existingDevice = try context.fetch(request).first {
                 // 更新现有设备
                 existingDevice.name = item.deviceName
                 existingDevice.deviceImage = item.deviceImage
             } else {
                 // 创建新设备
                 let newDevice = InkDevice(context: context)
                 newDevice.name = item.deviceName
                 newDevice.mac = item.indentify
                 newDevice.deviceImage = item.deviceImage
                 newDevice.hGrids = Int64(item.deviceType.shape[0])
                 newDevice.vGrids = Int64(item.deviceType.shape[1])
             }
             
             try context.save()
         } catch {
             print("Error inserting or updating device: \(error)")
         }
    }
    
    func deleteDeviceWith(mac: String) throws {
        container.performBackgroundTask { context in
            let request = NSFetchRequest<InkDevice>(entityName: "InkDevice")
            request.predicate = NSPredicate(format: "mac = %@", mac)
            do {
                if let result = try context.fetch(request).first {
                    context.delete(result)
                    try context.save()
                }
            } catch let error as NSError {
                print("Error in deleting object: \(error), \(error.userInfo)")
            }
        }
    }
}
