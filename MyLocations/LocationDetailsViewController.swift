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
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var category = "No Category"
    var date = Date()
    var descriptionText = ""
    var image: UIImage?
    
    var managedObjectContext: NSManagedObjectContext!
    var observer: Any!
  
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
    
    deinit {
        print("*** deinit \(self)")
        NotificationCenter.default.removeObserver(observer!)
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
            location.photoID = nil
        }
        location.locationDescription = descriptionTextView.text
        location.category = category
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        // save image
        if let image = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            // converts the UIImage to JPEG format
            if let data = image.jpegData(compressionQuality: 0.5) {
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
        
        
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
        clearsSelectionOnViewWillAppear = true
        
        if let location = locationToEdit {
            title = "Edit Location"
            if location.hasPhoto, let photoImage = location.photoImage {
                show(image: photoImage)
            }
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
        
        listenForBackgroundNotification()
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
        } else if indexPath.section == 2 && indexPath.row == 0{
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
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

    func show(image: UIImage) {
        imageView.image = image
        imageHeight.constant = 260
        tableView.reloadData()
        imageView.isHidden = false
        addPhotoLabel.isHidden = true
    }
    
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(forName: UIScene.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) {
            [weak self]  _ in
            if let temp = self {
                if temp.presentedViewController != nil {
                    temp.dismiss(animated: false, completion: nil)
                }
                temp.descriptionTextView.resignFirstResponder()
            }
        }
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

extension LocationDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if let temp = image {
            show(image: temp)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - helper method
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
      let imagePicker = UIImagePickerController()
      imagePicker.sourceType = .photoLibrary
      imagePicker.delegate = self
      imagePicker.allowsEditing = true
      present(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let photoAction = UIAlertAction(title: "Take Photo", style: .default) {
            _ in
            self.takePhotoWithCamera()
        }
        alert.addAction(photoAction)
        
        let libraryAction = UIAlertAction(title: "Choose From Library", style: .default) {
            _ in self.choosePhotoFromLibrary()
        }
        alert.addAction(libraryAction)
        
        present(alert, animated: true, completion: nil)
        
    }
}
