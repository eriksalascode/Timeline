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


    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
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
        searchBar.barTintColor = navBarColor
    }
        

    
    
    // MARK: - Tableview datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = categoryItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(categoryItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            cell.accessoryType = item.done ? .checkmark : .none
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
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
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
        

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation methods
    

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

