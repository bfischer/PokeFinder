//
//  ViewController.swift
//  PokeFinder
//
//  Created by Blake Fischer on 2/15/17.
//  Copyright © 2017 Blake Fischer. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManage = CLLocationManager()
    var mapHasCenteredOnce = false
    var geoFire: GeoFire!
    var geoFireRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        geoFireRef = FIRDatabase.database().reference()
        geoFire = GeoFire(firebaseRef: geoFireRef)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    func createSighting(forLocation location: CLLocation, withPokemon pokemonId: Int) {
        geoFire.setLocation(location, forKey: "\(pokemonId)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == .authorizedWhenInUse) {
            mapView.showsUserLocation = true
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showSightingsOnMap(location: CLLocation, radius: Double) {
        let circleQuery = geoFire!.query(at: location, withRadius: radius);
        
        _ = circleQuery?.observe(GFEventType.keyEntered, with: {
            (key,location) in
            
            //Iterate through locations saved in db
            if let key = key, let location = location {
                let pokeAnnotation = PokemonAnnotation(coordinate: location.coordinate, pokemonId: Int(key)!)
                
                self.mapView.addAnnotation(pokeAnnotation)
            }
        })
    }
    
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if(!mapHasCenteredOnce) {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let anno = view.annotation as? PokemonAnnotation {
            let place = MKPlacemark(coordinate: anno.coordinate)
            let destination = MKMapItem(placemark: place)
            destination.name = "Pokemon Sighting"
            let regionDistance: CLLocationDistance = 1000
            let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span),
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking,
            ] as [String : Any]
            
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let location = CLLocation(latitude: self.mapView.centerCoordinate.latitude,
                                  longitude: self.mapView.centerCoordinate.longitude)
        
        showSightingsOnMap(location: location, radius: 2.5)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView?
        let annotationId = "Pokemon"
        
        if(annotation.isKind(of: MKUserLocation.self)) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "ash")
        }
        else if let deqAnnotation = self.mapView.dequeueReusableAnnotationView(withIdentifier: annotationId) {
            annotationView = deqAnnotation
            annotationView?.annotation = annotation
        }
        else {
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        
        if let annotationView = annotationView, let anno = annotation as? PokemonAnnotation {
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "\(anno.pokemonId)")
            
            let button = UIButton()
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            button.setImage(UIImage(named: "map"), for: .normal)
            annotationView.rightCalloutAccessoryView = button
        }
        
        return annotationView
    }
    
    func locationAuthStatus() {
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            mapView.showsUserLocation = true
        }
        else {
            locationManage.requestWhenInUseAuthorization()
        }
    }

    @IBAction func spotRandomPokemon(_ sender: Any) {
        let location = CLLocation(latitude: self.mapView.centerCoordinate.latitude,
                                  longitude: self.mapView.centerCoordinate.longitude)
        let pokemonId = Int(arc4random_uniform(5) + 1) //Generate randpom pokemon number - change later
        
        createSighting(forLocation: location, withPokemon: pokemonId)
    }

}

