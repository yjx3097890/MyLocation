//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by yanjixian on 2021/7/7.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    public var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    public var subtitle: String? {
        category
    }
    
    var hasPhoto: Bool {
        photoID != nil
    }
    
    var photoURL: URL {
        assert(photoID != nil, "No photo ID set")
        let fileName = "Photo-\(photoID!.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(fileName)
    }
    
    var photoImage: UIImage? {
        UIImage(contentsOfFile: photoURL.path)
    }
    
    class func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
      let currentID = userDefaults.integer(forKey: "PhotoID") + 1
      userDefaults.set(currentID, forKey: "PhotoID")
      return currentID
    }
    
    func removePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL)
            } catch {
                print("Error removing filr: \(error)")
            }
        }
    }
}
