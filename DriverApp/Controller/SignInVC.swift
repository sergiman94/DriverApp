//
//  SignInVC.swift
//  DriverApp
//
//  Created by Sergio Manrique on 1/18/18.
//  Copyright © 2018 smm. All rights reserved.
//

/*
 Esta clase gestiona todo lo relacionado con el primer ViewContoller
 entrada de texto y la ejecucion de los distintas clases, haciendo
 invocacion de las funciones que estas mismas contienen, asi como el
 traslado del usuario a otros ViewControllers
*/

import UIKit
import FirebaseAuth

class SignInVC: UIViewController {
    
    private let DRIVER_SEGUE = "DriverVCSegue"

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Boton LogIn (Ingresar)
    @IBAction func logIn(_ sender: Any) {
        
        /* si las entradas de texto del usuario y contraseña no estan en blanco
         ejecute la funcion login de la clase AuthProvider, de lo contrario
         muestre al usuario un mensaje de alerta */
        if emailTextField.text != "" && passwordTextField.text != ""{
            
            AuthProvider.Instance.login(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                
                if message != nil{
                    self.alertTheUser(title: "Problem With Authentication", message: message!)
                }else{
                    
                    UberHandler.Instance.driver = self.emailTextField.text!
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    // traslado al otro ViewController
                    self.performSegue(withIdentifier: self.DRIVER_SEGUE, sender: nil)
                    print("LOGIN COMPLETED")
                }
            })
            
        }else{
            alertTheUser(title: "Email And Password Are Required", message: "Please enter email and password in the text fields")
        }
    }
    
    // Boton SignUp (registro)
    @IBAction func signUp(_ sender: Any) {
        
        /* si las entradas de texto del usuario y contraseña no estan en blanco
         ejecute la funcion signUp de la clase AuthProvider, de lo contrario
         muestre al usuario un mensaje de alerta */
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            AuthProvider.Instance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertTheUser(title: "Problem With Creating A New User", message: message!)
                }else{
                    
                    UberHandler.Instance.driver = self.emailTextField.text!
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    // traslado al otro ViewController
                    self.performSegue(withIdentifier: self.DRIVER_SEGUE, sender: nil)
                    print("CREATING USER COMPLETED")
                }
            })
            
        }else{
            alertTheUser(title: "Email And Password Are Required", message: "Please enter email and password in the text fields")
        }
        
        
    }
    
    // funcion que contiene los mensajes de alerta para mostrar al usuario 
    private func alertTheUser(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        
    }
    
}
