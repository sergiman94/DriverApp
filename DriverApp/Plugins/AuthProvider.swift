//
//  AuthProvider.swift
//  DriverApp
//
//  Created by Sergio Manrique on 1/18/18.
//  Copyright © 2018 smm. All rights reserved.
//
/*
 Esta clase contiene las autenticaciones de las cuentas ligadas a la base de datos
 de firebase, sus verificaciones y demás.
*/

import Foundation
import FirebaseAuth

// Handler que contiene los mensajes al momento de ingresar a la aplicacion
typealias LoginHandler = (_ msg: String?) -> Void

// Estructura que contiene los distintos errores que pueden mostrarse en la autenticacion,
// registro o ingreso a la aplicacion
struct LoginErrorCode {
    
    static let INVALID_EMAIL = "Invalid Email Adress, Please Provide A Real Email Adress"
    static let WRONG_PASSWORD = "Wrong Paswword, Please Enter The Correct Password"
    static let PROBLEM_CONNECTING = "Problem Connecting To Database"
    static let USER_NOT_FOUND = "User Not Found, Please Register"
    static let EMAIL_ALREADY_IN_USE = "Email Already In Use, Please Use Another Email"
    static let WEAK_PASSWORD = "Password Should Be At Least 6 Characters Long"
    
}

class AuthProvider{
    
    private static var _instance = AuthProvider()
    
    static var Instance: AuthProvider {
        return _instance
    }
    
    // Funcion que gestiona el ingreso del ususario a la aplicacion
    func login (withEmail: String, password: String, loginHandler: LoginHandler? ){
        
        Auth.auth().signIn(withEmail: withEmail, password: password) { (user, error) in
            
            if error != nil {
                // si EXISTE un error
                
                self.handlerErrors(err: error! as NSError, loginHandler: loginHandler)
                
            }else{
                // si NO EXISTE un error
                loginHandler?(nil)
            }
            
        }
        
    }
    
    //Funcion que gestiona el registro del usuario otrogando una clave automatica
    func signUp(withEmail: String, password: String, loginHandler: LoginHandler?){
        
        Auth.auth().createUser(withEmail: withEmail, password: password) { (user, error) in
            
            if error != nil{
                // EXISTE un error
                self.handlerErrors(err: error! as NSError, loginHandler: loginHandler)
            }else{
                // NO EXISTE un error
                if user?.uid != nil {
                    
                    // store the user to database
                    // se guarda el usuario en la base de datos
                     DBProvider.Instance.saveUser(withID: user!.uid, email: withEmail, password: password)
                    
                    // login the user
                    // automaticamente despues de registrarse se ingresa el usuario
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler)
                }
            }
            
        }
        
    }
    
    // Funcion que cierra la sesion del usuario
    func logOut() -> Bool{
        
        if Auth.auth().currentUser != nil {
            
            do {
                try Auth.auth().signOut()
                return true
            }catch{
                return false
            }
        }
        return true
    }
    
    // Funcion que contiene los distintos errores que pueden aparecer en el momento de autenticacion del usuario
    private func handlerErrors(err: NSError, loginHandler: LoginHandler? ){
        
        if let errCode = AuthErrorCode(rawValue: err.code) {
            
            switch errCode {
                
            case .wrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD)
                break
                
            case .invalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL)
                break
                
            case .userNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND)
                break
                
            case .emailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE)
                break
                
            case .weakPassword:
                loginHandler?(LoginErrorCode.WEAK_PASSWORD)
                break
                
            default:
                loginHandler?(LoginErrorCode.PROBLEM_CONNECTING)
                break
                
            }
        }
        
    }
    
}
