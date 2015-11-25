//
//  MapViewController.swift
//  ExchangeAGram
//
//  Created by Darryl Pendergrass on Nov/1/15.
//  Copyright © 2015 Phoenix Media Services, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        MapView Test Code
//        let location = CLLocationCoordinate2D(latitude: 48.868639224587, longitude: 2.37119161036255)
//        let span = MKCoordinateSpanMake(0.05, 0.05)
//        let region = MKCoordinateRegionMake(location, span)
//        mapView.setRegion(region, animated: true)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = location
//        annotation.title = "Canal Saint-Martin"
//        annotation.subtitle = "Paris"
//        mapView.addAnnotation(annotation)
        
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDelegate.managedObjectContext
        var itemArray: [AnyObject] = []
        do {
            try itemArray = context.executeFetchRequest(request)
            if itemArray.count > 0 {
                for itemEntry in itemArray {
                    let item = itemEntry as! FeedItem
                    if !((item.latitude == nil) && (item.longitude == nil))
                    {
                        let location = CLLocationCoordinate2D(latitude: Double(item.latitude!), longitude: Double(item.longitude!))
                        let span = MKCoordinateSpanMake(0.05, 0.05)
                        let region = MKCoordinateRegionMake(location, span)
                        mapView.setRegion(region, animated: true)
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = location
                        annotation.title = item.caption
                        mapView.addAnnotation(annotation)
                    }
                }
            }
        }
        catch {
            print("Fetch Request Error")
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
