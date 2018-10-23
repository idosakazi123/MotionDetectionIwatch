//
//  HeartRate.swift
//  MotionDetectionIwatch WatchKit Extension
//
//  Created by Ido Sakazi on 22/10/2018.
//  Copyright © 2018 Ido Sakazi. All rights reserved.
//

import Foundation
import WatchKit
import HealthKit
import UIKit
protocol HeartRateDelegate {
    func heartRateUpdated(heartRateSamples: [HKSample])
}

class HealthKitManager : NSObject{
    
    static let sharedInstance = HealthKitManager()
    
    private override init() {}
    
    
    
    let healthStore = HKHealthStore()
    
    var anchor:HKQueryAnchor?

    var heartRateDelegate : HeartRateDelegate?
    
    func authorizeHealthKit(_ completion: @escaping ((_ success:Bool, _ error: Error?) ->Void)){
        guard let heartRateType : HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else{
         return
        }
        let typesToShare = Set([HKObjectType.workoutType(),heartRateType])
        let typesToRead = Set([HKObjectType.workoutType(),heartRateType])
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        {(success, error) in
            print("Was authorization successful ? \(success)")
            completion(success,error)
        }
    
    }
    
    func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery?{
        
        guard let heartRateType : HKQuantityType = HKQuantityType.quantityType(forIdentifier: .heartRate) else{
            return nil
        }
        
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate])
        
        let heartRateQuery = HKAnchoredObjectQuery(type: heartRateType, predicate: compoundPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) in
            guard let newAnchor = newAnchor,
                let sampleObjects = sampleObjects else{
                    return
            }
            self.anchor = newAnchor
            self.heartRateDelegate?.heartRateUpdated(heartRateSamples: sampleObjects)
        }
        
        heartRateQuery.updateHandler =  { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            guard let newAnchor = newAnchor,
                let sampleObjects = sampleObjects else{
                    return
            }
            self.anchor = newAnchor
            self.heartRateDelegate?.heartRateUpdated(heartRateSamples: sampleObjects)
        }
        return heartRateQuery
        
        
    }
    
    /*
     var heartRateLabel : String = ""
    var healthKitStore  = HKHealthStore()
    
    
    
    
    
    public func subscribeToHeartBeatChanges() {
        
        // Creating the sample for the heart rate
        guard let sampleType: HKSampleType =
            HKObjectType.quantityType(forIdentifier: .heartRate) else {
                return
        }
        
        /// Creating an observer, so updates are received whenever HealthKit’s
        // heart rate data changes.
        let heartRateQuery = HKObserverQuery.init(
            sampleType: sampleType,
            predicate: nil) { [weak self] _, _, error in
                guard error == nil else {
                    print(error!)
                    //log.warn(error!)
                    return
                }
                
                /// When the completion is called, an other query is executed
                /// to fetch the latest heart rate
                self!.fetchLatestHeartRateSample(completion: { sample in
                    guard let sample = sample else {
                        return
                    }
                    
                    /// The completion in called on a background thread, but we
                    /// need to update the UI on the main.
                    DispatchQueue.main.async {
                        
                        /// Converting the heart rate to bpm
                        let heartRateUnit = HKUnit(from: "count/min")
                        let heartRate = sample
                            .quantity
                            .doubleValue(for: heartRateUnit)
                        
                        /// Updating the UI with the retrieved value
                        self!.heartRateLabel = ("\(Int(heartRate))")
                    }
                })
        }
        
    }
    
    public func fetchLatestHeartRateSample(
        completion: @escaping (_ sample: HKQuantitySample?) -> Void) {
        
        /// Create sample type for the heart rate
        guard let sampleType = HKObjectType
            .quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
                completion(nil)
                return
        }
        
        /// Predicate for specifiying start and end dates for the query
        let predicate = HKQuery
            .predicateForSamples(
                withStart: Date.distantPast,
                end: Date(),
                options: .strictEndDate)
        
        /// Set sorting by date.
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false)
        
        /// Create the query
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: Int(HKObjectQueryNoLimit),
            sortDescriptors: [sortDescriptor]) { (_, results, error) in
                
                guard error == nil else {
                    print("Error: \(error!.localizedDescription)")
                    return
                }
                
                completion(results?[0] as? HKQuantitySample)
        }
        
        self.healthKitStore.execute(query)
    }
    
   
    
    public func getHeartRate() -> String{
        return self.heartRateLabel
    }
    */
    
    /*func startRecordingHeartRate() {
        let heartRateSample = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        let datePredicate = HKQuery.predicateForSamples(withStart: Date(), end: nil,
                                                        options: .strictStartDate)
        let anchor: HKQueryAnchor? = nil
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> () = {
            query, newResult, deleted, newAnchor, error in
            
            if let samples = newResult as? [HKQuantitySample] {
                guard samples.count > 0 else {
                    return
                }
                
                for sample in samples {
                    let doubleSample = sample.quantity.doubleValue(for: heartRateUnit)
                    let timeSinceStart = sample.endDate.timeIntervalSince(self.startTime)
                    self.hkHeartRate[0].append(doubleSample)
                    self.hkHeartRate[1].append(Double(timeSinceStart))
                }
                
                self.updateHeartRateLabel()
                self.processData.heartRateArray = self.hkHeartRate
                self.processData.checkData()
            }
        }
        
        let heartRateQuery = HKAnchoredObjectQuery(type: heartRateSample!,
                                                   predicate: datePredicate,
                                                   anchor: anchor,
                                                   limit: Int(HKObjectQueryNoLimit),
                                                   resultsHandler: updateHandler)
        
        heartRateQuery.updateHandler = updateHandler
        healthKitStore.execute(heartRateQuery)
    }*/
    
}
