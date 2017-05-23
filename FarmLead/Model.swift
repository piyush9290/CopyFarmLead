//
//  Model.swift
//  FarmLead
//
//  Created by Piyush Sharma on 2017-05-04.
//  Copyright © 2017 Piyush. All rights reserved.
//

import Foundation


class Transport {
    
    var offerID = ""
    var offerVisits = ""
    var offerExpiry = ""
    var grainName = ""
    var gradeName = ""
    var cropYear = ""
    
    var transportName = ""
    var region = Region()
    var distance = Distance()
    var willDeliver = ""
    var deliveryDistance = Distance()
    var grainStorageName = ""
    var movementYear = ""
    var movementPeriod = ""
    
    var userRating = ""
    
    var offerImages = [Image]()
    
    var moisture = ""
    var organicName = ""
    
    var comments = ""
    
    
    
    //MARK:- API Methods
    
    class func getOfferInformation(withURL urlStr : String, AndParameters params : [String : Any], success : @escaping (Transport) ->(), failure : @escaping (String) -> ()) {
        
        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        
        var request = URLRequest(url: NSURL(string: urlStr)! as URL)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            
            if let error = error {
                
                DispatchQueue.main.async {
                    
                    failure(error.localizedDescription)
                }
                return
            }
            
            if let responseData = data {
                
                do {
                    
                    let jsonDict = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as! [String : AnyObject]
                    print(jsonDict)
                    let transObj = Transport.parseTransportData(dict: jsonDict)
                    
                    DispatchQueue.main.async {
                        
                        success(transObj)
                    }
                    
                }catch let jsonError as NSError {
                    
                    DispatchQueue.main.async {
                     
                        failure(jsonError.localizedDescription)
                    }
                }
                
                
            }
        })
        
        task.resume()
    }
    
    
    

    
    //MARK:- Parsing Methods
    
    class func parseTransportData(dict: [String : AnyObject]) -> Transport {
        
        let transportObj = Transport()
        
        transportObj.offerID = "\(dict["id"]!)"
        transportObj.offerVisits = "\(dict["visits"]!)"
        transportObj.offerExpiry = dict["expiration"] as! String
        transportObj.grainName = dict["grain_name"] as! String
        transportObj.gradeName = dict["grade_name"] as! String
        transportObj.cropYear = dict["season_name"] as! String
        transportObj.transportName = dict["transport_name"] as! String
        transportObj.region = Region.parseRegion(dict: dict["region"] as! [String : AnyObject])
        transportObj.distance = Distance.getDistance(dict: dict["distance"] as! [String : AnyObject])
        transportObj.willDeliver = "\(dict["will_deliver"]!)"
        transportObj.deliveryDistance = Distance.getDistance(dict: ["distance" : dict["delivery_distance"] as AnyObject])
        transportObj.grainStorageName = dict["grain_storage_name"] as! String
        transportObj.movementYear = "\(dict["delivery_year"]!)"
        transportObj.movementPeriod = dict["delivery_name"] as! String
        
        transportObj.userRating = "\(dict["user_rating"]!)"
        transportObj.offerImages = Image.parseImages(imagesArr: dict["images"] as! [[String : String]])
        
        if let moisture = dict["moisture"]  {
            
            transportObj.moisture = "\(moisture)"
        }
        transportObj.organicName = dict["organic_name"] as! String
        
        if let comments = dict["comments"] as? String {
            
            transportObj.comments = comments
        }
        
        return transportObj
    }
    
}


class Image {
    
    var fullImage = ""
    var thumbnailImage = ""
    
    class func parseImages(imagesArr : [[String : String]]) -> [Image] {
        
        var imgArr = [Image]()
        
        for dict in imagesArr {
            
            let imgObj = Image()
            imgObj.fullImage = dict["full"]!
            imgObj.thumbnailImage = dict["thumb"]!
            
            imgArr.append(imgObj)
        }
        
        return imgArr
    }
}



class Region {
    
    var cityID = ""
    var cityName = ""
    var provinceID = ""
    var provinceName = ""
    
    
    class func parseRegion(dict : [String : AnyObject]) -> Region {
        
        let regionObj = Region()
        
        regionObj.cityID = "\(dict["city_id"])"
        regionObj.cityName = dict["city_name"] as! String
        regionObj.provinceID = "\(dict["province_id"])"
        regionObj.provinceName = dict["province_name"] as! String
        
        return regionObj
    }
}

class Distance {
    
    var miles = ""
    var kms = ""
    var compass = ""
    var region = Region()
    
    class func getDistance(dict : [String : AnyObject]) -> Distance {
        
        let disObj = Distance()
        
        disObj.kms = "\((dict["distance"] as! [String : AnyObject])["km"])"
        disObj.miles = "\((dict["distance"] as! [String : AnyObject])["mi"])"
        
        if let compass = dict["compass"] as? String {
            
            disObj.compass = compass
        }
        
        if let regionDict = dict["from"] as? [String : AnyObject] {
            
            let region = Region.parseRegion(dict: regionDict)
            disObj.region = region
        }
        
        return disObj
    }
}

