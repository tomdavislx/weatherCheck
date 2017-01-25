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
    @IBOutlet weak var conditionImageView: NSImageView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    var location : LocationDB? = nil
    var locationsVC : LocationViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        clearView()
        let image = #imageLiteral(resourceName: "yahoologo")
        yahooImageView.image = image
        
    }
    
    
    func updateView() {
        
        if location?.cityName != nil {
            cityLabel.stringValue = location!.cityName!
            countryLabel.stringValue = location!.countryName!
            tempLabel.stringValue = "Updating..."
            currentConditionLabel.stringValue = "Updating..."
            conditionImageView.image = nil
            progressIndicator.startAnimation(self)
            
            if let url = URL(string: location!.queryURL!) {
                
                URLSession.shared.dataTask(with: url) { (data:Data?, response:URLResponse?, error:Error?) in
                    
                    if error != nil {
                        print(error!)
                        
                    } else {
                        
                        if data != nil {
                            
                            let parser = Parser()
                            let info = parser.getTemp(data: data!)
                            
                            if info.temp != nil {
                                
                                DispatchQueue.main.async {
                                
                                self.tempLabel.stringValue = "\(info.temp!) °F / \(parser.celsiusConversion(degrees: info.temp!)) °C"
                                self.currentConditionLabel.stringValue = info.condition!
                                
                                // self.getForecasts()
                                self.getConditionImage()
                                    
                                }
                                
                            } else {
                                self.tempLabel.stringValue = "Unable to Retrieve"
                                self.currentConditionLabel.stringValue = "Unable to Retrieve"
                                
                            }
                            
                        }
                        DispatchQueue.main.async {
                            self.progressIndicator.stopAnimation(self)
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
    
    func getConditionImage() {
        
        if location?.cityName != nil {
            
            if let url = URL(string: location!.queryURL!) {
                
                URLSession.shared.dataTask(with: url) { (data:Data?, response:URLResponse?, error:Error?) in
                    
                    if error != nil {
                        print(error!)
                        
                    } else {
                        
                        if data != nil {
                            
                            let parser = Parser()
                            let code = parser.getConditionCode(data: data!)
                            
                            if code != nil {
                                
                                let imageURL = "http://l.yimg.com/a/i/us/we/52/\(code!).gif"
                                let image = NSImage(byReferencing: URL(string: imageURL)!)
                                DispatchQueue.main.async {
                                self.conditionImageView.image = image
                                }
                                
                            } else {
                                self.conditionImageView.image = nil
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
        self.conditionImageView.image = nil
    }
    
    
}
