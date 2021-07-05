//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by yanjixian on 2021/6/19.
//

import UIKit
import CoreLocation

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

    // MARK: - Actions
    @IBAction func done() {
        navigationController?.popViewController(animated: true)
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

        descriptionTextView.text = ""
        categoryLabel.text = category
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        dateLabel.text = format(date: Date())
        
        if let placemark = placemark {
            addressLabel.text = stringFor(placemark: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
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
    
    // MARK: - helper methods
    
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
