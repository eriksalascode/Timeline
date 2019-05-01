//
//  CategoryViewController.swift
//  Timeline
//
//  Created by Erik Salas on 3/24/19.
//  Copyright © 2019 Erik Salas. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    //create a new Realm
    let realm = try! Realm()
    //create an array of Category objects
    var categories: Results<Category>?
    var add = UIBarButtonItem()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //load categories, set separatorStyle to .none, and reload table view
        loadCategories()
        tableView.separatorStyle = .none
        tableView.reloadData()
        
        //create an array of rightBarButtonItems that will hold an edit and add button to the right of top nav bar
        add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCategoryButton(_:)))
        navigationItem.rightBarButtonItems = [add, editButtonItem]
        
        editButtonItem.title = "Move"
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //reload data to show updated list count
        tableView.reloadData()

        //setup initial navigation bar and navigation bar item colors
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation bar has not finished updating")}
        guard let navBarColor = UIColor(hexString: "000000") else{fatalError()}
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
        

    }
    
    // MARK: - Table View Datasource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return categorySetup(indexPath: indexPath)
    }
    
  
    
    // MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveCategories(from: sourceIndexPath, to: destinationIndexPath)
    }
    
    // MARK: - Add New Categories
    @IBAction func addCategoryButton(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("cancel was called")
        }
        
        let addCategory = UIAlertAction(title: "Done", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            var maxNumber = 0
            
//            for (index, _) in currentCategory.items.enumerated() {
            let categories = self.realm.objects(Category.self)
            for (index, _) in categories.enumerated() {
            
                //                            var minNumber = item.order
                
                
                //                            print(index, item)
                //                            while currentCategory.items.count < (currentCategory.items.count - 1) {
                
                
                // if minNumber > currentCategory.items[index].order (ORIGINAL)
                
                if maxNumber < categories[index].order {
                    print("max number is \(maxNumber)")
                    
                    maxNumber = categories[index].order
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
                newCategory.order = maxNumber
                //                            if index == 0 {
                //                                newItem.done = item.done
                //                            }
                
            }
            
            
            self.save(category: newCategory)
            print("new category was saved")
            
        }
        

        
        addCategory.isEnabled = false
        
        alert.addAction(cancel)
        alert.addAction(addCategory)
        
        alert.addTextField { (alertTextField) in
            alertTextField.enablesReturnKeyAutomatically = true
            alertTextField.returnKeyType = .done
            alertTextField.placeholder = "Add new category"
            textField = alertTextField
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alertTextField, queue: OperationQueue.main, using:
                
                {_ in
                    // Being in this block means that something fired the UITextFieldTextDidChange notification.
                    
                    // Access the textField object from alertController.addTextField(configurationHandler:) above and get the character count of its non whitespace characters
                    let textCount = alertTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let textIsNotEmpty = textCount > 0
                    
                    // If the text contains non whitespace characters, enable the addCategory button
                    addCategory.isEnabled = textIsNotEmpty
                    
                })


        }
        
        let alertColor = "000000"
        updateAlertWindow(for: alert, with: "Add New Category", alertColor, cancel, addCategory)
        present(alert, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Edit Category", message: "", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("cancel")
        }
        
        let editItem = UIAlertAction(title: "Done", style: .default) { (action) in
            if let category = self.categories?[indexPath.row] {
                do {
                    try self.realm.write {
                        category.name = textField.text!
                    }
                } catch {
                    print(error)
                }
            }
            
            tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            if let category = self.categories?[indexPath.row] {
                alertTextField.enablesReturnKeyAutomatically = true
                alertTextField.returnKeyType = .done
                alertTextField.borderStyle = .none
                alertTextField.text = category.name
                textField = alertTextField
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(editItem)
        
        guard let categoryColor = categories?[indexPath.row].color else {fatalError()}
        updateAlertWindow(for: alert, with: "Edit Category", categoryColor, cancel, editItem)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Data Manipulation Methods
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        if(self.isEditing)
        {
            self.editButtonItem.title = "Done"
            add.isEnabled = false
        }else
        {
            self.editButtonItem.title = "Move"
            add.isEnabled = true
        }
        tableView.setEditing(tableView.isEditing, animated: true)
    }
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    func categorySetup(indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.font = UIFont(name:"AvenirNext-Medium", size:16)
            cell.detailTextLabel?.font = UIFont(name:"AvenirNext-Medium", size:14)
            cell.textLabel?.text = category.name
            
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
            cell.backgroundColor = categoryColor
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat:true)
            cell.tintColor = ContrastColorOf(categoryColor, returnFlat: true)
            
            if categories?[indexPath.row].items.count != 0 {
                cell.detailTextLabel?.isHidden = false
                guard let itemCount = categories?[indexPath.row].items.count else {fatalError()}
                cell.detailTextLabel?.text = String(itemCount)
                cell.detailTextLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            } else {
                cell.detailTextLabel?.isHidden = true
            }
            
        }
        return cell
    }
    
    func loadCategories() {
        //categoryItems = selectedCategory?.items.sorted(byKeyPath: "order")
        categories = realm.objects(Category.self).sorted(byKeyPath: "order")
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryToDelete = categories?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(categoryToDelete)
                }
            } catch {
                print("error updating model, \(error)")
            }
        }
    }
    
    func moveCategories(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        do {
            try realm.write {
                let sourceObject = categories?[sourceIndexPath.row]
                let destinationObject = categories?[destinationIndexPath.row]
                
                guard let destinationObjectOrder = destinationObject?.order else {fatalError()}
                
                if sourceIndexPath.row < destinationIndexPath.row {
                    for index in sourceIndexPath.row...destinationIndexPath.row {
                        guard let item = categories?[index] else {fatalError()}
                        item.order -= 1
                    }
                } else {
                    for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                        guard let item = categories?[index] else {fatalError()}
                        item.order += 1
                    }
                }
                
                sourceObject?.order = destinationObjectOrder
                
            }
            
            tableView.reloadData()
            
        } catch {
            print("Error")
        }
    }
    
    func updateAlertWindow(for alert: UIAlertController, with title: String, _ color: String, _ action1 : UIAlertAction, _ action2: UIAlertAction) {
        
        guard let alertColor = UIColor(hexString: color) else {fatalError()}
        //selectedCategory?.color else{fatalError()}
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
    
    // MARK: - Prepare For Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

}



