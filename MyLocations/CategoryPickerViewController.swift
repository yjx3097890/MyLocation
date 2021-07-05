//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by yanjixian on 2021/7/5.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
    
    var selectedCategory = ""
    
    let categories = [
        "No Category",
        "Apple Store",
        "Bar",
        "Bookstore",
        "Club",
        "Grocery Store",
        "Historic Building",
        "House",
        "Icecream Vendor",
        "Landmark",
        "Park"
      ]
    
    var selectedIndexPath = IndexPath(row: 0, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 0..<categories.count {
            if categories[i] == selectedCategory {
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = categories[indexPath.row]
        
        if selectedCategory == categories[indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
      
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedIndexPath.row {
            tableView.cellForRow(at: selectedIndexPath)?.accessoryType = .none
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            selectedIndexPath = indexPath
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                selectedCategory = categories[indexPath.row]
            }
            
        }
    }
    

}
