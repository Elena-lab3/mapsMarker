//
//  ViewController.swift
//  mapsMarker
//
//  Created by Елена Барковская on 4.08.22.
//

import UIKit
import Alamofire
import GoogleMaps

class ViewController: UIViewController {

    var dataFromRequest: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            
            //Google Maps initialization
            GMSServices.provideAPIKey(" AIzaSyDndZLBLdTftInxO2cB1aysHZDDnKE11a0")
            let mapView = GMSMapView.map(withFrame: self.view.frame, camera: GMSCameraPosition.camera(withLatitude: 52.6365, longitude: 31.1356, zoom: 6.0))
            self.view.addSubview(mapView)
            //Alamofire request
            AF.request("https://fish-pits.krokam.by/api/rest/points/?format=json").response(){(response) in
                if let data = response.data {
                        self.dataFromRequest = String(data: data, encoding: .utf8)!
                    do {
                        if let jsonArray = try JSONSerialization.jsonObject(with: Data(self.dataFromRequest.utf8), options :[]) as? [Dictionary<String,Any>]
                            {
                            for i in 0...jsonArray.count-1 where i % 3 == 0{
                                guard let coordinatesJSON = jsonArray[i]["point"]! as? [String:Any] else{return}
                                self.addMarker(lat: coordinatesJSON["lat"]! as! Double, lon: coordinatesJSON["lng"]! as! Double, description: String(htmlEncodedString: jsonArray[i]["point_name"]! as! String)!, mapView: mapView)
                            }
                                } else {
                                    print("bad json")
                                }
                        } catch let error as NSError {
                                print(error)
                        }
                    }
                
        }
    }
        
        func addMarker(lat: Double, lon: Double, description: String, mapView: GMSMapView) {
            let marker = GMSMarker()
            marker.icon = UIImage(named: "marker")
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            marker.title = description
            marker.map = mapView
        }
}

extension String {
    init?(htmlEncodedString: String) {
        guard let data = htmlEncodedString.data(using: .utf8) else { return nil }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else { return nil }
        
        self.init(attributedString.string)
    }

}




