//
//  ViewController.swift
//  Timeline
//
//  Created by Erik Salas on 3/23/19.
//  Copyright © 2019 Erik Salas. All rights reserved.
//

import UIKit
import CoreData

class ItemViewController: UITableViewController {
    //use the app delegate to reach the persistentContainer viewContext
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    //create an array of Item() objects
    var items = [Item]()
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
        return items.count
    }
    
    //send the data from the itemArray to be displayed in the table's cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create the reusable cell that will be used to display all the information on the table
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        
        //create a reference to the item in the itemArray at the current indexPath
        let item = items[indexPath.row]
        //set the cell's label to the tile of the itemArray item at the current indexPath
        cell.textLabel?.text = item.title
        //set the accessoryType of the item in the itemArray at the current indexPath
        //depending on the state of the item.done property
        cell.accessoryType = item.done ? .checkmark : .none
        
        //return the custom cell at the current itemArray indexPath.row
        return cell
    }
    
    // MARK: - Tableview delegate methods
    
    //determine when a cell is selected by the user
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //if the cell is tapped by the user, set the item.done property to the opposite of
        //what it currently is
        items[indexPath.row].done = !items[indexPath.row].done
        
        //call the saveItems method that will reach into the context to save the updated table
        //data into the persistantContainer
        saveItems()
        
        //use the tableView.deslectRow to remove the gray background from a cell when it is selected
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
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.items.append(newItem)
            
            //then the saveItems method will access context to save updated itemArray into the
            //persistent container
            self.saveItems()
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
    func saveItems() {
        //throws, so check if context is able to save into the persistantContainer
        do {
            try context.save()
        } catch {
            print(error)
        }
        
        //reload the table to show updated data
        tableView.reloadData()
    }

    //the function that will be used to load items from the persistantContainer into the tableview
    //if there is no initial request or predicate, then there will be a defualt request and predicate will be nil
    //if there is a specified request and predicate passed into the loadItems func, the specified
    //request/predicate will be used
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        //predicate that will return only items that are owned by specified category
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        //if a predicate is provided into the loadItems func, then both the additional predicate and the categoryPredicate
        //will be used by the request
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
        //if no default predicate is provided into the loadItems func, then only the categoryPredicate will be used by request
            request.predicate = categoryPredicate
        }
        
        //fetch the items specified by the request and predicate into the local items array
        do {
            items = try context.fetch(request)
        } catch {
            print(error)
        }
        
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
        //create a request to be sent to the persistantContainer
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        //create a predicate that will determine the request's search along with a way to sort the
        //results returned
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        //call the loadItems method with the new search request, predicate, and sort method
        loadItems(with: request, predicate: predicate)
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

