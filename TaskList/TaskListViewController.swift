//
//  TaskListViewController.swift
//  TaskList
//
//  Created by Максим Евграфов on 30.09.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    private let cellID = "task"
    private var taskList: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        fetchData()
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem:.add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc
    private func addNewTask() {
        showAlert()
    }
    
    private func fetchData() {
        StorageManager.shared.fetchTasks() { [weak self] result in
            switch result {
            case .success(let tasks):
                self?.taskList = tasks
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func showAlert(task: Task? = nil, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "New task", message: "What do you want to do?", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
            if let task = task, let completion = completion {
                StorageManager.shared.updateTask(task: task, with: taskName)
                completion()
            } else {
                save(taskName: taskName)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            if task != nil {
                textField.placeholder = task?.title // На случай, если юзер сотрет весь текст, а потом забудет, что он редактирует)
                textField.text = task?.title
            } else {
                textField.placeholder = "New task..."
            }
        }
        present(alert, animated: true)
    }
    
    private func save(taskName: String) {
        StorageManager.shared.createTask(with: taskName) { [weak self] result in
            switch result {
            case .success(let taskResult):
                self?.taskList.append(taskResult)
                guard let row = self?.taskList.count else { return }
                let cellIndex = IndexPath(row: (row - 1), section: 0)
                self?.tableView.insertRows(at: [cellIndex], with: .automatic)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func deleteTask(at index: Int) {
        let cellIndex = IndexPath(row: index, section: 0)
        let task = taskList[cellIndex.row]
        
        StorageManager.shared.deleteTask(task: task) { [weak self] result in
            switch result {
            case .success(_):
                self?.taskList.remove(at: index)
                self?.tableView.deleteRows(at: [cellIndex], with: .automatic)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}

// MARK: - UITableView Data Source
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableView Delegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(task: taskList[indexPath.row]) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteTask = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.deleteTask(at: indexPath.row)
            completionHandler(true)
        }
        
        deleteTask.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteTask])
        
        return configuration
    }
}
