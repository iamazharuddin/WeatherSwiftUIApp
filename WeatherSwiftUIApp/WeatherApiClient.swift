//
//  WeatherApiClient.swift
//  WeatherApp
//
//  Created by Azharuddin 1 on 27/03/23.
//

import Foundation
import CoreLocation
import SwiftUI

let API_KEY = "JyRla89QTGphnrZMiNFpeLQJTfuvRaX1"
let baseURL = "https://api.tomorrow.io/v4/timelines"
final class WeatherAPIClient: NSObject, ObservableObject {
    @Published var currentWeather: Weather?
    var location : CLLocation?
    private let dateFormatter = ISO8601DateFormatter()
    private let locationManager = LocationManager()

    override init() {
        super.init()
        locationManager.locationManagerDelegate = self
    }
    
    
    func decodeResponse(from data:Data) throws -> WeatherModel {
        do {
              let weatherResponse  = try JSONDecoder().decode(WeatherModel.self, from: data)
              return weatherResponse
        } catch {
            throw HttpError.invalidData
        }
    }
    
    func fetchWeather() async throws {
        guard let location = location else { return }
        
        let urlString = baseURL + "?location=\(location.coordinate.latitude),\(location.coordinate.longitude)&fields=emperature&fields=weatherCode&units=metric&timesteps=1h&startTime=\(dateFormatter.string(from: Date()))&endTime=\(dateFormatter.string(from:Date().addingTimeInterval(60*60)))&apikey=\(API_KEY)"
        
        print("urlstr mine ==== \(urlString)")
        guard let url = URL(string: urlString) else { throw HttpError.invalidURL }
        
        do{
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw HttpError.invalidResponse  }
            
          print(  Helper.convertDataToJsonString(data: data))
           let weatherResponse =  try decodeResponse(from: data)
            
            let weatherValue = weatherResponse.data.timelines.first!.intervals.first!.values
            let weatherCode = WeatherCode(rawValue: "\(weatherValue.weatherCode)")!
            
            locationManager.getPlace(for: location) { placemark in
                DispatchQueue.main.async { [weak self] in
                    self?.currentWeather = Weather(temperature: Int(weatherValue.temperature),
                                                   weatherCode: weatherCode, cityName: placemark?.locality ?? "")
                }
            }
          
        }catch let error{
            print(error.localizedDescription)
        }
    }
}

extension WeatherAPIClient : LocationManagerDelegate {
    func useLocation(_ location: CLLocation)  {
        self.location = location
        Task{
            try await fetchWeather()
        }
    }
}

enum HttpError : Error {
     case invalidResponse
     case invalidData
     case invalidURL
}
