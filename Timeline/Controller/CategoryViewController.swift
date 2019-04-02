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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        tableView.separatorStyle = .none
        tableView.reloadData()
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(UIColor.black, returnFlat: true)]

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
    
    // MARK: - Add New Categories
    @IBAction func addCategoryButton(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let addCategory = UIAlertAction(title: "Done", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            self.save(category: newCategory)
            print("new category was saved")
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("cancel was called")
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
                    
                    // If the text contains non whitespace characters, enable the OK Button
                    addCategory.isEnabled = textIsNotEmpty
                    
                })


        }
//
//        NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using:
//            {_ in
//                // Being in this block means that something fired the UITextFieldTextDidChange notification.
//
//                // Access the textField object from alertController.addTextField(configurationHandler:) above and get the character count of its non whitespace characters
//                let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).characters.count ?? 0
//                let textIsNotEmpty = textCount > 0
//
//                // If the text contains non whitespace characters, enable the OK Button
//                okAction.isEnabled = textIsNotEmpty
//
//        })
        

        
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Data Manipulation Methods
    
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
            cell.textLabel?.font = UIFont(name:"AvenirNext-Medium", size:24)
            cell.detailTextLabel?.font = UIFont(name:"AvenirNext-Regular", size:17)
            cell.textLabel?.text = category.name
            
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
            cell.backgroundColor = categoryColor
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat:true)
            
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
        categories = realm.objects(Category.self).sorted(byKeyPath: "name", ascending: true)
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
    
    // MARK: - Prepare For Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

}

