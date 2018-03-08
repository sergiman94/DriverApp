//
//  DriverVC.swift
//  DriverApp
//
//  Created by Sergio Manrique on 1/22/18.
//  Copyright © 2018 smm. All rights reserved.
//
/*
 Clase encargada de gestionar la localizacion y de recibir la solicitud del rider,
 al mismo tiempo de enviar la solicitud para cancelarla al rider
*/

import UIKit
import MapKit

// recibe el protocolo UberController de la clase UberHandler
class DriverVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberController {

    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var acceptUberBtn: UIButton!
    
    
    private var locationManager = CLLocationManager()
    private var userLocation : CLLocationCoordinate2D?
    private var riderLocation : CLLocationCoordinate2D?
    
    private var timer = Timer()
    
    private var acceptedUber = false
    private var driverCanceledUber = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        
        UberHandler.Instance.delegate = self
        UberHandler.Instance.obseveMessagesForDriver()
    }
    
    /* funcion encargada de de definir e inicializar el delegado del location manager, como tambien de pedir
     la autorizacion al usuario de usar su localizacion y demas requisitos necesarios para una
     buena conexion y localizacion */
    private func initializeLocationManager(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        UberHandler.Instance.delegate = self
        
    }
    
    /*
     Funcion encargada de conocer la localizacion del usuario u objeto y gestionar su movimiento en el mapa
     tambien de realziar las anotaciones necesarias con respecto al driver en el mapa para asi
     poder visualizarlo, demás gestiones
    */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // if we have the locations from the manager
        // si tenemos las localizaciones desde el manager
        if let location = locationManager.location?.coordinate{
            
            // encontramos la ubicacion de esta entidad con respecto a la latitud y la longitud
            userLocation = CLLocationCoordinate2D(latitude:location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            myMap.setRegion(region, animated: true)
            
            myMap.removeAnnotations(myMap.annotations)
            
            if riderLocation != nil {
                if acceptedUber {
                    let riderAnnotation = MKPointAnnotation()
                    riderAnnotation.coordinate = riderLocation!
                    riderAnnotation.title = "Riders Location"
                    myMap.addAnnotation(riderAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation!
            annotation.title = "Drivers Location"
            myMap.addAnnotation(annotation)
            
        }
        
    }
    
    /*
     Boton cerrar sesion
     se cancelan todas las solicitudes y se deja de actualizar la ubicacion del driver en la bd
    */
    @IBAction func logOut(_ sender: Any) {
        if AuthProvider.Instance.logOut() {
            
            if acceptedUber {
                acceptUberBtn.isHidden = true
                UberHandler.Instance.cancelUberForDriver()
                // dejamos de actualizar la localizacion del usuario a la bd
                timer.invalidate()
            }
            
            dismiss(animated: true, completion: nil)
            
        }else{
            // problem with login out
            uberRequest(title: "Could Not Logout", message: "We could not logout at the moment, please try again later", requestAlive: false)
        }
    }
    
    /*
     funcion encargada de cancelar la solicitud del rider, esta aparece solo cuando se haya aceptado la solicitud del rider
     funcion del protocolo uberController
    */
    func riderCanceledUber() {
        
        if !driverCanceledUber{
            UberHandler.Instance.cancelUberForDriver()
            self.acceptedUber = false
            self.acceptUberBtn.isHidden = true
            uberRequest(title: "Uber Canceled", message: "The Rider Has Canceled The Uber", requestAlive: false)
            
        }
        
        driverCanceledUber = false
    }
    
    /*
     Funcion que advierte al driver la llegada de una solicitud por parte del rider
     funcion del protocolo uberController
    */
    func acceptUber(lat: Double, long: Double) {
        
        if !acceptedUber{
            uberRequest(title: "Uber Request", message: "You have a request for an uber at this location Lat: \(lat), Lon: \(long)", requestAlive: true)
        }
    }
    
    /*
     funcion que actualiza la ubicacion del rider
     funcion del protocolo uberController
    */
    func updateRidersLocation(lat: Double, long: Double) {
        riderLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    /*
     funcion que cancela una solicitud
     funcion del protocolo uberController
    */
    func uberCanceled() {
        acceptedUber = false
        acceptUberBtn.isHidden = true
        timer.invalidate()
    }
    
    // funcion que actualiza la ubicacion del driver
    @objc func updateDriversLocation(){
        UberHandler.Instance.updateDriverLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }
    
    /*
     Boton que cancela la solicitud
     cancela la solicitud y deja de actualizar la ubicacion de el driver
    */
    @IBAction func cancelUber(_ sender: Any) {
        if acceptedUber{
            driverCanceledUber = true
            acceptUberBtn.isHidden = true
            UberHandler.Instance.cancelUberForDriver()
            timer.invalidate() // se aplica para que se deje de rastrear la localizacion
        }
    }
    
    /*
     funcion encargada de recibir la solicitud por parte de un rider y mostrarla al driver
    */
    private func uberRequest(title: String, message: String, requestAlive: Bool){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if requestAlive {
            
            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (AlertAction: UIAlertAction) in
             
                self.acceptedUber = true
                self.acceptUberBtn.isHidden = false
                
                // ESTUDIAR ESTA LINEA (CONSUMO DE BATERIA DE ACUERDO AL INTERVALO DE TIEMPO DE REPETICION)
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(DriverVC.updateDriversLocation), userInfo: nil, repeats: true)
                
                //inform that we accepted the uber
                UberHandler.Instance.uberAccepted(lat: Double(self.userLocation!.latitude), long: Double(self.userLocation!.longitude))
                
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            alert.addAction(accept)
            alert.addAction(cancel)
        }else{
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // funcion que contiene un mensaje de alerta acorde a la situacion
    private func alertTheUser(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        
    }
    
    
}
