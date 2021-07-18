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
        // Round corner for images
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2
        photoImageView.clipsToBounds = true
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0)
        
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
            text.add(text: placemark.subThoroughfare)
            text.add(text: placemark.thoroughfare)
           text.add(text: placemark.locality, separatedBy: ", ")
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
            return UIImage(named: "No Photo")!
        }
    }

}
