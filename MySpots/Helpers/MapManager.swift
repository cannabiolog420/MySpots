//
//  MapManager.swift
//  MySpots
//
//  Created by cannabiolog420 on 13.10.2020.
//

import Foundation
import MapKit
import CoreLocation

protocol MapManagerDelegate {
    
    func getTimeAndDistance(timeInterval: String, distance: String)
}


class MapManager{
    
    
    let locationManager = CLLocationManager()
    var mapManagerDelegate:MapManagerDelegate!
    private let regionInMeters:Double = 1000
    private var spotCoordinate:CLLocationCoordinate2D?
    private var directionsArray:[MKDirections] = []
    
    
    
    //Spot marker
    
    func setupPlacemark(spot:Spot,mapView:MKMapView){
        
        
        guard let location = spot.location else { return }
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            
            if let error = error{
                print(error.localizedDescription)
                return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = spot.name
            annotation.subtitle = spot.type
            
            guard let placemarkLocation = placemark?.location else { return }
            self.spotCoordinate = placemarkLocation.coordinate
            
            annotation.coordinate = placemarkLocation.coordinate
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    
     func checkLocationServices(mapView:MKMapView,segueIdentifier:String,closure:()->()){
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        }else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlertController(title: "Location Services are disabled",
                                         message: "To turn On Location Services go to:Settings → Privacy → Location Services")
            }
        }
    }
    
     func checkLocationAuthorization(mapView:MKMapView,segueIdentifier:String){
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse,.authorizedAlways:
            mapView.showsUserLocation = true
            if segueIdentifier == "getLocationSegue" { showUserLocation(mapView:mapView) }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlertController(title: "Your location is not available",
                                         message: "To give permission go to:Settings → Places → Location ")
            }
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        @unknown default:
            print("New case is available")
        }
    }
    
    
    
    
    private func showAlertController(title:String,message:String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default)
        let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { _ in
            
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsURL){
                UIApplication.shared.open(settingsURL)
            }
        }
        
        alertController.addAction(okAction)
        alertController.addAction(settingsAction)
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true)
    }
    
    
    func showUserLocation(mapView:MKMapView){
        
        if let location = locationManager.location?.coordinate{
            
            let region = MKCoordinateRegion(center:location , latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func startTrackingUserLocation(for mapView:MKMapView,and location:CLLocation?,closure:(_ currentLocation:CLLocation)->()){
        
        guard let previousLocation = location else { return }
        let center = getCenterLocation(for: mapView)
        
        guard center.distance(from: previousLocation) > 10 else { return }
        closure(center)
    }
    
    func getCenterLocation(for mapView:MKMapView)->CLLocation{
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    func getDirection(mapView:MKMapView,previousLocation:(CLLocation)->()){
        
        guard let location = locationManager.location?.coordinate else {
            showAlertController(title: "Error", message: "Location is not found")
            return
            
        }
        
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlertController(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
        
        resetMapView(withNew: directions, mapView: mapView)
        
        directions.calculate { (response, error) in
            if let error = error{
                print(error.localizedDescription)
            }
            guard let response = response else {
                self.showAlertController(title: "Error", message: "Direction is not available")
                return
            }
            
            for route in response.routes{
                
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            
                
                let distance = String(format: "%.f", route.distance / 1000)
                let timeInterval = String(format: "%.f", (route.expectedTravelTime / 60))
                
                self.mapManagerDelegate.getTimeAndDistance(timeInterval: timeInterval, distance: distance)
            }
            
            
        }
        
        
    }
    
    private func createDirectionsRequest(from coordinate:CLLocationCoordinate2D)->MKDirections.Request?{
        
        guard let destinationCoordinate = spotCoordinate else { return nil }
        
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    

    
    
    
    // Reset earlier created routes before creating new one

    func resetMapView(withNew directions:MKDirections,mapView:MKMapView){
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel()}
        directionsArray.removeAll()
    }
    
    
}
