//
//  DBProvider.swift
//  DriverApp
//
//  Created by Sergio Manrique on 1/22/18.
//  Copyright © 2018 smm. All rights reserved.
//
/*
 Clase que provee los diferentes atributos a la base de datos, tanto del usuario
 como del conductor
*/

import Foundation
import FirebaseDatabase

class DBProvider{
    
    
    
    private static let _instance = DBProvider()
    
    static var Instance : DBProvider {
        return _instance
    }
    
    // referencia de la DB
    var dbRef : DatabaseReference! {
        return Database.database().reference()
    }
    
    var driversRef : DatabaseReference! {
        return dbRef.child(Constants.DRIVERS)
    }
    
    var requestRef: DatabaseReference! {
        return dbRef.child(Constants.UBER_REQUEST)
    }
    
    var requestAcceptedReference : DatabaseReference! {
        return dbRef.child(Constants.UBER_ACCEPTED)
    }
    
    // RequestAccepted
    // funcion que guarda el email y la contraseña del usuario una vez se ha registrado
    func saveUser (withID: String, email: String, password: String){
        
        let data: Dictionary<String, Any> = [Constants.EMAIL : email, Constants.PASSWORD : password, Constants.isRider: false]
        // se le agregan los atributos del driver con respecto al diccionario 
        driversRef.child(withID).child(Constants.DATA).setValue(data)
        
    }
    
}

