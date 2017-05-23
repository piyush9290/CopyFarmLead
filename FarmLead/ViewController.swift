//
//  ViewController.swift
//  FarmLead
//
//  Created by Piyush Sharma on 2017-05-04.
//  Copyright © 2017 Piyush. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var Label_offerID: UILabel!
    @IBOutlet weak var Label_offerViews: UILabel!
    @IBOutlet weak var loaderView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    func updateNavigationLabels(_ transportObj : Transport) {
        
        Label_offerID.text = "Offer #\(transportObj.offerID)"
        Label_offerViews.text = "Viewed \(transportObj.offerVisits) times"
    }
}

