//
//  ViewController.swift
//  MyLocations
//
//  Created by yanjixian on 2021/6/15.
//

import UIKit

class CurrrentLocationViewController: UIViewController {

    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var tagButton: UIButton!
    @IBOutlet var getButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    @IBAction func getLocation() {
        
    }


}

