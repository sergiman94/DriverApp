//
//  UberHandler.swift
//  DriverApp
//
//  Created by Sergio Manrique on 1/22/18.
//  Copyright © 2018 smm. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol UberController: class {
    func acceptUber(lat: Double, long: Double)
    func riderCanceledUber()
    func uberCanceled()
    func updateRidersLocation(lat: Double, long: Double)
}

class UberHandler {
    
    private static let _instance = UberHandler()
    
    weak var delegate : UberController?
    
    var rider = ""
    var driver = ""
    var driver_id = ""
    
    static var Instance : UberHandler{
        return _instance
    }
    
    func obseveMessagesForDriver(){
        
        // RIDER REQUESTED AN UBER
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        self.delegate?.acceptUber(lat: latitude, long: longitude)
                    }
                }
                
                if let name = data[Constants.NAME] as? String {
                    self.rider = name
                }
            }
            
            // RIDER CANCELED UBER
            DBProvider.Instance.requestRef.observe(DataEventType.childRemoved, with: { (snapshot: DataSnapshot) in
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.rider {
                            self.rider = ""
                            self.delegate?.riderCanceledUber()
                        }
                    }
                }
            })
            
        }
        
        // RIDER UPDATING LOCATION
        DBProvider.Instance.requestAcceptedReference.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let lat = data[Constants.LATITUDE] as? Double {
                    if let long = data[Constants.LONGITUDE] as? Double {
                        self.delegate?.updateRidersLocation(lat: lat, long: long)
                    }
                }
            }
        }
        
        // DRIVER ACCEPTS UBER
        DBProvider.Instance.requestAcceptedReference.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver {
                        self.driver_id = snapshot.key
                    }
                }
            }
        }
        
        // DRIVER CANCELED UBER
        DBProvider.Instance.requestAcceptedReference.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.delegate?.uberCanceled()
                    }
                }
            }
        }
        
    }
    
    
    func uberAccepted( lat : Double, long : Double){
        let data : Dictionary <String, Any> = [Constants.NAME: driver, Constants.LATITUDE: lat, Constants.LONGITUDE: long]
        DBProvider.Instance.requestAcceptedReference.childByAutoId().setValue(data)
    }
    
    
    func cancelUberForDriver(){
        DBProvider.Instance.requestAcceptedReference.child(driver_id).removeValue()
    }
    
    func updateDriverLocation(lat: Double , long: Double){
        DBProvider.Instance.requestAcceptedReference.child(driver_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long])
    }
    
}




















