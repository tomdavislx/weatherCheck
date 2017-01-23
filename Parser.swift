//
//  Weather.swift
//  weather
//
//  Created by Tom Davis on 16/01/2017.
//  Copyright © 2017 Tom Davis. All rights reserved.
//

import Foundation

class Weather {
    
    var finished = false
    var apiLaunched = false
    
    func celsiusConversion(degrees: String) -> Float? {
        
        let converted = ((degrees as NSString).floatValue - 32) / 1.8
        return roundf(converted * 10) / 10
    }
    
    func getTemp(location:String)  {
        
        if let urlEncodedLocation = location.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] \"").inverted) {
            
            if let url = URL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22\(urlEncodedLocation)%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys") {
                
                URLSession.shared.dataTask(with: url, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) in
                    
                    if error != nil {
                        print("API ERROR!")
                    } else {
                        
                        if data != nil {
                            let json = JSON(data: data!)
                            if let temp = (json["query"]["results"]["channel"]["item"]["condition"]["temp"].string) {
                                print("Current Temp: \(temp)°F / \(self.celsiusConversion(degrees: temp)!)°C")
                            }
                            if let condition = (json["query"]["results"]["channel"]["item"]["condition"]["text"].string) {
                                print("Current Condition: \(condition)")
                                
                            }
                        }
                        
                    }
                    self.finished = true
                }).resume()
                
            } else {
                self.finished = true
            }
        } else {
            self.finished = true
        }
    }
}
