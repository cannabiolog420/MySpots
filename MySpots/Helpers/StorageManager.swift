//
//  StorageManager.swift
//  MySpots
//
//  Created by cannabiolog420 on 09.10.2020.
//

import Foundation
import RealmSwift




let realm = try! Realm()


class StorageManager{
    
    
    static func saveObject(_ spot: Spot){
        
        try! realm.write{
            
            realm.add(spot)
        }
    }
    
    static func deleteObject(_ spot:Spot){
        
        try! realm.write{
            
            realm.delete(spot)
        }
    }
    
}
