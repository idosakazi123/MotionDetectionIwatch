//
//  ViewController.swift
//  MotionDetectionIwatch
//
//  Created by Ido Sakazi on 19/10/2018.
//  Copyright © 2018 Ido Sakazi. All rights reserved.
//

import UIKit
import WatchConnectivity


class ViewController: UIViewController,WCSessionDelegate {

    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    //private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    var session: WCSession?
    
    let healthKitManager = HealthKitManager.sharedInstance
    
    var fileURL : URL!
    var date = Date()
    var interval = 1/50
    var time = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let fileName = "isActivity"
        //let fileManager = FileManager.default
        let path = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        fileURL = path.appendingPathComponent(fileName).appendingPathExtension("csv")
        let csvString = "\("Time"),\("Acce_X"),\("Acce_Y"),\("Acce_Z"),\("Gyro_X"),\("Gyro_Y"),\("Gyro_Z"),\("Gravity_X"),\("Gravity_Y"),\("Gravity_Z"),\("Roll"),\("Pitch"),\("Yaw"),\("Heart_Rate")\n"
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError{
            print(error)
        }
        print("FilePath: \(fileURL.path)")
        
        processIwatchContext()
        
        //sendTimeToWatch()
        
        if WCSession.isSupported() {
            self.session = WCSession.default
            self.session?.delegate = self
            self.session?.activate()
        }
        
        healthKitManager.authorizeHealthKit{ (success,error) in
            print("Was healthkit successful? \(success)")
        }
    }
    
    
    @IBOutlet weak var startLabel: UILabel!
    
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        print("\(self.session!)")
        
        if let validSession = session{
            
            let iPhoneAppContext = ["switchStatus": sender.isOn]
            print("\(iPhoneAppContext)")
            self.time = getTime()
            print(self.time)
            do {
                try validSession.updateApplicationContext(iPhoneAppContext)
            } catch {
                print("Something went wrong")
            }
            
        }
    }
    
    
    /*func sendTimeToWatch(){
        if let validSession = session{
            if !self.time.isEmpty{
                let iPhoneAppContext = ["timeInIphone": self.time]
                do {
                    try validSession.updateApplicationContext(iPhoneAppContext)
                    self.time = ""
                    print("send the time");
                } catch {
                    print("Something went wrong")
                }
                
            }
        }
    }*/
    
    
    let fileManager = FileManager.default
    
    
    func processIwatchContext() {
        if let iPhoneContext = session?.receivedApplicationContext as? [String : String] {
            
            if iPhoneContext["buttonStatus"] == "START" {
                startLabel.text = "NOT RECORDING"
                //self.time = getTime()
                //print(self.time)
                //self.sendTimeToWatch()
            } else {
                startLabel.text = "RECORDING"
            }
            if let csvString = iPhoneContext["csvAcceIsActivity"] { // take the data from the dictionary
                do{
                    let fileHandle = try FileHandle(forWritingTo: fileURL)
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(csvString.data(using: .utf8)!)
                    fileHandle.closeFile()
                } catch let error as NSError{
                    print("Failed to write to URL")
                    print(error)
                }
            }
        }
    }
    
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async() {
            self.processIwatchContext()
        }
    }
    
    func getTime() -> String{
        self.date = Date()
        let dataFormatter = DateFormatter()
        dataFormatter.calendar = Calendar(identifier: .iso8601)
        dataFormatter.dateFormat = "HH:mm:ss"
        let str = dataFormatter.string(from: self.date)
        return str
    }
    
    /*func writeFile(writeString:String, to_fileName:String ,fileExtension:String = "csv",path:URL){
        do{
            let fileURL = path.appendingPathComponent(to_fileName).appendingPathExtension(fileExtension)
            print("FilePath: \(fileURL.path)")
            try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError{
            print("Failed to write to URL")
            print(error)
        }
    }*/
    
    /*let path = try self.fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
     self.writeFile(writeString: csvString, to_fileName:fileName,path:path)*/
    /*if let csvString = iPhoneContext["csvAcceIsNotEating"] { // take the data from the dictionary
     let fileName = "isNotEating"
     let fileManager = FileManager.default
     do{
     let path = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
     let fileURL = path.appendingPathComponent(fileName).appendingPathExtension("csv")
     print("FilePath: \(fileURL.path)")
     try csvString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
     } catch let error as NSError{
     print("Failed to write to URL")
     print(error)
     }
     }*/


}

