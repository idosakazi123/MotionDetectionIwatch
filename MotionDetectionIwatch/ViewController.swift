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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        processIwatchContext()
        
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
            do {
                try validSession.updateApplicationContext(iPhoneAppContext)
            } catch {
                print("Something went wrong")
            }
        }
    }
    
    func processIwatchContext() {
        if let iPhoneContext = session?.receivedApplicationContext as? [String : String] {
            
            if iPhoneContext["buttonStatus"] == "START" {
                startLabel.text = "NOT RECORDING"
            } else {
                startLabel.text = "RECORDING"
            }
            
            if let csvString = iPhoneContext["csvAcceIsActivity"] { // take the data from the dictionary
                let fileName = "isActivity"
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
            }
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
    }
    
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async() {
            self.processIwatchContext()
        }
    }


}

