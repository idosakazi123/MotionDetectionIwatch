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
import UIKit




class InterfaceController: WKInterfaceController,WCSessionDelegate{

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    var changeIsActivity = "START"
    var motionManager = CMMotionManager()
    var csvString = "\("Time"),\("Acce X"),\("Acce Y"),\("Acce Z"),\("Gyro X"),\("Gyro Y"),\("Gyro Z"),\("Gravity X"),\("Gravity Y"),\("Gravity Z"),\("Roll"),\("Pitch"),\("Yaw"),\("Heart Rate")\n"
    //var csvString = "\("Time"),\("Acce X"),\("Acce Y"),\("Acce Z"),\("Gyro X"),\("Gyro Y"),\("Gyro Z"),\("Gravity X"),\("Gravity Y"),\("Gravity Z"),\("Roll"),\("Pitch"),\("Yaw"),\("Magnetic Field X"),\("Magnetic Field Y"),\("Magnetic Field Z"),\("Magnetic Field Accuracy"),\("Heart Rate")\n"
    
    var acceX : Double = 0
    var acceY : Double = 0
    var acceZ : Double = 0
    var gyroX : Double = 0
    var gyroY : Double = 0
    var gyroZ : Double = 0
    var gravX : Double = 0
    var gravY : Double = 0
    var gravZ : Double = 0
    var roll : Double = 0
    var pitch : Double = 0
    var yaw : Double = 0
    //var magneticFieldX : Double = 0
    //var magneticFieldY : Double = 0
    //var magneticFieldZ : Double = 0
    //var magneticFieldAccuracy : Double = 0
    
    
    var date = Date()
    let interval : Double = 1/50
    var time = ""
    let healthKitManager = HealthKitManager.sharedInstance
    var workoutSession : HKWorkoutSession?
    
    //var isWorkoutInProgress : Bool = false
    var heartRate : String = ""
    
    var workoutStartDate : Date?
    
    var hearRateQuery : HKQuery?
    
    var heartRateSamples:[HKQuantitySample] = [HKQuantitySample]()
   
    
    let sessionWCS = WCSession.default
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        processApplicationContext()
        healthKitManager.authorizeHealthKit{ (success,error) in
            print("Was healthkit successful? \(success)")
            
            self.createWorkoutSession()
        }
        
        sessionWCS.delegate = self
        sessionWCS.activate()
    }

    
    @IBOutlet weak var displayLabel: WKInterfaceLabel!
    
    @IBOutlet weak var buttonLabelIsEating: WKInterfaceButton!
    
    
   
    
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
        if changeIsActivity == "START"{
            buttonLabelIsEating.setTitle("STOP ACTIVITY")
            changeIsActivity = "STOP"
            self.date = Date()
            
            //UIApplication.shared.isIdleTimerDisabled = true
            startWorkoutSession()
            
            startMotion(isEatingLabel: true)
            
            
            if sessionWCS.activationState == .activated{
                
                let iWatchAppContext = ["buttonStatus": changeIsActivity]
                do {
                    try sessionWCS.updateApplicationContext(iWatchAppContext)
                } catch {
                    print("Something went wrong")
                }
                
            }
        }else {
            buttonLabelIsEating.setTitle("START ACTIVITY")
            changeIsActivity = "START"
            stopDeviceMotion()
            endWorkoutSession()
            self.workoutSession = nil
            
            if sessionWCS.activationState == .activated{
                let iWatchAppContext = ["buttonStatus": changeIsActivity,"csvAcceIsActivity": self.csvString]
                self.csvString = ""
                self.csvString = "\("Time"),\("Acce X"),\("Acce Y"),\("Acce Z"),\("Gyro X"),\("Gyro Y"),\("Gyro Z"),\("Gravity X"),\("Gravity Y"),\("Gravity Z"),\("Roll"),\("Pitch"),\("Yaw"),\("Heart Rate")\n"
                do {
                    print("send it")
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
        motionManager.showsDeviceMovementDisplay = true
        
        /*motionManager.startMagnetometerUpdates(to: OperationQueue.current!) { (magnetometer :CMMagnetometerData?, error:Error?) in
            self.magneticFieldX = magnetometer!.magneticField.x
            self.magneticFieldY = magnetometer!.magneticField.y
            self.magneticFieldZ = magnetometer!.magneticField.z
            print("Magnetic x:\(self.magneticFieldX) y:\(self.magneticFieldY)  z:\(self.magneticFieldZ) ")
        }*/
  
    
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
                self.motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical)
                //accelerometer
                self.acceX = deviceMotion!.userAcceleration.x
                self.acceY = deviceMotion!.userAcceleration.y
                self.acceZ =  deviceMotion!.userAcceleration.z
                
                //Gyroscope
                self.gyroX = deviceMotion!.rotationRate.x
                self.gyroY = deviceMotion!.rotationRate.y
                self.gyroZ = deviceMotion!.rotationRate.z
                
                //gravity
                self.gravX = deviceMotion!.gravity.x
                self.gravY = deviceMotion!.gravity.y
                self.gravZ = deviceMotion!.gravity.z
                
                //Attitude
                self.roll = deviceMotion!.attitude.roll
                self.pitch = deviceMotion!.attitude.pitch
                self.yaw = deviceMotion!.attitude.yaw
                
                //magneticfield
                //In the apple watch i can't get the magnetic field if you need it you need to use core location use link below
                //https://stackoverflow.com/questions/15380632/in-ios-what-is-the-difference-between-the-magnetic-field-values-from-the-core-l/15470571#15470571
                /*self.magneticFieldX = deviceMotion!.magneticField.field.x
                self.magneticFieldY = deviceMotion!.magneticField.field.y
                self.magneticFieldZ = deviceMotion!.magneticField.field.z
                self.magneticFieldAccuracy = Double(deviceMotion!.magneticField.accuracy.rawValue)
                 print(self.motionManager.isMagnetometerAvailable)
                 print(self.time)
                 print("Magnetic x:\(self.magneticFieldX) y:\(self.magneticFieldY)  z:\(self.magneticFieldZ) ")
                 
                 */
            
                
                //get time
                self.time = self.getTime()
               
                print(self.heartRate)
                print("Acceleration X:\(self.acceX) Y:\(self.acceY) Z:\(self.acceZ)")
                print("Gyro X:\(self.gyroX) Y:\(self.gyroY) Z:\(self.gyroZ)")
                self.csvString = self.csvString.appending("\(self.time),\(self.acceX),\(self.acceY),\(self.acceZ),\(self.gyroX),\(self.gyroY),\(self.gyroZ),\(self.gravX),\(self.gravY),\(self.gravZ),\(self.roll),\(self.pitch),\(self.yaw),\(self.heartRate)\n")
                
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
    
    func createWorkoutSession(){
        
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other
        workoutConfiguration.locationType = .unknown
        do{
            self.workoutSession =  try HKWorkoutSession(healthStore: healthKitManager.healthStore, configuration: workoutConfiguration)
            workoutSession?.delegate = self
        }catch{
            print("Exception throw")
        }
        
    }
    
    func startWorkoutSession(){
        if self.workoutSession == nil{
            createWorkoutSession()
        }
        guard let session = workoutSession else{
            print("Cannot start a workout without a workout session")
            return
        }
        healthKitManager.healthStore.start(session)
        self.workoutStartDate = Date()
    }
    
    func endWorkoutSession() {
        guard let session = workoutSession else{
            print("Cannot start a workout without a workout session")
            return
        }
         healthKitManager.healthStore.end(session)
        saveWorkout()
    }
    
    
    func saveWorkout(){
        guard let startDate = workoutStartDate else {
            return
        }
        let workout = HKWorkout(activityType: .other, start: startDate, end: Date())
        
        healthKitManager.healthStore.save(workout) {[weak self] (success, error) in
            print("Was saveworkout successful? \(success)")
            guard let samples = self?.heartRateSamples else{
                return
            }
            
            self?.healthKitManager.healthStore.add(samples, to: workout, completion: { (success, error) in
                if success{
                    print("Successfully saved heart rate samples.")
                }
            })
        }
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

extension InterfaceController: HKWorkoutSessionDelegate{
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout failed with error: \(error)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState{
        case.running:
            print("workout started")
            guard let workoutStartDate = workoutStartDate else {
                return
            }
            if let query = healthKitManager.createHeartRateStreamingQuery(workoutStartDate){
                self.hearRateQuery = query
                self.healthKitManager.heartRateDelegate = self
                healthKitManager.healthStore.execute(query)
            }
        case.ended:
            print("workout ended")
            if let query = self.hearRateQuery{
                healthKitManager.healthStore.stop(query)
            }
        default:
            print("Other workout state")
        }
    }
}

extension InterfaceController : HeartRateDelegate{
    func heartRateUpdated(heartRateSamples: [HKSample]) {
        guard let heartRateSamples = heartRateSamples as?  [HKQuantitySample] else {
            return
        }
        
        DispatchQueue.main.async {
            self.heartRateSamples = heartRateSamples
            guard let sample = heartRateSamples.first else {
                return
            }
            
            let heartRateUnit = HKUnit(from: "count/min")
            let value = sample
                .quantity
                .doubleValue(for: heartRateUnit)
            //let value = sample.quantity.doubleValue(for: HKUnit(form: "count/min"))
            let heartRateString = String(format: "%.00f", value)
            self.heartRate = heartRateString
        }
    }
}
