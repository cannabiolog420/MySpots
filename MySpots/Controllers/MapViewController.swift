//
//  MapViewController.swift
//  MySpots
//
//  Created by cannabiolog420 on 12.10.2020.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    
    func getAddress(_ address:String?)
    
}

class MapViewController: UIViewController {
    
    
    var spot = Spot()
    var mapViewControllerDelegate:MapViewControllerDelegate?
    let annotationIdentifier = "annotationIdentifier"
    var segueIdentifier = ""
    let mapManager = MapManager()
    var previousLocation:CLLocation?{
        didSet{
            mapManager.startTrackingUserLocation(for: mapView, and: previousLocation) { (currentLocation) in
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var userLocation: UIButton!
    @IBOutlet weak var marker: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var timeAndDistanceLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = ""
        userLocation.setImage(UIImage(systemName: "location.fill"), for: .selected)
        
        mapManager.mapManagerDelegate = self
        mapView.delegate = self
        mapView.showsCompass = false
        setupMapView()
        
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        userLocation.isSelected = false
    }
    
    @IBAction func closeMap(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
    
    
    @IBAction func centerUserLocation(_ sender: UIButton) {
        
        userLocation.isSelected = true
        mapManager.showUserLocation(mapView: mapView)
        
    }
    
    
    @IBAction func donePressed(_ sender:UIButton) {
        
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
        
    }
    
    
    @IBAction func getDirections() {
        
        mapManager.getDirection(mapView: mapView) { (location) in
            self.previousLocation = location
        }
    }
    
    
    
    
    private func setupMapView(){
        
        timeAndDistanceLabel.isHidden = true
        goButton.isHidden = true
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: segueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        if segueIdentifier == "showSpotOnMap"{
            
            marker.isHidden = true
            doneButton.isHidden = true
            addressLabel.isHidden = true
            goButton.isHidden = false
            mapManager.setupPlacemark(spot: spot, mapView: mapView)
        }
    }
    
   
}

extension MapViewController:MKMapViewDelegate{
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil}
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil{
            
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
            
        }
        
        if let image = spot.imageData{
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: image)
            annotationView?.leftCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let location = mapManager.getCenterLocation(for: mapView)
        
        let geocoder = CLGeocoder()
        
//        if segueIdentifier == "showSpotOnMap" && previousLocation != nil{
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.mapManager.showUserLocation(mapView: mapView)
//            }
//        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            
            if let error = error{
                print(error.localizedDescription)
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                
                if streetName != nil && buildNumber != nil{
                    self.addressLabel.text = "\(streetName!),\(buildNumber!)"
                }else if streetName != nil{
                    self.addressLabel.text = "\(streetName!)"
                }else{
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        
        
        renderer.strokeColor = .black
        
        
        return renderer
    }
    
    
}

extension MapViewController:CLLocationManagerDelegate{
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        mapManager.checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
    }
    
}


extension MapViewController:MapManagerDelegate{
    
    func getTimeAndDistance(timeInterval: String, distance: String) {
        
        timeAndDistanceLabel.isHidden = false
        timeAndDistanceLabel.text = "\(timeInterval) min(\(distance) km)"
    }
}

