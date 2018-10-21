//
//  InterfaceController.swift
//  MotionDetectionIwatch WatchKit Extension
//
//  Created by Ido Sakazi on 19/10/2018.
//  Copyright © 2018 Ido Sakazi. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import CoreMotion
import HealthKit


class InterfaceController: WKInterfaceController,WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    var changeIsEating = "START"
    var changeIsNotEAting = "START"
    var motionManager = CMMotionManager()
    var csvString = "\("Time"),\("Acce X"),\("Acce Y"),\("Acce Z"),\("Gyro X"),\("Gyro Y"),\("Gyro Z"),\("Is Eating")\n"
    
    var acceX : Double = 0
    var acceY : Double = 0
    var acceZ : Double = 0
    var gyroX : Double = 0
    var gyroY : Double = 0
    var gyroZ : Double = 0
    var date = Date()
    let interval : Double = 1
    var time = ""
    //var isEating : Bool = true
    
    
    
    let sessionWCS = WCSession.default
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        processApplicationContext()
        
        sessionWCS.delegate = self
        sessionWCS.activate()
    }
    
    
    
    
    @IBOutlet weak var displayLabel: WKInterfaceLabel!
    
    @IBOutlet weak var buttonLabelIsEating: WKInterfaceButton!
    
    
    @IBOutlet weak var buttonLabelNotEating: WKInterfaceButton!
    
    /*
     this function is handle with a session that make the
     iphone, and then i change the label in addition that
     what is change
     */
    func processApplicationContext() {
        if let iPhoneContext = sessionWCS.receivedApplicationContext as? [String : Bool] {
            
            if iPhoneContext["switchStatus"] == true {
                displayLabel.setText("Switch On")
            } else {
                displayLabel.setText("Switch Off")
            }
        }
    }
    
    //this is a quee that keep the things that i do
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async() {
            self.processApplicationContext()
        }
    }
    
    @IBAction func buttonChangeLabelIsEating() {
        if changeIsEating == "START"{
            buttonLabelIsEating.setTitle("STOP EATING")
            changeIsEating = "STOP"
            self.date = Date()
            
            startMotion(isEatingLabel: true)
            
            if sessionWCS.activationState == .activated{
                
                let iWatchAppContext = ["buttonStatus": changeIsEating]
                do {
                    try sessionWCS.updateApplicationContext(iWatchAppContext)
                } catch {
                    print("Something went wrong")
                }
                
            }
        }else {
            buttonLabelIsEating.setTitle("START EATING")
            changeIsEating = "START"
            stopDeviceMotion()
            if sessionWCS.activationState == .activated{
                let iWatchAppContext = ["buttonStatus": changeIsEating,"csvAcceIsEating": self.csvString]
                self.csvString = ""
                self.csvString = "\("Time"),\("Acce X"),\("Acce Y"),\("Acce Z"),\("Gyro X"),\("Gyro Y"),\("Gyro Z"),\("Is Eating")\n"
                do {
                    try sessionWCS.updateApplicationContext(iWatchAppContext)
                } catch {
                    print("Something went wrong")
                }
                
            }
        }
        
        
    }
    
    
    @IBAction func buttonChangeLabelNotEating() {
        if changeIsNotEAting == "START"{
            buttonLabelNotEating.setTitle("STOP IS'T EATING")
            changeIsNotEAting = "STOP"
            self.date = Date()
            
            startMotion(isEatingLabel: false)
            
            if sessionWCS.activationState == .activated{
                
                let iWatchAppContext = ["buttonStatus": changeIsNotEAting]
                do {
                    try sessionWCS.updateApplicationContext(iWatchAppContext)
                } catch {
                    print("Something went wrong")
                }
                
            }
        }else {
            buttonLabelNotEating.setTitle("START IS'T EATING")
            changeIsNotEAting = "START"
            stopDeviceMotion()
            if sessionWCS.activationState == .activated{
                let iWatchAppContext = ["buttonStatus": changeIsNotEAting,"csvAcceIsNotEating": self.csvString]
                self.csvString = ""
                self.csvString = "\("Time"),\("Acce X"),\("Acce Y"),\("Acce Z"),\("Gyro X"),\("Gyro Y"),\("Gyro Z"),\("Is Eating")\n"
                do {
                    try sessionWCS.updateApplicationContext(iWatchAppContext)
                } catch {
                    print("Something went wrong")
                }
                
            }
        }
    }
    
    
    
    
    func stopDeviceMotion(){
        self.motionManager.stopDeviceMotionUpdates()
    }
    
    func startMotion(isEatingLabel: Bool){
        motionManager.deviceMotionUpdateInterval = self.interval
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            if deviceMotion != nil {
                // 1. These strings are to show on the UI. Trying to fit
                // x,y,z values for the sensors is difficult so we’re
                // just going with one decimal point precision.
                /* gravityStr = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                 deviceMotion.gravity.x,
                 deviceMotion.gravity.y,
                 deviceMotion.gravity.z)*/
                self.acceX = deviceMotion!.userAcceleration.x
                self.acceY = deviceMotion!.userAcceleration.y
                self.acceZ =  deviceMotion!.userAcceleration.z
                
                self.gyroX = deviceMotion!.rotationRate.x
                self.gyroY = deviceMotion!.rotationRate.y
                self.gyroZ = deviceMotion!.rotationRate.z
                
                self.time = self.getTime()
                
                
                
                
                print(self.time)
                print("Acceleration X:\(self.acceX) Y:\(self.acceY) Z:\(self.acceZ)")
                print("Gyro X:\(self.gyroX) Y:\(self.gyroY) Z:\(self.gyroZ)")
                self.csvString = self.csvString.appending("\(self.time),\(self.acceX),\(self.acceY),\(self.acceZ),\(self.gyroX),\(self.gyroY),\(self.gyroZ),\(isEatingLabel)\n")
                /*userAccelStr = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                 deviceMotion.userAcceleration.x,
                 deviceMotion.userAcceleration.y,
                 deviceMotion.userAcceleration.z)*/
                
                /*rotationRateStr = String(format: "X: %.1f Y: %.1f Z: %.1f" ,
                 deviceMotion.rotationRate.x,
                 deviceMotion.rotationRate.y,
                 deviceMotion.rotationRate.z)*/
                
                /*attitudeStr = String(format: "r: %.1f p: %.1f y: %.1f" ,
                 deviceMotion.attitude.roll,
                 deviceMotion.attitude.pitch,
                 deviceMotion.attitude.yaw)*/
            }
        }
    }
    
    
    func getTime() -> String{
        self.date += TimeInterval(self.interval)
        let dataFormatter = DateFormatter()
        dataFormatter.calendar = Calendar(identifier: .iso8601)
        dataFormatter.dateFormat = "HH:mm:ss"
        let str = dataFormatter.string(from: self.date)
        return str
    }
    
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
