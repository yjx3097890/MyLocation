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
}
