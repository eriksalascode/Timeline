//
//  CategoryViewController.swift
//  Timeline
//
//  Created by Erik Salas on 3/24/19.
//  Copyright © 2019 Erik Salas. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    //create a new Realm
    let realm = try! Realm()
    //create an array of Category objects
    var categories: Results<Category>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        loadCategories()
    }
    
    // MARK: - Table View Datasource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return the number of objects in the categories array
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create a reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        //set the text label to the name of the category at the current index path
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet"
        //return the custom cell to be displayed
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //trigger the segue that will take you to the list of items associated with the current selected category
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    //prepare before triggering a new seque
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //set the destination view controller as the assumed view controller
        let destinationVC = segue.destination as! ItemViewController
        //access the selectedCategory property of the destination view controller and set it to the
        //current selected category to load the items associated with it
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

    
    
    // MARK: - Add New Categories
    @IBAction func addCategoryButton(_ sender: UIBarButtonItem) {
        //create a local variable that will hold the name of the new category once typed in by the user
        //in the alert's text field
        var textField = UITextField()
        //create an alert to allow user to enter a new category
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        //create an action button that the user can touch once they are ready to add a new category
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //create a new category reference in the context
            let newCategory = Category()
            //set the newCategory name from the textField's input
            newCategory.name = textField.text!
            //save the new category into the database
            self.save(category: newCategory)
            
        }
        //add a textField that the users can use to add the new category
        alert.addTextField { (alertTextField) in
            //set a textfield placeholder
            alertTextField.placeholder = "Add new category"
            //set the local textfield variable equal to the one typed into the textfield in the closure
            textField = alertTextField
        }
        
        //add the action to the alert
        alert.addAction(action)
        
        //present the alert to the user once they click on add new category button
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Data Manipulation Methods
    //save a new category into the database
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print(error)
        }
        //reload the tableview
        tableView.reloadData()
    }
    
    //load all categories saved in the database
    func loadCategories() {
        categories = realm.objects(Category.self)
        //reload the table view data shown to the user
        tableView.reloadData()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
