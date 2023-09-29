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
    
    private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private init() {}
    
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
        do {
            viewContext.delete(task)
            try viewContext.save()
            completion(.success(task))
        } catch let error {
            completion(.failure(error))
        }
    }
}
