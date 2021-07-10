//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by yanjixian on 2021/6/19.
//

import UIKit
import CoreLocation
import CoreData

fileprivate let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationDetailsViewController: UITableViewController {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var category = "No Category"
    var date = Date()
    var descriptionText = ""
    
    var managedObjectContext: NSManagedObjectContext!
  
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                category = location.category
                placemark = location.placemark
                date = location.date
                coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            }
        }
    }

    // MARK: - Actions
    @IBAction func done() {
        
        guard let mainView = navigationController?.parent?.view else {
            return
        }
        let hud = HudView.hud(inView: mainView, animated: true)
        
        let location: Location
        if let temp = locationToEdit {
            hud.text = "Updated"
            location = temp
        } else {
            hud.text = "Tagged"
            location = Location(context: managedObjectContext)
        }
        location.locationDescription = descriptionTextView.text
        location.category = category
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        do {
            try managedObjectContext.save()
            afterDelay(0.6) {
                self.navigationController?.popViewController(animated: true)
                hud.hide()
            }
        } catch {
            fatalCoreDataError(error)
        }
        
        
        
        
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        category = controller.selectedCategory
        categoryLabel.text = category
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let location = locationToEdit {
            title = "Edit Location"
        }

        descriptionTextView.text = descriptionText
        categoryLabel.text = category
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        dateLabel.text = format(date: date)
        
        if let placemark = placemark {
            addressLabel.text = stringFor(placemark: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        // Hide Key
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategory = category
        }
    }
    
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section < 3 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    }
    
    // MARK: - helper methods
    
    @objc func hideKeyboard(
      _ gestureRecognizer: UIGestureRecognizer
    ) {
      let point = gestureRecognizer.location(in: tableView)
      let indexPath = tableView.indexPathForRow(at: point)

      if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
        return
      }
      descriptionTextView.resignFirstResponder()
    }

    
    
    func stringFor(placemark: CLPlacemark) -> String {
        var text = ""
        if let tmp = placemark.subThoroughfare {
            text += tmp + " "
          }
          if let tmp = placemark.thoroughfare {
            text += tmp + ", "
          }
          if let tmp = placemark.locality {
            text += tmp + ", "
          }
          if let tmp = placemark.administrativeArea {
            text += tmp + " "
          }
          if let tmp = placemark.postalCode {
            text += tmp + ", "
          }
          if let tmp = placemark.country {
            text += tmp
          }
        return text
    }

    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }

}
