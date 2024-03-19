//
//  ViewController.swift
//  GPS (L7)
//
//  Created by PRIYAM PATEL on 18/03/24.
//

import UIKit
import CoreLocation
import MapKit

class TripViewController: UIViewController, CLLocationManagerDelegate {
    

    @IBOutlet weak var startTripButton: UIButton!
    @IBOutlet weak var stopTripButton: UIButton!
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var maxAccelerationLabel: UILabel!
    @IBOutlet weak var speedAlert: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var greenView: UIView!
    
    let locationManager = CLLocationManager()
    var Tripstart = false
    var startTripTime: Date?
    var currentSpeed: CLLocationSpeed = 0.0
    var maxSpeed: CLLocationSpeed = 0.0
    var distance: CLLocationDistance = 0.0
    var maxAcceleration: Double = 0.0
    var previousLocation: CLLocation?
    var speed: [CLLocationSpeed] = []
    var lastSpeed: CLLocationSpeed = 0.0
    var timetaken: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
        
    }
    
    func setupUI(){
        speedAlert.backgroundColor = .gray
        greenView.backgroundColor = .gray
        currentSpeedLabel.text = "0 km/h"
        maxSpeedLabel.text = "0 km/h"
        averageSpeedLabel.text = "0 km/h"
        distanceLabel.text = "0 km"
        maxAccelerationLabel.text = "0 m/s²"
    }
    func setupLocationManager(){
        Tripstart = false
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func startButton(_ sender: Any) {
        locationManager.requestAlwaysAuthorization()
        Tripstart = true
        startTripTime = Date()
        timetaken = 0
        startUpdatingLocation()
    }
    
    @IBAction func stopButton(_ sender: Any) {
        Tripstart = false
        stopUpdatingLocation()
        TripSummary()
        greenView.backgroundColor = .gray
        currentSpeed = 0.0
        maxSpeed = 0.0
        distance = 0.0
        maxAcceleration = 0.0
        speed = []
        previousLocation = nil
        updateUI()
    }
    
    func startUpdatingLocation(){
        locationManager.startUpdatingLocation()
        speed = []
        previousLocation = nil
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        greenView.backgroundColor = .green
    }
    func stopUpdatingLocation(){
        locationManager.stopUpdatingLocation()
        mapView.showsUserLocation = false
        mapView.userTrackingMode = .none
    }
    func updateUI(){
        currentSpeedLabel.text = String(format: "%.1f km/h",currentSpeed * 3.6)
        maxSpeedLabel.text = String(format: "%.1f km/h", maxSpeed * 3.6)
        averageSpeedLabel.text = speed.isEmpty ? "0 km/h" : String(format: "%.1f km/h ",(speed.reduce(0,+)/Double(speed.count)) * 3.6)
        distanceLabel.text = String(format: "%.1f km", distance / 1000)
        maxAccelerationLabel.text = String(format: "%.1f m/s²",maxAcceleration)
        if currentSpeed * 3.6 > 115{
            speedAlert.backgroundColor = .red
            speedAlert.isHidden = false
        } else{
            speedAlert.backgroundColor = .gray
            speedAlert.isHidden = true
        }
        let averageSpeed = timetaken > 0 ? distance / timetaken : 0
        averageSpeedLabel.text = String(format: "%.1f km/h", averageSpeed * 3.6)

    }
    func TripSummary() {
        let timetaken = startTripTime != nil ? Date().timeIntervalSince(startTripTime!) : 0
        let averageSpeed = timetaken > 0 ? distance / timetaken : 0
        var lastSpeed = 0.0
        var accelerations: [Double] = []
        for spid in speed {
            let currentAcceleration = (spid - lastSpeed) / (timetaken / Double(speed.count))
            accelerations.append(currentAcceleration)
            lastSpeed = spid
        }
        maxAcceleration = accelerations.max() ?? 0.0
        averageSpeedLabel.text = String(format: "%.1f km/h", averageSpeed * 3.6)
        maxAccelerationLabel.text = String(format: "%.2f m/s²", maxAcceleration)
        speed = []
        distance = 0.0
        maxSpeed = 0.0
        startTripTime = nil
    }
}
extension TripViewController{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, Tripstart else {return}
        let spid = location.speed >= 0 ? location.speed : 0
        currentSpeed = spid
        maxSpeed = max(maxSpeed, currentSpeed)
        speed.append(currentSpeed)
        
        if let strttrp = startTripTime {
                timetaken = Date().timeIntervalSince(strttrp)
            }
        
        if let previousLocation = previousLocation {
            let timeInterval = location.timestamp.timeIntervalSince(previousLocation.timestamp)
            if timeInterval > 0 {
                let Acceleration = abs(spid - lastSpeed) / timeInterval
                maxAcceleration = max(maxAcceleration, Acceleration)
                let totaldistance = location.distance(from: previousLocation)
                distance += totaldistance


            }
        }
        
        lastSpeed = spid
        previousLocation = location
        
        let averageSpeed = timetaken > 0 ? distance / timetaken : 0
        averageSpeedLabel.text = String(format: "%.1f km/h", averageSpeed * 3.6)
        updateUI()
    }
}
    


