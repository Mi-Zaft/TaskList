//
//  StorageManager.swift
//  TaskList
//
//  Created by Максим Евграфов on 07.10.2023.
//

import UIKit
import CoreData

final class StorageManager {
    static let shared = StorageManager()
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let viewContext: NSManagedObjectContext
    
    private init() {
        viewContext = persistentContainer.viewContext
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
    
    func fetchTasks(completion: @escaping(Result<[Task], Error>) -> Void) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let taskList = try viewContext.fetch(fetchRequest)
            completion(.success(taskList))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func createTask(with name: String, completion: @escaping(Result<Task, Error>) -> Void) {
        let task = Task(context: viewContext)
        task.title = name
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                completion(.success(task))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    func updateTask(task: Task, with name: String) {
        task.title = name
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Изменений нет")
        }
    }
    
    func deleteTask(task: Task, completion: @escaping(Result<Task, Error>) -> Void) {
        viewContext.delete(task)
        do {
            try viewContext.save()
            completion(.success(task))
        } catch let error {
            completion(.failure(error))
        }
    }
}
