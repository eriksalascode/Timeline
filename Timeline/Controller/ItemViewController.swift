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

    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    //MARK: - View setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Timeline", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ItemViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
            cell.textLabel?.font = UIFont(name:"AvenirNext-Medium", size:17)
            
            if item.done {
                 cell.textLabel?.text = "☑️ \(item.title)"
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

    //MARK: - Add new items function
    
    @IBAction func addItemButton(_ sender: UIBarButtonItem) {
        var textField = UITextField()
       
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("cancel")
        }
        
        let addItem = UIAlertAction(title: "Done", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
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
                    // Being in this block means that something fired the UITextFieldTextDidChange notification.
                    
                    // Access the textField object from alertController.addTextField(configurationHandler:) above and get the character count of its non whitespace characters
                    let textCount = alertTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let textIsNotEmpty = textCount > 0
                    
                    // If the text contains non whitespace characters, enable the addItem button
                    addItem.isEnabled = textIsNotEmpty
                    
            })
        }
        
        updateAlertWindow(for: alert, with: "Add New Item", cancel, addItem)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation methods
    
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
        categoryItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
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

