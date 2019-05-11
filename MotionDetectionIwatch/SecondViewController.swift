//
//  SecondViewController.swift
//  MotionDetectionIwatch
//
//  Created by Ido Sakazi on 11/05/2019.
//  Copyright © 2019 Ido Sakazi. All rights reserved.
//

import UIKit
import CoreML

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    var readStringProject = ""
    var strArr : [String]?
    @IBOutlet weak var predictionInProgress: UILabel!
    
    @IBOutlet weak var showPredictionTextView: UITextView!
    
    func createModel(arr : Array<[Double]>, arrTime : Array<[String]>) -> String{
        
        let options = MLPredictionOptions()
        options.usesCPUOnly = true
        let model = HARClassifier()
        
        
        
        // Upstairs example data set (already preprocessed (copy&paste from Python)
        //var accelerationUpstairs : [Double] = [-0.0266,-0.1994,0.3533,0.2143,0.0503,-0.0251,0.0621]
        
        // Jogging example data set (already preprocessed (copy&paste from Python)
        //var accelerationJogging : [Double] = [-0.0348,0.2512,-0.0148,0.2409,0.0621,-0.1478,0.4597]
        
        // Populates the mlMultiArrayInput with all values from the example data set (conversion to NSNumber necessary)
        print("segment array: " + "\(arr)")
        print("array time: " + "\(arrTime)")
        print("the size of segments" + "\(arr.count)")
        var i = 0
        var j = 3
        var writeToTextView : String = ""
        var predict : Array<String>
        var predictString : String = ""
        var predictArr = [String]()
        var predictArrForTime = [String]()
        
        
        //var predictionSegmentsTime = [String:[String]]()
        for segment in arr {
            //print("\(segment.count)" + "ido")
            // This array will hold the input data (40x13 = 520 entries for x,y, and z acceleration data
            let mlMultiArrayInput = try? MLMultiArray(shape:[520], dataType:MLMultiArrayDataType.double)
            let segmentD : [Double] = segment
            for (index, element) in segmentD.enumerated() {
                mlMultiArrayInput![index] = NSNumber(floatLiteral: element)
                // Make predictions and output the result
            }
            //print(i)
            
            let prediction = try? model.prediction(input: HARClassifierInput(acceleration: mlMultiArrayInput!),options: options)
            //print(prediction!.classLabel)'
            predictArr.append(prediction!.classLabel)
            if(j == 3){
                i += 1
                predictArrForTime.append(prediction!.classLabel)
                if(predictArrForTime.count % 7 == 0){
                    print(predictArrForTime)
                    var counts : [String:Int] = predictArrForTime.reduce(into: [:]){ counts, words in counts[words, default: 0] += 1 }
                    let max = counts.values.max()!
                    counts = counts.filter{$0.1 == max}
                    print(counts)
                    predict = Array(counts.keys)
                    predictString = predict[0]
                    let firstTimeArr = arrTime[i-7][0]
                    let lastTimeArr = arrTime[i-1][1]
                    //predictionSegmentsTime.Add([firstTimeArr:lastTimeArr], forKey: predict)
                    print("prediction: " + "\(predictString)" + ", " + "time: " + "\(firstTimeArr)" + " - " + "\(lastTimeArr)\n")
                    writeToTextView.append( "Time: " + "\(firstTimeArr)" + " - " + "\(lastTimeArr)" + ", " + "Prediction: " + "\(predictString)\n")
                    predictArrForTime = []
                    j=0
                }
            }else{
                j += 1
                i += 1
            }
            //var firstTimeArr = arrTime[0][0]
            //print(firstTimeArr)
            
            
            
            /*print("Predicted label:")
             print(prediction?.classLabel ?? "No prediction possible")
             /*if(prediction?.classLabel.elementsEqual("Eating")){
             
             }else if(prediction?.classLabel.elementsEqual("Eating")){
             
             }*/
             print("Probability per label:")
             print(prediction?.output ?? "No prediction possible")
             */
        }
        
        print(predictArr)
        if(predictArrForTime.count > 0){
            if(predictArrForTime.count == 1){
                var counts : [String:Int] = predictArrForTime.reduce(into: [:]){ counts, words in counts[words, default: 0] += 1 }
                let max = counts.values.max()!
                counts = counts.filter{$0.1 == max}
                print(counts)
                predict = Array(counts.keys)
                predictString = predict[0]
                let firstTimeArr = arrTime[arr.count-1][0]
                let lastTimeArr = arrTime[arr.count-1][1]
                print("prediction: " + "\(predictString)" + ", " + "time: " + "\(firstTimeArr)" + " - " + "\(lastTimeArr)")
                writeToTextView.append( "Time: " + "\(firstTimeArr)" + " - " + "\(lastTimeArr)" + ", " + "Prediction: " + "\(predictString)\n")
                //predictionSegmentsTime.updateValue([firstTimeArr:lastTimeArr], forKey: predict)
                predictArrForTime = []
            }else if(predictArrForTime.count == 2){
                var counts : [String:Int] = predictArrForTime.reduce(into: [:]){ counts, words in counts[words, default: 0] += 1 }
                let max = counts.values.max()!
                counts = counts.filter{$0.1 == max}
                print(counts)
                predict = Array(counts.keys)
                predictString = predict[0]
                let firstTimeArr = arrTime[arr.count-2][0]
                let lastTimeArr = arrTime[arr.count-1][1]
                print("prediction: " + "\(predictString)" + ", " + "time: " + "\(firstTimeArr)" + " - " + "\(lastTimeArr)")
                writeToTextView.append( "Time: " + "\(firstTimeArr)" + " - " + "\(lastTimeArr)" + ", " + "Prediction: " + "\(predictString)\n")
                //predictionSegmentsTime.updateValue([firstTimeArr:lastTimeArr], forKey: predict)
                predictArrForTime = []
            }else if(predictArrForTime.count == 3){
                var counts : [String:Int] = predictArrForTime.reduce(into: [:]){ counts, words in counts[words, default: 0] += 1 }
                let max = counts.values.max()!
                counts = counts.filter{$0.1 == max}
                print(counts)
                predict = Array(counts.keys)
                predictString = predict[0]
                let firstTimeArr = arrTime[arr.count-3][0]
                let lastTimeArr = arrTime[arr.count-1][1]
                print("prediction: " + "\(predictString)" + ", " + "time: " + "\(firstTimeArr)" + " - " + "\(lastTimeArr)")
                writeToTextView.append( "Time: " + "\(firstTimeArr)" + " - " + "\(lastTimeArr)" + ", " + "Prediction: " + "\(predictString)\n")
                //predictionSegmentsTime.updateValue([firstTimeArr:lastTimeArr], forKey: predict)
                predictArrForTime = []
            }else if(predictArrForTime.count == 4){
                var counts : [String:Int] = predictArrForTime.reduce(into: [:]){ counts, words in counts[words, default: 0] += 1 }
                let max = counts.values.max()!
                counts = counts.filter{$0.1 == max}
                print(counts)
                predict = Array(counts.keys)
                predictString = predict[0]
                let firstTimeArr = arrTime[arr.count-4][0]
                let lastTimeArr = arrTime[arr.count-1][1]
                print("prediction: " + "\(predictString)" + ", " + "time: " + "\(firstTimeArr)" + " - " + "\(lastTimeArr)")
                writeToTextView.append( "Time: " + "\(firstTimeArr)" + " - " + "\(lastTimeArr)" + ", " + "Prediction: " + "\(predictString)\n")
                //predictionSegmentsTime.updateValue([firstTimeArr:lastTimeArr], forKey: predict)
                predictArrForTime = []
            }else if(predictArrForTime.count == 5){
                var counts : [String:Int] = predictArrForTime.reduce(into: [:]){ counts, words in counts[words, default: 0] += 1 }
                let max = counts.values.max()!
                counts = counts.filter{$0.1 == max}
                print(counts)
                predict = Array(counts.keys)
                predictString = predict[0]
                let firstTimeArr = arrTime[arr.count-5][0]
                let lastTimeArr = arrTime[arr.count-1][1]
                print("prediction: " + "\(predictString)" + ", " + "time: " + "\(firstTimeArr)" + " - " + "\(lastTimeArr)")
                writeToTextView.append( "Time: " + "\(firstTimeArr)" + " - " + "\(lastTimeArr)" + ", " + "Prediction: " + "\(predictString)\n")
                //predictionSegmentsTime.updateValue([firstTimeArr:lastTimeArr], forKey: predict)
                predictArrForTime = []
            }else if(predictArrForTime.count == 6){
                var counts : [String:Int] = predictArrForTime.reduce(into: [:]){ counts, words in counts[words, default: 0] += 1 }
                let max = counts.values.max()!
                counts = counts.filter{$0.1 == max}
                print(counts)
                predict = Array(counts.keys)
                predictString = predict[0]
                let firstTimeArr = arrTime[arr.count-6][0]
                let lastTimeArr = arrTime[arr.count-1][1]
                print("prediction: " + "\(predictString)" + ", " + "time: " + "\(firstTimeArr)" + " - " + "\(lastTimeArr)")
                writeToTextView.append( "Time: " + "\(firstTimeArr)" + " - " + "\(lastTimeArr)" + ", " + "Prediction: " + "\(predictString)\n")
                //predictionSegmentsTime.updateValue([firstTimeArr:lastTimeArr], forKey: predict)
                predictArrForTime = []
            }
        }
        
        var counts = predictArr.reduce(into: [:]){ counts, words in counts[words, default: 0] += 1 }
        print(counts)
        let max = counts.values.max()!
        counts = counts.filter{$0.1 == max}
        print(counts)
        //print(predictionSegmentsTime)
        
        
        /*for (index, element) in arr.enumerated() {
         mlMultiArrayInput![index] = NSNumber(floatLiteral: element)
         i += 1
         print(i)
         }*/
        
        return writeToTextView
        
    }
    
    func readFile() -> String{
        // File location
        //let fileURLProject = Bundle.main.path(forResource: "shayIsEating10", ofType: "csv")
        var fileURLProject : String?
         if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
         
         let fileURL = dir.appendingPathComponent("isActivityApple.csv")
         
         //reading
         do {
         fileURLProject = try String(contentsOf: fileURL, encoding: .utf8)
         print(fileURLProject as! String)
         }
         catch {/* error handling here */}
         }
        if(fileURLProject == nil){
            // Alert: textField is empty!
            return "No File"
        }else{
            // Read from the file
            //var str = ""
            /*do {
                str = try String(contentsOfFile: fileURLProject!, encoding: String.Encoding.utf8)
                
            } catch let error as NSError {
                print("Failed reading from URL")
                print(error)
            }*/
            //str = fileURLProject?
            return fileURLProject!
        }
        
        
    }
    
    func makeStringArr(sentence:String) -> [String]{
        var lines: [String] = []
        sentence.enumerateLines { line, _ in
            lines.append(line)
        }
        return lines
    }
    
    func createSegments(strArray:[String]) -> (Array<[Double]>,Array<[String]>) {
        var append_segments_all : Array<[Double]> = Array()
        var append_segment_Alltime:  Array<[String]> = Array()
        for row in stride(from: 1, to: strArray.count-40, by: 10){
            var append_segments  = [Double]()
            var append_segments_time  = [String]()
            var i = 1
            for row_in_segment in row...row+39{
                let arr = strArray[row_in_segment]
                //print(arr.count)
                let array = arr.components(separatedBy: ",")
                //print("\(array)")
                if(i == 1){
                    append_segments_time.append(array[0])
                }else if(i == 40){
                    append_segments_time.append(array[0])
                }
                i += 1
                //print(append_segments_time)
                for i in 1...13{
                    //print("\(array[i])")
                    let turnFloat = (array[i] as NSString).doubleValue
                    //print("\(turnFloat)")
                    append_segments.append(turnFloat)
                }
            }
            //print(append_segments_time.count)
            //print(append_segments.count)
            append_segments_all.append(append_segments)
            append_segment_Alltime.append(append_segments_time)
        }
        //print("\(append_segments_all)")
        return (append_segments_all,append_segment_Alltime)
    }
    
    
    
    @IBAction func makePrediction(_ sender: UIButton) {
        var predictFile : String = ""
        
        let myAlert = UIAlertController(title: "ALERT", message: "There is no file to predict", preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (ACTION) in
            print("OK button tapped")
        }
        myAlert.addAction(okAction)
        
        
        
        self.readStringProject = readFile()
        if(self.readStringProject.elementsEqual("No File")){
            self.present(myAlert,animated: true,completion: nil)
            print("there is no file!!!!")
        }else{
            predictionInProgress.isHidden = false
            
            //print(self.readStringProject)
            strArr =  makeStringArr(sentence: self.readStringProject)
            //print(strArr?[0])
            //self.createMoldel()
            let (arrFloat,arrTime) = createSegments(strArray:(strArr)!)
            //print("\(arrTime.count)" + " \(arrFloat.count)" )
            
            predictFile = self.createModel(arr : arrFloat ,arrTime: arrTime)
            
            //print("hello: " + "\(predictFile)")
        }
        
        showPredictionTextView.text = predictFile
        predictionInProgress.text = "THE PREDICTION"
    }
    
    
    @IBAction func resetButton(_ sender: UIButton) {
        predictionInProgress.text = ""
        showPredictionTextView.text = ""
    }
    
}
