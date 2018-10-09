//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController,CLLocationManagerDelegate,ChangeCiteDelegate {
   
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weeatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var mySwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url : String , parameters : [String : String]) {
        Alamofire.request(url, method: .get , parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("sucecess! got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json : weatherJSON)
                
            }
            else{
                let alert = UIAlertController(title: "Connection Issue", message: "please check connection!", preferredStyle: .alert)
                let restartAction = UIAlertAction(title: "Ok", style: .default, handler: { _ in
                    
                    print("hereeeeeeeeeeeeeee")
                  
                })
                alert.addAction(restartAction)
                
                self.present(alert, animated: true, completion: nil)
                
                print("Error \(response.result.error!)")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }

    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData (json : JSON){
        if let tempResult = json["main"]["temp"].double{
        
        weeatherDataModel.temprature = Int(tempResult - 273.15)
        weeatherDataModel.city = json["name"].stringValue
        weeatherDataModel.condition = json["weather"][0]["id"].intValue
        weeatherDataModel.weatherIconName = weeatherDataModel.updateWeatherIcon(condition: weeatherDataModel.condition)
            
            updateUiWithWeatherData()
        }
        else {
            
            let alert = UIAlertController(title: "Oops!", message: "Location you have entered is Unavilable, please enter it again", preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "ReEnter", style: .default, handler: { _ in
                
                print("hereeeeeeeeeeeeeee")
            })
            alert.addAction(restartAction)
            
            present(alert, animated: true, completion: nil)
            
            cityLabel.text = "Weather Unavilable"
            temperatureLabel.text = ""
            weatherIcon.image = UIImage()
            mySwitch.isHidden = true
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    func updateUiWithWeatherData(){
        temperatureLabel.text = "C \(weeatherDataModel.temprature)°"
        weatherIcon.image = UIImage(named : weeatherDataModel.weatherIconName)
        cityLabel.text = "\(weeatherDataModel.city)"
        
        
    }
    
    
    //Write the updateUIWithWeatherData method here:
    
    //MARK: - Location Manager Delegate Methods
    /*********************************************************\******/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            
            print("longtiude = \(location.coordinate.longitude) latitude = \(location.coordinate.latitude)")
            
            let longitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            
            let params : [String : String] = ["lat" : latitude , "lon" : longitude , "appid" : APP_ID]
      
            getWeatherData(url : WEATHER_URL, parameters : params )
        }
    }
    
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavilable"
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
   
    //Write the userEnteredANewCityName Delegate method here:
    func userEnterANewCityName(city: String) {
        
        let params : [String : String] = ["q" : city , "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
    
    @IBAction func changeBetween_F_C(_ sender: Any) {
        if mySwitch.isOn{
            
            temperatureLabel.text = "C \(weeatherDataModel.temprature)°"
        }else{
            
             temperatureLabel.text = "F \(weeatherDataModel.temprature * 9 / 5 + 32)°"
        }
        
    }
    
    
    
}


