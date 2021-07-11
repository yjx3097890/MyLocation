//
//  MapViewController.swift
//  MyLocations
//
//  Created by yan jixian on 2021/7/11.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext!
    
    var locations = [Location]()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        if !locations.isEmpty {
            showLocations()
        }
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    @IBAction func showUser() {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        
    }
    
    @IBAction func showLocations() {
        mapView.setRegion(region(for: locations), animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Helper Methods
    func updateLocations() {
        mapView.removeAnnotations(locations)
        let entity = Location.entity()
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        
        locations = try! managedObjectContext.fetch(fetchRequest)
        mapView.addAnnotations(locations)
        
    }
    
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        
        switch annotations.count {
        case 0:
            region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        case 1:
            region = MKCoordinateRegion(center: annotations[0].coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        default:
            var topLeft = CLLocationCoordinate2D(
              latitude: -90,
              longitude: 180)
            var bottomRight = CLLocationCoordinate2D(
              latitude: 90,
              longitude: -180)

            for annotation in annotations {
              topLeft.latitude = max(topLeft.latitude,
                                     annotation.coordinate.latitude)
              topLeft.longitude = min(topLeft.longitude,
                                      annotation.coordinate.longitude)
              bottomRight.latitude = min(bottomRight.latitude,
                                         annotation.coordinate.latitude)
              bottomRight.longitude = max(
                bottomRight.longitude,
                annotation.coordinate.longitude)
            }

            let center = CLLocationCoordinate2D(
              latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2,
              longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2)

            let extraSpace = 1.1
            let span = MKCoordinateSpan(
              latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace,
              longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)

            region = MKCoordinateRegion(center: center, span: span)
          }

          return mapView.regionThatFits(region)

    }

}

extension MapViewController: MKMapViewDelegate {
    
}
