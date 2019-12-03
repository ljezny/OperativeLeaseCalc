//
//  PersistentStorageManager.swift
//  OperativeLeaseCalc
//
//  Created by Lukas Jezny on 25/11/2019.
//  Copyright © 2019 Lukas Jezny. All rights reserved.
//

import UIKit
import CoreData

class NSCustomPersistentContainer: NSPersistentContainer {
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.operativelease")
        storeURL = storeURL?.appendingPathComponent("Lease.sqlite")
        return storeURL!
    }
}

class PersistentStorageManager {
    static let shared = PersistentStorageManager()
    
    private init() {
        
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSCustomPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func loadLeaseParams() -> LeaseParams {
        let request = NSFetchRequest<LeaseParams>(entityName: "LeaseParams")
        
        guard let lp = try? persistentContainer.viewContext.fetch(request).first else {
            let lp = LeaseParams(context: persistentContainer.viewContext)
            lp.startDate = Date()
            return lp
        }
        
        return lp
    }
    
    func loadHistory() -> [History] {
        let request = NSFetchRequest<History>(entityName: "History")
        request.sortDescriptors = [NSSortDescriptor.init(key: "date", ascending: false)]
        return (try? persistentContainer.viewContext.fetch(request)) ?? [History]()
    }
    
    func addHistory(date: Date, state: Int) -> History {
        let h = History(context: persistentContainer.viewContext)
        h.date = date
        h.state = state as NSNumber
        return h
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
