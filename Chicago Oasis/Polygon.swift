//
//  Polygon.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/29/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import MapKit

@objc
class Polygon : NSObject, NSCoding {
    var id:String
    var name:String
    var overlay:MKPolygon?
    
    init (id: String, name: String, overlay: MKPolygon) {
        self.id = id
        self.name = name
        self.overlay = overlay
    }
    
    init (id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.id, forKey: "id")
        aCoder.encodeObject(self.name, forKey: "name")
        
        if (self.overlay != nil) {
            aCoder.encodeObject(SerializableMKPolygon(polygon: self.overlay!), forKey: "overlay")
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let
            id = aDecoder.decodeObjectForKey("id") as? String,
            name = aDecoder.decodeObjectForKey("name") as? String,
            overlay = aDecoder.decodeObjectForKey("overlay") as? SerializableMKPolygon
            else
        {
            return nil
        }
        
        self.init(id: id, name: name, overlay: overlay.polygon)
    }
}

@objc
class SerializableMKPolygon : NSObject, NSCoding {
    
    let polygon: MKPolygon
    
    init (polygon: MKPolygon) {
        self.polygon = polygon
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        var coordinateRecords: [[String:Double]] = [[:]]
        let coordinatePtr = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(polygon.pointCount)
        polygon.getCoordinates(coordinatePtr, range: NSRange(location: 0, length: polygon.pointCount))
        
        for index in 0 ... polygon.pointCount - 1 {
            let lat = coordinatePtr.advancedBy(index).memory.latitude
            let lng = coordinatePtr.advancedBy(index).memory.longitude
            
            coordinateRecords.append(["lat":lat, "lng":lng])
        }
        
        aCoder.encodeObject(coordinateRecords, forKey: "coordinates")
        aCoder.encodeObject(polygon.title, forKey: "title")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let coordinateRecords = aDecoder.decodeObjectForKey("coordinates") as? [[String:Double]] else {
            return nil
        }

        var coordinates: [CLLocationCoordinate2D] = []
        for thisCoordinateRecord in coordinateRecords {
            if let lat = thisCoordinateRecord["lat"], lng = thisCoordinateRecord["lng"] {
                coordinates.append(CLLocationCoordinate2DMake(lat, lng))
            }
        }
        
        let polygon: MKPolygon = MKPolygon(coordinates: UnsafeMutablePointer<CLLocationCoordinate2D>(coordinates), count: coordinates.count)
        polygon.title = aDecoder.decodeObjectForKey("title") as? String
        
        self.init(polygon: polygon)
    }
}