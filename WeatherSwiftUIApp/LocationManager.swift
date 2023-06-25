//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Azharuddin 1 on 22/05/23.
//

import Foundation
import CoreLocation
protocol LocationManagerDelegate : AnyObject {
    func useLocation(_ location:CLLocation)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    weak var locationManagerDelegate : LocationManagerDelegate?
    override init() {
        super.init()
        getCurrentCityName()
    }
    
    func getCurrentCityName() {
        locationManager.delegate = self
        // Request location authorization
        locationManager.requestWhenInUseAuthorization()
        // Start updating location
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            // Failed to get location
            return
        }
        locationManagerDelegate?.useLocation(location)
        // Stop updating location to conserve battery
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Failed to get location
        print("Location manager error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
    }
}

// MARK: - Get Placemark
extension LocationManager {

    func getPlace(for location: CLLocation,
              completion: @escaping (CLPlacemark?) -> Void) {

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                completion(nil)
                return
            }

            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }

            completion(placemark)
        }
    }
}
