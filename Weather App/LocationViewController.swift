//
//  LocationViewController.swift
//  Weather App
//
//  Created by Tom Davis on 18/01/2017.
//  Copyright © 2017 Tom Davis. All rights reserved.
//

import Cocoa

class LocationViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var locationTextField: NSTextField!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var deleteButton: NSButton!
    
    @IBOutlet weak var tableView: NSTableView!
    
    
    var locations : [LocationDB] = []
    var locationRequest : String = ""
    var detailsVC : DetailViewController? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        locationTextField.placeholderString = "Add Location..."
        getLocations()
        deleteButton.isEnabled = false
        tableView.headerView = nil
    }
    
    
    
    @IBAction func addClicked(_ sender: Any) {
        
        if locationTextField.stringValue != "" {
            
            locationRequest = locationTextField.stringValue
            print("Getting City Name for \(locationRequest)")
            Parser().getLocationName(location: locationRequest)
            
            if let urlEncodedLocation = locationRequest.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] \"").inverted) {
                
                if let url = URL(string: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22\(urlEncodedLocation)%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys") {
                    
                    URLSession.shared.dataTask(with: url) { (data:Data?, response:URLResponse?, error:Error?) in
                        
                        if error != nil {
                            print(error!)
                        } else {
                            if data != nil {
                                let parser = Parser()
                                let info = parser.getKeyMetaData(data: data!)
                                
                                if info.city != nil {
                                    
                                    
                                    if !self.locationExists(cityName: info.city!) {
                                        
                                        if let context = (NSApplication.shared().delegate as? AppDelegate)?.managedObjectContext {
                                            let location = LocationDB(context: context)
                                            
                                            print("Writing to Core Data...")
                                            location.queryURL = url.absoluteString
                                            location.countryName = info.country
                                            location.cityName = info.city
                                            
                                            
                                            (NSApplication.shared().delegate as? AppDelegate)?.saveAction(nil)
                                            
                                            
                                            
                                            DispatchQueue.main.async {
                                                self.locationTextField.stringValue = ""
                                                self.getLocations()
                                                if let label = self.detailsVC?.infoLabel {
                                                    label.stringValue = "City Added Succesfully!"
                                                    label.textColor = NSColor.black
                                                }
                                                
                                                
                                            }
                                        }
                                    }
                                } else {
                                    print("No City was returned")
                                    if let label = self.detailsVC?.infoLabel {
                                        label.stringValue = "No City Was Found"
                                        label.textColor = NSColor.red
                                    }
                                }
                            }
                        }
                        }.resume()
                }
            }
        }
    }
    
    
    @IBAction func deleteClicked(_ sender: Any) {
        
        let location = locations[tableView.selectedRow]
        if let context = (NSApplication.shared().delegate as? AppDelegate)?.managedObjectContext {
            
            context.delete(location)
            
            (NSApplication.shared().delegate as? AppDelegate)?.saveAction(nil)
            
            getLocations()
            
            deleteButton.isEnabled = false
            
            detailsVC?.clearView()
            
            
            
        }
        
    }
    
    func locationExists(cityName:String) -> Bool {
        
        print("Checking city does not exist: \(cityName)")
        
        if let context = (NSApplication.shared().delegate as? AppDelegate)?.managedObjectContext {
            
            let fetchy = LocationDB.fetchRequest() as NSFetchRequest<LocationDB>
            fetchy.predicate = NSPredicate(format: "cityName ==%@", cityName)
            
            do {
                let matchingCities = try context.fetch(fetchy)
                
                if matchingCities.count >= 1 {
                    print("ERROR: City Exists in Core Data")
                    return true
                } else {
                    print("City does not exist, continuing...")
                    return false
                    
                }
            } catch {}
        }
        
        return false
    }
    
    
    func getLocations() {
        if let context = (NSApplication.shared().delegate as? AppDelegate)?.managedObjectContext {
            
            let fetchy = LocationDB.fetchRequest() as NSFetchRequest<LocationDB>
            fetchy.sortDescriptors = [NSSortDescriptor(key: "cityName", ascending: true)]
            
            do {
                locations = try context.fetch(fetchy)
                
            } catch {}
            
            tableView.reloadData()
        }
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.make(withIdentifier: "locationcell", owner: self) as? NSTableCellView
        
        let location = locations[row]
        
        if location.cityName != nil {
            
            cell?.textField?.stringValue = location.cityName!
            
        } else {
            cell?.textField?.stringValue = "Unknown Location"
        }
        return cell
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        if tableView.selectedRow >= 0 {
            
            deleteButton.isEnabled = true
            
            let location = locations[tableView.selectedRow]
            detailsVC?.location = location
            detailsVC?.updateView()
            detailsVC?.infoLabel.stringValue = ""
            
            
            
        } else {
            deleteButton.isEnabled = false
            detailsVC?.clearView()
        }
    }
}





