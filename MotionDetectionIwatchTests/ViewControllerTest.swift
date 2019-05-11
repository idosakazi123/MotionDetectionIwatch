//
//  ViewControllerTest.swift
//  MotionDetectionIwatchTests
//
//  Created by Ido Sakazi on 14/04/2019.
//  Copyright © 2019 Ido Sakazi. All rights reserved.
//

import Foundation
import XCTest
import UIKit
import WatchConnectivity
@testable import MotionDetectionIwatch

class ViewControllerTest: XCTestCase,WCSessionDelegate  {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    var session: WCSession?
    
    
    func testProcessIwatchContext() {
        let vc = ViewController()
        vc.processIwatchContext()
        XCTAssertTrue(true)
    }
    
    func testswitchValueChanged() {
        if WCSession.isSupported() {
            self.session = WCSession.default
            self.session?.delegate = self
            self.session?.activate()
            let vc = ViewController()
            vc.sessionDidBecomeInactive(self.session!)
            vc.sessionDidDeactivate(self.session!)
            XCTAssertTrue(true)
        }
        
    }
    
    func testGetTime(){
        let vc = ViewController()
        vc.viewDidLoad()
        XCTAssertTrue(true)
    }
    
    


}
