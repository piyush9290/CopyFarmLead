//
//  OfferTableViewController.swift
//  FarmLead
//
//  Created by Piyush Sharma on 2017-05-04.
//  Copyright © 2017 Piyush. All rights reserved.
//

import UIKit
import SDWebImage

class OfferTableViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    //MARK:- Outlets/Properties
    
    @IBOutlet weak var Label_offerExpiry: UILabel!
    @IBOutlet weak var Label_grainName: UILabel!
    @IBOutlet weak var Label_cropYear: UILabel!
    @IBOutlet weak var Label_transportName: UILabel!
    @IBOutlet weak var Label_city: UILabel!
    @IBOutlet weak var Label_direction: UILabel!
    @IBOutlet weak var Label_willingToDeliver: UILabel!
    @IBOutlet weak var Label_storage: UILabel!
    @IBOutlet weak var Label_movementYear: UILabel!
    @IBOutlet weak var Label_movementPeriod: UILabel!
    @IBOutlet weak var Label_rating: UILabel!
    @IBOutlet weak var Label_moisture: UILabel!
    @IBOutlet weak var Label_organic: UILabel!
    @IBOutlet weak var Label_comments: UILabel!
    @IBOutlet weak var collectionViewObj: UICollectionView!
    @IBOutlet weak var Label_sale: UILabel! {
        didSet {
            Label_sale.layer.borderWidth = 2.0
            Label_sale.layer.borderColor = UIColor(colorLiteralRed: 224/255, green: 213/255, blue: 110/255, alpha: 1.0).cgColor
        }
    }
    
    
    @IBOutlet weak var cell1: UITableViewCell!
    @IBOutlet weak var cell2: UITableViewCell!
    @IBOutlet weak var cell3: UITableViewCell!
    @IBOutlet weak var cell4: UITableViewCell!
    @IBOutlet weak var cell5: UITableViewCell!
    @IBOutlet weak var cell6: UITableViewCell!
    
    
    
    var transportObj = Transport()
    
    //MARK:- Object Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.preferredContentSizeChanged(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 120, 0)
        tableView.tableFooterView = UIView.init(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        getOfferDetails()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Navigation
    
    func preferredContentSizeChanged(_ notification : Notification) {
        
        updateCellLabelTexts(ForCell: cell1)
        updateCellLabelTexts(ForCell: cell2)
        updateCellLabelTexts(ForCell: cell3)
        updateCellLabelTexts(ForCell: cell4)
        updateCellLabelTexts(ForCell: cell5)
        updateCellLabelTexts(ForCell: cell6)
    }
    
    func updateCellLabelTexts(ForCell cell : UITableViewCell) {
        
        for view in cell.contentView.subviews {
            
            if let label = view as? UILabel {
                
                label.font = UIFont.preferredFont(forTextStyle: .body)
            }
        }
    }
    
    //MARK:- View Setup
    
    func getOfferDetails() {
        
        let parentVC = self.parent as! ViewController
        parentVC.loaderView.isHidden = false
        
        let urlStr = "https://api.farmlead.com/api/v2/offer/34462"
        let params = ["region_id" : 5460]
        
        Transport.getOfferInformation(withURL: urlStr, AndParameters: params, success: { (responseObj) in
            
            parentVC.loaderView.isHidden = true
            
            self.transportObj = responseObj
            self.setupUI()
            
        }) { (errorStr) in
            
            parentVC.loaderView.isHidden = true
            let alert = UIAlertController.init(title: "Error", message: errorStr, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setupUI() {
        
        let parentVC = self.parent as! ViewController
        parentVC.updateNavigationLabels(transportObj)
        
        collectionViewObj.delegate = self
        collectionViewObj.dataSource = self
        
        let time = getTimePassedFromDate(dateStr: transportObj.offerExpiry)
        
        if time.contains("day") {
            
            Label_offerExpiry.text = time
            Label_offerExpiry.textColor = UIColor.gray
        }
        else if time.contains("hour") {
            
            Label_offerExpiry.text = time
            Label_offerExpiry.textColor = UIColor.darkText
        }
        else {
            
            Label_offerExpiry.text = "Not on Marketplace"
            Label_offerExpiry.textColor = UIColor.red
        }
        
        Label_grainName.text = "\(transportObj.grainName) - \(transportObj.gradeName)"
        Label_cropYear.text = transportObj.cropYear
        Label_transportName.text = transportObj.transportName
        Label_city.text = "\(transportObj.region.cityName), \(transportObj.region.provinceName)"
        Label_direction.text = "\(transportObj.distance.kms) km \(transportObj.distance.compass) of \(transportObj.distance.region.cityName), \(transportObj.distance.region.provinceName)"
        Label_willingToDeliver.text = (transportObj.willDeliver == "0") ? "NO" : "YES"
        Label_storage.text = transportObj.grainStorageName
        Label_movementYear.text = transportObj.movementYear
        Label_movementPeriod.text = transportObj.movementPeriod
        Label_rating.text = "\(transportObj.userRating) / 10"
        
        Label_moisture.text = (transportObj.moisture == "") ? "-" : transportObj.moisture
        Label_organic.text = transportObj.organicName
        Label_comments.text = (transportObj.comments == "") ? "-" : transportObj.comments
    }
    
    func getTimePassedFromDate(dateStr : String) -> String {
        
        let sharedFormatter = DateFormatter.init()
        sharedFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        sharedFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        
        let date = sharedFormatter.date(from: dateStr)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.second, .minute, .hour, .day], from: date!, to: Date())
        
        if let day = components.day {
            
            if day > 0 {
                
                return "\(day) \((day > 1) ? "days" : "day") left"
            }
        }
        
        if let hour = components.hour {
            
            if hour > 0 {
                
                return "\(hour) \((hour > 1) ? "hours" : "hour") left"
            }
        }
        
        if let minute = components.minute {
            
            if minute > 0 {
                
                return "\(minute) \((minute > 1) ? "minutes" : "minute") left"
            }
        }
        
        if let second = components.second {
            
            if second > 0 {
                
                return "\(second) \((second > 1) ? "seconds" : "second") left"
            }
        }
        
        return ""
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 120
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    //MARK:- CollectionView Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return transportObj.offerImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        
        let imgObj = transportObj.offerImages[indexPath.row]
        cell.offerImgView.sd_setImage(with: URL.init(string: imgObj.thumbnailImage))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: 90, height: 90)
    }
}
