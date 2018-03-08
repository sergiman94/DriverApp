//
//  UberHandler.swift
//  DriverApp
//
//  Created by Sergio Manrique on 1/22/18.
//  Copyright © 2018 smm. All rights reserved.
//
/*
 Clase que gestiona los cambios en la base de datos para asi determinar
 el funcionamiento y flujo de trabajo de la aplicacion como tal, en si
 acá esta la conexion con la otra aplicacion(rider).
*/

import Foundation
import FirebaseDatabase

// protocolo para intercambio de datos entre ViewControllers
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
        // Observa cuando el rider ha enviado la solicitud, cuando esta instancia esta en la bd pasa lo sgte:
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
            // Observa cuando el rider ha cancelado la solicitud
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
        // Se observa la actualizacion de la localizacion del rider
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
        // Observa cuando el driver ha aceptado una solicitud, se crea una nueva instancia en la bd
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
        // Observa cuando el driver ha cancelado una soliciud, se elimina una instancia en la bd
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
    
    // cuando el driver acepta una solicitud, esta funcion crea una isntancia en la base de datos
    func uberAccepted( lat : Double, long : Double){
        let data : Dictionary <String, Any> = [Constants.NAME: driver, Constants.LATITUDE: lat, Constants.LONGITUDE: long]
        DBProvider.Instance.requestAcceptedReference.childByAutoId().setValue(data)
    }
    
    // cuando el driver cancela una solicitud, esta funcion elimina la instancia en la base de datos
    func cancelUberForDriver(){
        DBProvider.Instance.requestAcceptedReference.child(driver_id).removeValue()
    }
    
    // esta funcion actualiza la localizacion del driver, enviando su ubicacion durante un intervalo de tiempo a la base datos
    func updateDriverLocation(lat: Double , long: Double){
        DBProvider.Instance.requestAcceptedReference.child(driver_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long])
    }
    
}




















