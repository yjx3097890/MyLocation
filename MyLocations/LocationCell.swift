//
//  LocationCell.swift
//  MyLocations
//
//  Created by yanjixian on 2021/7/9.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - help methods
    func configure(for location: Location) {
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
          } else {
            descriptionLabel.text = location.locationDescription
          }
        
        photoImageView.image = thumbnail(for: location)

         
        if let placemark = location.placemark {
            var text = ""
            if let tmp = placemark.subThoroughfare {
              text += tmp + " "
            }
            if let tmp = placemark.thoroughfare {
              text += tmp + ", "
            }
            if let tmp = placemark.locality {
              text += tmp
            }
            addressLabel.text = text
          } else {
            addressLabel.text = String(format: "Lat: %.8f, Lon: %.8f", location.latitude, location.longitude)
          }
    }
    
    func thumbnail(for location: Location) -> UIImage {
        if location.hasPhoto, let image = location.photoImage {
            return image.resized(withBounds: CGSize(
            width: 52, height: 52))
        } else {
            return UIImage()
        }
    }

}
