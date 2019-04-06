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
    var csvString = ""
    struct DataCollection {
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
    }
    
    
    let semaphore = DispatchSemaphore(value: 1)
    var date = Date()
    var checkDate = Date()
    let interval : Double = 1/10
    var sendInterval = 0;
    //var stillRunning = false;
    let healthKitManager = HealthKitManager.sharedInstance
    var workoutSession : HKWorkoutSession?
    var time = ""
    
    var takeTime = ""
    
    var checkTime = ""
    
    var stopTimer = ""
    
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
    
    
    func processApplicationContext() {
        if let iPhoneContext = sessionWCS.receivedApplicationContext as? [String : Bool] {
            if iPhoneContext["switchStatus"] == true{
                displayLabel.setText("Switch On")
            } else {
                displayLabel.setText("Switch Off")
            }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async() {
            self.processApplicationContext()
        }
    }
    
    
    @IBAction func buttonChangeLabelIsEating() {
        if changeIsActivity == "START"{
            buttonLabelIsEating.setTitle("STOP ACTIVITY")
            changeIsActivity = "STOP"
            //self.stillRunning = false
            self.csvString = ""
            self.date = Date()
            
            //UIApplication.shared.isIdleTimerDisabled = true
            //DispatchQueue.main.async{
            
                self.startWorkoutSession()
                
                self.startMotion(isEatingLabel: true) //need to check outside the main thread
            
           
            //}
           
            
            
            
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
            
            self.stopTimer = self.getCurrentTime();
           
            
            /*if self.sessionWCS.activationState == .activated{
                let iWatchAppContext = ["buttonStatus": self.changeIsActivity]
                self.csvString = ""
                do {
                    try self.sessionWCS.updateApplicationContext(iWatchAppContext)
                } catch {
                    print("Something went wrong")
                }
                
            }*/
            DispatchQueue.global(qos: .utility).async {
                //self.checkDate = self.date
                self.semaphore.wait()
                self.checkTime = self.time
                self.semaphore.signal()
                while(!self.stopTimer.elementsEqual(self.checkTime) ){
                    //self.endWorkoutSession()
                    //self.workoutSession = nil
                    //self.startWorkoutSession()
                    
                    //self.startMotion(isEatingLabel: true)
                    //self.checkTime = self.getCheckTime()
                    self.semaphore.wait()
                    self.checkTime = self.time
                    self.semaphore.signal()
                    print("stopTimer: \(self.stopTimer)")
                    print("selfTimer: \(self.checkTime)")
                }
            
                self.stopDeviceMotion()
            
                self.endWorkoutSession()
                
                self.workoutSession = nil
            
            
                self.changeIsActivity = "START"
                if self.sessionWCS.activationState == .activated && self.workoutSession == nil{
                    let iWatchAppContext = ["buttonStatus": self.changeIsActivity,"csvAcceIsActivity": ""]
                    //self.csvString = ""
                    do {
                        try self.sessionWCS.updateApplicationContext(iWatchAppContext)
                        print("Send All")
                    } catch {
                        print("Something went wrong")
                    }
                    
                }
                
           }
      
            /*if self.sessionWCS.activationState == .activated{
                let iWatchAppContext = ["buttonStatus": self.changeIsActivity,"csvAcceIsActivity": self.csvString]
                self.csvString = ""
                do {
                    try self.sessionWCS.updateApplicationContext(iWatchAppContext)
                    print("Send All1")
                } catch {
                    print("Something went wrong")
                }
                
            }*/
            
            
            /*if sessionWCS.activationState == .activated{
               //let size = self.csvString.utf8.count
                //print(size)
                let iWatchAppContext = ["buttonStatus": changeIsActivity,"csvAcceIsActivity": self.csvString]
                
                do {
                    print("send it")
                    try sessionWCS.updateApplicationContext(iWatchAppContext)
                    self.csvString = ""
                    self.csvString = "\("Time"),\("Acce X"),\("Acce Y"),\("Acce Z"),\("Gyro X"),\("Gyro Y"),\("Gyro Z"),\("Gravity X"),\("Gravity Y"),\("Gravity Z"),\("Roll"),\("Pitch"),\("Yaw"),\("Heart Rate")\n"
                    //self.actualCsvString = ""
                } catch {
                    print("Something went wrong")
                }
                
            }*/
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
                
                //In this variable we insert the data from the sensors accelerometer ,Gyroscope ,gravity , and Attitude
                let dataCollection = DataCollection(acceX: deviceMotion!.userAcceleration.x, acceY: deviceMotion!.userAcceleration.y, acceZ: deviceMotion!.userAcceleration.z, gyroX: deviceMotion!.rotationRate.x, gyroY: deviceMotion!.rotationRate.y, gyroZ: deviceMotion!.rotationRate.z, gravX: deviceMotion!.gravity.x, gravY: deviceMotion!.gravity.y, gravZ: deviceMotion!.gravity.z, roll: deviceMotion!.attitude.roll, pitch: deviceMotion!.attitude.pitch, yaw: deviceMotion!.attitude.yaw)
                
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
                self.semaphore.wait()
                self.time = self.getTime()
                self.takeTime = self.time
                self.semaphore.signal()
                //print(self.heartRate)
                print("collect sensors in motionManager: " + "\(self.takeTime)")
                print("Acceleration X:\(dataCollection.acceX) Y:\(dataCollection.acceY) Z:\(dataCollection.acceZ)")
                //print("Gyro X:\(self.gyroX) Y:\(self.gyroY) Z:\(self.gyroZ)")
            self.csvString.append("\(self.takeTime),\(dataCollection.acceX),\(dataCollection.acceY),\(dataCollection.acceZ),\(dataCollection.gyroX),\(dataCollection.gyroY),\(dataCollection.gyroZ),\(dataCollection.gravX),\(dataCollection.gravY),\(dataCollection.gravZ),\(dataCollection.roll),\(dataCollection.pitch),\(dataCollection.yaw),\(self.heartRate)\n")
                
                self.sendInterval += 1;
                
                if(self.sendInterval == 10){
                    let iWatchAppContext = ["buttonStatus": self.changeIsActivity,"csvAcceIsActivity": self.csvString]
                    
                    do {
                        print("send it")
                        try self.sessionWCS.updateApplicationContext(iWatchAppContext)
                        self.csvString = ""
                        self.sendInterval = 0;
                    } catch {
                        print("Something went wrong")
                    }
                }
               /*if(self.stillRunning){
                    let iWatchAppContext = ["csvAcceIsActivity": self.csvString]
                    do {
                        print("send it")
                        try self.sessionWCS.updateApplicationContext(iWatchAppContext)
                        self.csvString = ""
                        self.sendInterval = 0;
                    } catch {
                        print("Something went wrong")
                    }
                }*/
                
                
                /*if self.sessionWCS.activationState == .activated{
                    //let size = self.csvString.utf8.count
                    //print(size)
                    let sendMessage  = "STOP"
                    self.csvString = "\(self.time),\(self.acceX),\(self.acceY),\(self.acceZ),\(self.gyroX),\(self.gyroY),\(self.gyroZ),\(self.gravX),\(self.gravY),\(self.gravZ),\(self.roll),\(self.pitch),\(self.yaw),\(self.heartRate)\n"
                    let iWatchAppContext = ["buttonStatus": sendMessage,"csvAcceIsActivity": self.csvString]
                    
                    do {
                        print("send it")
                        try self.sessionWCS.updateApplicationContext(iWatchAppContext)
                        self.csvString = ""
                        /*self.csvString = "\("Time"),\("Acce X"),\("Acce Y"),\("Acce Z"),\("Gyro X"),\("Gyro Y"),\("Gyro Z"),\("Gravity X"),\("Gravity Y"),\("Gravity Z"),\("Roll"),\("Pitch"),\("Yaw"),\("Heart Rate")\n"*/
                        //self.actualCsvString = ""
                    } catch {
                        print("Something went wrong")
                    }
                    
                }*/
                
                /*
                self.csvString = self.csvString.appending("\(self.time),\(self.acceX),\(self.acceY),\(self.acceZ),\(self.gyroX),\(self.gyroY),\(self.gyroZ),\(self.gravX),\(self.gravY),\(self.gravZ),\(self.roll),\(self.pitch),\(self.yaw),\(self.heartRate)\n")
                */
                
                
            }
        }
    }
    
   /*@objc func sendTo(){
        
        if self.sessionWCS.activationState == .activated{
            //let size = self.csvString.utf8.count
            //print(size)
            DispatchQueue.main.async {
                let sendMessage  = "STOP"
                /*self.csvString = "\(self.time),\(self.acceX),\(self.acceY),\(self.acceZ),\(self.gyroX),\(self.gyroY),\(self.gyroZ),\(self.gravX),\(self.gravY),\(self.gravZ),\(self.roll),\(self.pitch),\(self.yaw),\(self.heartRate)\n"*/
                let iWatchAppContext = ["buttonStatus": sendMessage,"csvAcceIsActivity": self.csvString]
                
                do {
                    print("send it")
                    try self.sessionWCS.updateApplicationContext(iWatchAppContext)
                    self.csvString = ""
                    /*self.csvString = "\("Time"),\("Acce X"),\("Acce Y"),\("Acce Z"),\("Gyro X"),\("Gyro Y"),\("Gyro Z"),\("Gravity X"),\("Gravity Y"),\("Gravity Z"),\("Roll"),\("Pitch"),\("Yaw"),\("Heart Rate")\n"*/
                    //self.actualCsvString = ""
                } catch {
                    print("Something went wrong")
                }
            }
            
        }
    }*/
    
    func getTime() -> String{
        self.date += TimeInterval(self.interval)
        let dataFormatter = DateFormatter()
        dataFormatter.calendar = Calendar(identifier: .iso8601)
        dataFormatter.dateFormat = "HH:mm:ss"
        let str = dataFormatter.string(from: self.date)
        return str
    }
    
    
    func getCheckTime() -> String{
        self.checkDate += TimeInterval(self.interval)
        let dataFormatter = DateFormatter()
        dataFormatter.calendar = Calendar(identifier: .iso8601)
        dataFormatter.dateFormat = "HH:mm:ss"
        let str = dataFormatter.string(from: self.checkDate)
        return str
    }
    
    func getCurrentTime() -> String{
        let currentDate = Date()
        let dataFormatter = DateFormatter()
        dataFormatter.calendar = Calendar(identifier: .iso8601)
        dataFormatter.dateFormat = "HH:mm:ss"
        let str = dataFormatter.string(from: currentDate)
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
        self.workoutStartDate = Date()
        healthKitManager.healthStore.start(session)
        //was here before
        
        //session.startActivity(with: self.workoutStartDate)
    }
    
    func endWorkoutSession() {
        guard let session = workoutSession else{
            print("Cannot start a workout without a workout session")
            return
        }
        //healthKitManager.healthStore.end(session)
        //workoutStartDate was not here before
        //self.workoutStartDate = Date()
        //session.stopActivity(with: self.workoutStartDate)
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
