//
//  SpotModel.swift
//  MySpots
//
//  Created by cannabiolog420 on 09.10.2020.
//

import Foundation
import RealmSwift




class Spot:Object{
    
    
    @objc dynamic var name = ""
    @objc dynamic var location:String?
    @objc dynamic var type:String?
    @objc dynamic var imageData:Data?
    @objc dynamic var date = Date()
    @objc dynamic var rating = 0.0
    
    
    convenience init(name:String,location:String,type:String,imageData:Data,rating:Double) {
        
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
        
    }
    
    
    
    
}
