//
//  ViewController.swift
//  Timeline
//
//  Created by Erik Salas on 3/23/19.
//  Copyright © 2019 Erik Salas. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ItemViewController: SwipeTableViewController {
    //create an array of Item() objects
    @IBOutlet var searchBar: UISearchBar!
    var categoryItems: Results<Item>?
    let realm = try! Realm()
    //    let image = UIImage(named: "checkmark")
    var add = UIBarButtonItem()
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    //MARK: - View setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        
        let backButton = UIBarButtonItem(image: UIImage(imageLiteralResourceName: "back"), style: .done, target: self, action: #selector(ItemViewController.back(sender:)))
        add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemButton(_:)))
        self.navigationItem.leftBarButtonItem = backButton
        
//        let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(addItemButton(_:)))

        navigationItem.rightBarButtonItems = [add, editButtonItem]
        

        editButtonItem.title = "Move"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        title = selectedCategory?.name
        title = selectedCategory?.name
        guard let color = selectedCategory?.color else{fatalError()}
        updateNavBar(withHexCode: color)
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "000000")
    }
    
    func updateNavBar(withHexCode colorHexCode: String) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation bar has not finished updating")}
        guard let navBarColor = UIColor(hexString: colorHexCode) else{fatalError()}
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor = navBarColor
    }
    
    // MARK: - Tableview datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = categoryItems?[indexPath.row] {
            cell.textLabel?.font = UIFont(name:"AvenirNext-Medium", size:16)
            
            if item.done {
                cell.textLabel?.text = "✔︎ \(item.title)"
            } else {
                cell.textLabel?.text = item.title
            }
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(categoryItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                cell.tintColor = ContrastColorOf(color, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text = "No Items In This Category"
        }
        
        return cell
    }
    
    // MARK: - Tableview delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if let item = categoryItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print(error)
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true )
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveItems(from: sourceIndexPath, to: destinationIndexPath)
    }
    
    //MARK: - Add new items function
    
    @objc func addItemButton(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("cancel")
        }
        
        let addItem = UIAlertAction(title: "Done", style: .default) { (action) in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        
//                        if let lastItem { currentCategory.items.last?.order else {fatalError("This is the error")}}
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
//                        newItem.order = lastItem
                        
                        print("got to this line")

                        var maxNumber = 0
                        
//                        if currentCategory.items != nil {
                        
                        
                        for (index, _) in currentCategory.items.enumerated() {
                            
//                            var minNumber = item.order
                            

//                            print(index, item)
//                            while currentCategory.items.count < (currentCategory.items.count - 1) {
                            
                            
                            // if minNumber > currentCategory.items[index].order (ORIGINAL)
                            
                                if maxNumber < currentCategory.items[index].order {
                                    print("max number is \(maxNumber)")

                                    maxNumber = currentCategory.items[index].order
                                    print("max number is \(maxNumber)")

                                }
//                            }
                            
//
//                            repeat {
//                                if minNumber > currentCategory.items[index + 1].order {
//                                    minNumber = currentCategory.items[index + 1].order
//                                }
//                            } while index < currentCategory.items.count
                            print("max number is \(maxNumber)")

                            //minNumber -= 1 (ORIGINAL)
                            maxNumber += 1
                            print("max number is \(maxNumber)")
                            newItem.order = maxNumber
//                            if index == 0 {
//                                newItem.done = item.done
//                            }
            
                        }
                            
                        
                        
                        currentCategory.items.append(newItem)
                        
                        
                    }
                } catch {
                    print(error)
                }
            }
            self.tableView.reloadData()
        }
        
        addItem.isEnabled = false
        alert.addAction(cancel)
        alert.addAction(addItem)
        alert.addTextField { (alertTextField) in
            alertTextField.enablesReturnKeyAutomatically = true
            alertTextField.returnKeyType = .done
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertTextField, queue: OperationQueue.main, using:
                {_ in
                    let textCount = alertTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let textIsNotEmpty = textCount > 0
                    addItem.isEnabled = textIsNotEmpty
            })
        }
        
        updateAlertWindow(for: alert, with: "Add New Item", cancel, addItem)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation methods
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        if(self.isEditing)
        {
            self.editButtonItem.title = "Done"
            self.add.isEnabled = false
            
        }else
        {
            self.editButtonItem.title = "Move"
            self.add.isEnabled = true
        }
        tableView.setEditing(tableView.isEditing, animated: true)
    }
    
    
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Edit Item", message: "", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("cancel")
        }
        
        let editItem = UIAlertAction(title: "Done", style: .default) { (action) in
            if let item = self.categoryItems?[indexPath.row] {
                do {
                    try self.realm.write {
                        item.title = textField.text!
                    }
                } catch {
                    print(error)
                }
            }
            
            tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            if let item = self.categoryItems?[indexPath.row] {
                alertTextField.enablesReturnKeyAutomatically = true
                alertTextField.returnKeyType = .done
                alertTextField.borderStyle = .none
                alertTextField.text = item.title
                textField = alertTextField
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(editItem)
        
        updateAlertWindow(for: alert, with: "Edit Item", cancel, editItem)
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        categoryItems = selectedCategory?.items.sorted(byKeyPath: "order")
        
//        objects = realm.objects(Data.self).sorted("order")
        
//        categoryItems = realm.objects(selectedCategory?.items.self).sorted(byKeyPath: "order")
//        lists = uiRealm.objects(TaskList)
//        self.taskListsTableView.setEditing(false, animated: true)
//        self.taskListsTableView.reloadData()
        tableView.reloadData()
    }
    
    func moveItems(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        if let sourceItem = categoryItems?[sourceIndexPath.row],
//            let destinationItem = categoryItems?[destinationIndexPath.row] {
    
//            do {
//                try realm.write {
//
//                    guard let item = selectedCategory?.items[sourceIndexPath.row] else {fatalError()}
//                    //item.currentIndex = destinationIndexPath.row
//
//                    selectedCategory?.items.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
//
//
//                }
//            } catch {
//                print("Error deleting item, \(error)")
//            }
//
//        print("moving items")
////        }
//
//        tableView.reloadData()
        
        do {
            try realm.write {
                let sourceObject = categoryItems?[sourceIndexPath.row]
                let destinationObject = categoryItems?[destinationIndexPath.row]
                
                guard let destinationObjectOrder = destinationObject?.order else {fatalError()}
                
                if sourceIndexPath.row < destinationIndexPath.row {
                    for index in sourceIndexPath.row...destinationIndexPath.row {
                        guard let item = categoryItems?[index] else {fatalError()}
                        item.order -= 1
                    }
                } else {
                    for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                        guard let item = categoryItems?[index] else {fatalError()}
                        item.order += 1
                    }
                }
                
                sourceObject?.order = destinationObjectOrder
                
            }
            
            tableView.reloadData()

        } catch {
            print("Error")
        }

        
        
//        try! realm.write {
//            let sourceObject = objects[sourceIndexPath.row]
//            let destinationObject = objects[destinationIndexPath.row]
//
//            let destinationObjectOrder = destinationObject.order
//
//            if sourceIndexPath.row < destinationIndexPath.row {
//                // 上から下に移動した場合、間の項目を上にシフト
//                for index in sourceIndexPath.row...destinationIndexPath.row {
//                    let object = objects[index]
//                    object.order -= 1
//                }
//            } else {
//                // 下から上に移動した場合、間の項目を下にシフト
//                for index in (destinationIndexPath.row..<sourceIndexPath.row).reverse() {
//                    let object = objects[index]
//                    object.order += 1
//                }
//            }
//
//            　　　　　　　　　　　　　　　　// 移動したセルの並びを移動先に更新
//            sourceObject.order = destinationObjectOrder
//        }
//
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemToDelete = categoryItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(itemToDelete)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    
    func updateAlertWindow(for alert: UIAlertController, with title: String, _ action1 : UIAlertAction, _ action2: UIAlertAction) {
        
        guard let color = selectedCategory?.color else {fatalError()}
        guard let alertColor = UIColor(hexString: color) else {fatalError()}
        let subview = (alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.layer.cornerRadius = 10.0
        subview.backgroundColor = alertColor
        
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: title as String, attributes: [NSAttributedString.Key.font:UIFont(name: "AvenirNext-Medium", size: 17.0)!])
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: ContrastColorOf(alertColor, returnFlat: true), range: NSRange(location: 0, length: title.count))
        alert.setValue(myMutableString, forKey: "attributedTitle")
        
        action1.setValue(ContrastColorOf(alertColor, returnFlat: true), forKey: "titleTextColor")
        action2.setValue(ContrastColorOf(alertColor, returnFlat: true), forKey: "titleTextColor")
    }
    
    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
}

//MARK: - Search bar methods


extension ItemViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        categoryItems = categoryItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

