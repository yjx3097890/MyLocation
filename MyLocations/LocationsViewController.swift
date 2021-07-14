//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by yanjixian on 2021/7/9.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
        let fetchRequest = NSFetchRequest<Location>(entityName: "Location")
       
        let sortDescription1 = NSSortDescriptor(key: "category", ascending: false)
        let sortDescription2 = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescription1, sortDescription2]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: "category", cacheName: "Locations")
        fetchedController.delegate  = self
        return fetchedController
    }()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
      performFetch()
        
        navigationItem.rightBarButtonItem = editButtonItem
      
    }
    
    deinit {
        // don’t get any more notifications that were still pending.非必须
        fetchedResultsController.delegate = nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = fetchedResultsController.sections![section]
        return section.name
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let sectionInfo = fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell

        let location = fetchedResultsController.object(at: indexPath)
        cell.configure(for: location)
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
             // Delete the row from the data source
            let location = fetchedResultsController.object(at: indexPath)
            location.removePhotoFile()
            managedObjectContext.delete(location)
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
            
            
        } else if editingStyle == .insert {
            //  Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPath(for: sender as! LocationCell) {
                let location = fetchedResultsController.object(at: indexPath)
                controller.locationToEdit = location
            }
            
        }
    }
    
    // MARK: - Helper Methods
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    

}

// MARK: - NSFetchResultsController Delegate Extension
extension LocationsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(" *** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                let location = controller.object(at: indexPath!) as! Location
                cell.configure(for: location)
            }
            tableView.updateConstraints()
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        @unknown default:
            // @unknown default warns us about the missing case
            print("*** NSFetchedResults unknown type")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                  print("*** NSFetchedResultsChangeInsert (section)")
                  tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
                case .delete:
                  print("*** NSFetchedResultsChangeDelete (section)")
                  tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
                case .update:
                  print("*** NSFetchedResultsChangeUpdate (section)")
                case .move:
                  print("*** NSFetchedResultsChangeMove (section)")
                @unknown default:
                  print("*** NSFetchedResults unknown type")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}
