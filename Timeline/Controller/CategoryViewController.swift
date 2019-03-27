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
    }
    
    // MARK: - Table View Datasource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
            
            cell.backgroundColor = categoryColor
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }

        
        
        return cell
    }
    
  
    
    // MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ItemViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }

    
    
    // MARK: - Add New Categories
    @IBAction func addCategoryButton(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            self.save(category: newCategory)
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
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
    
    func loadCategories() {
        categories = realm.objects(Category.self)
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
}


/*
 
 
 override func viewDidLoad() {
 super.viewDidLoad()
 view.backgroundColor = .black
 
 navigationController?.navigationBar.barTintColor = ColorCodes.logoPrimaryColor
 let label = UILabel()
 label.attributedText = NSMutableAttributedString(string: "Your Profile", attributes: [NSAttributedString.Key.font : UIFont(name: "Montserrat-Bold", size: 15)!, NSAttributedString.Key.foregroundColor : UIColor.white])
 label.sizeToFit()
 navigationController?.navigationBar.topItem?.titleView = label
 navigationController?.navigationBar.tintColor = .white
 navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(signOutUser))
 navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "SettingsWheel"), style: .plain, target: self, action: #selector(settingsTapped))
 }
 
 
 
 
 */
