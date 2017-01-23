//
//  DetailViewController.swift
//  Weather App
//
//  Created by Tom Davis on 18/01/2017.
//  Copyright © 2017 Tom Davis. All rights reserved.
//

import Cocoa

class DetailViewController: NSViewController {
    
    
    @IBOutlet weak var cityLabel: NSTextField!
    @IBOutlet weak var countryLabel: NSTextField!
    @IBOutlet weak var tempLabel: NSTextField!
    @IBOutlet weak var currentConditionLabel: NSTextField!
    @IBOutlet weak var infoLabel: NSTextField!
    @IBOutlet weak var yahooImageView: NSImageView!
    
    var location : LocationDB? = nil
    var locationsVC : LocationViewController? = nil
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        clearView()
        //        yahooImageView.image = image
        
    }
    
    
    func updateView() {
        
        if location?.cityName != nil {
            cityLabel.stringValue = location!.cityName!
            countryLabel.stringValue = location!.countryName!
            tempLabel.stringValue = "Updating..."
            currentConditionLabel.stringValue = "Updating..."
            
            if let url = URL(string: location!.queryURL!) {
                
                URLSession.shared.dataTask(with: url) { (data:Data?, response:URLResponse?, error:Error?) in
                    
                    if error != nil {
                        print(error!)
                        
                    } else {
                        
                        if data != nil {
                            
                            let parser = Parser()
                            let info = parser.getTemp(data: data!)
                            
                            if info.temp != nil {
                                self.tempLabel.stringValue = "\(info.temp!) °F / \(parser.celsiusConversion(degrees: info.temp!)) °C"
                                self.currentConditionLabel.stringValue = info.condition!
                                
                                self.getForecasts()
                                
                                
                            } else {
                                self.tempLabel.stringValue = "Unable to Retrieve"
                                self.currentConditionLabel.stringValue = "Unable to Retrieve"
                            }
                            
                        }
                    }
                    }.resume()
            }
        }
    }
    
    func getForecasts() {
        
        if location?.cityName != nil {
            
            if let url = URL(string: location!.queryURL!) {
                
                URLSession.shared.dataTask(with: url) { (data:Data?, response:URLResponse?, error:Error?) in
                    
                    if error != nil {
                        print(error!)
                        
                    } else {
                        
                        if data != nil {
                            
                            let parser = Parser()
                            let info = parser.getForecast(data: data!)
                            
                            if info.count >= 1 {
//                                print(info)
                            } else {
                                print("Array Empty")
                            }
                            
                        }
                    }
                    }.resume()
            }
            
        }
    }
    
    
    
    func clearView() {
        
        cityLabel.stringValue = "No City Selected"
        countryLabel.stringValue = ""
        tempLabel.stringValue = ""
        currentConditionLabel.stringValue = ""
        infoLabel.stringValue = ""
    }
    
    
}
