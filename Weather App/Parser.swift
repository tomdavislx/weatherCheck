//
//  Parser.swift
//  Weather App
//
//  Created by Tom Davis on 18/01/2017.
//  Copyright © 2017 Tom Davis. All rights reserved.
//

import Foundation

class Location {
    
    var finished = false
    var apiLaunched = false
    
}

class Parser {
    
    func getKeyMetaData(data:Data) -> (city:String?, country:String?) {
        
        let json = JSON(data: data)
        
        return (json["query"]["results"]["channel"]["location"]["city"].string, json["query"]["results"]["channel"]["location"]["country"].string)
    }
    
    
    func celsiusConversion(degrees: String) -> Float {
        
        let converted = ((degrees as NSString).floatValue - 32) / 1.8
        return roundf(converted * 10) / 10
    }
    
    
    
    func getLocationName(location:String) {
        if let urlEncodedLocation = location.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] \"").inverted) {
            
            print("Encoding Location Request \(urlEncodedLocation)")
            
            if let url = URL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22\(urlEncodedLocation)%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys") {
                
                URLSession.shared.dataTask(with: url, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) in
                    
                    if error != nil {
                        print("API ERROR!")
                    } else {
                        
                        if data != nil {
                            let json = JSON(data: data!)
                            if let city = (json["query"]["results"]["channel"]["location"]["city"].string) {
                                print(city)
                            }
                            if let country = (json["query"]["results"]["channel"]["location"]["country"].string) {
                                print(country)
                            }
                        } else {
                            print("Unable to retrieve API Data")
                        }
                    }
                }).resume()
            }
        }
    }
    
    
    func getTemp(data:Data) -> (temp:String?, condition:String?)  {
        
        let json = JSON(data: data)
        
        return (json["query"]["results"]["channel"]["item"]["condition"]["temp"].string, json["query"]["results"]["channel"]["item"]["condition"]["text"].string)
    }
    
    func getForecast(data:Data) -> [Forecast] {
        
        let json = JSON(data: data)
        
        var forecasts : [Forecast] = []
        
        for forecastEntry in 0...4 {
            
            let forecast = Forecast()
            
            if let high = (json["query"]["results"]["channel"]["item"]["forecast"][forecastEntry]["high"].string) {
                forecast.high = high
            }
            if let low = (json["query"]["results"]["channel"]["item"]["forecast"][forecastEntry]["low"].string) {
                forecast.low = low
            }
            if let day = (json["query"]["results"]["channel"]["item"]["forecast"][forecastEntry]["day"].string) {
                forecast.day = day
            }
            if let condition = (json["query"]["results"]["channel"]["item"]["forecast"][forecastEntry]["text"].string) {
                forecast.condition = condition
            }
            
            forecasts.append(forecast)
//            print(forecast.condition)
            print(forecasts)
            
        }
        
        return forecasts
        
    }
    
    
    
    
}



