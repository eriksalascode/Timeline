//
//  ViewController.swift
//  Timeline
//
//  Created by Erik Salas on 3/23/19.
//  Copyright © 2019 Erik Salas. All rights reserved.
//

import UIKit
import RealmSwift

class ItemViewController: UITableViewController {
    //create an array of Item() objects
    var categoryItems: Results<Item>?
    let realm = try! Realm()


    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //load the items in the lists when the app loads
    }
    
    // MARK: - Tableview datasource methods
    
    //specify the number of sections that will be in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryItems?.count ?? 1
    }
    
    //send the data from the itemArray to be displayed in the table's cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create the reusable cell that will be used to display all the information on the table
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        //create a reference to the item in the itemArray at the current indexPath
        if let item = categoryItems?[indexPath.row] {
            
        //set the cell's label to the tile of the itemArray item at the current indexPath
        cell.textLabel?.text = item.title
        //set the accessoryType of the item in the itemArray at the current indexPath
        //depending on the state of the item.done property
        cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items In This Category"
        }
        
        //return the custom cell at the current itemArray indexPath.row
        return cell
    }
    
    // MARK: - Tableview delegate methods
    
    //determine when a cell is selected by the user
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
    
    //Create an action for the add item (+) bar button that will add a new item into the itemArray
    @IBAction func addItemButton(_ sender: UIBarButtonItem) {
        //create a local UITextField variable that will hold the new item to be saved into the context and then persistantContainer
        var textField = UITextField()
       
        //create a new aleart to allow the user to add an new item to their list
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        //create an action button to the alert that will allow the user to confirm to add a new item
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //inside this closure, a new item will be created with all of its properities, added to the context, and appended
            //to the local itemArray
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
            

            
            //then the saveItems method will access context to save updated itemArray into the
            //persistent container
        }
        
        //add a texfield to the alert that will temporaraly hold the new item typed by the user and then saved into the
        //local textField variable
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        //add the action to the alert
        alert.addAction(action)
        
        //present the alert to the user
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model manipulation methods
    
    //the function that will be called every time the table is modified

    //the function that will be used to load items from the persistantContainer into the tableview
    //if there is no initial request or predicate, then there will be a defualt request and predicate will be nil
    //if there is a specified request and predicate passed into the loadItems func, the specified
    //request/predicate will be used
    func loadItems() {
        //predicate that will return only items that are owned by specified category
        categoryItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        //reload the table to show updated data
        tableView.reloadData()
    }
}

//MARK: - Search bar methods

// an extension that will be using the UISearchBarDelegate protocol and will be using some of its
//delegate methods
extension ItemViewController: UISearchBarDelegate {
    //call a delegate method that will detect when the search bar is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        categoryItems = categoryItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()

//        categoryItems = categoryItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            //show all items when the searchBar.text count is reset to 0
            loadItems()

            //disable the search bar after the x button is pressed to clear it, setting it to be done by the main thread
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

