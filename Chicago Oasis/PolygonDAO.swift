//
//  PolygonDAO.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/23/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import Foundation
import MapKit
import Kml_swift
import XCGLogger

private class PolyCache {
    var data:[Polygon] = []
}

class PolygonDAO {
    
    private static let logger = XCGLogger()
    
    private static var neighborhoods:PolyCache = PolyCache()
    private static var tracts:PolyCache = PolyCache()

    static func loadNeighborhoodBoundaries (onComplete: () -> Void) {
        
        load("neighborhoods",
             cache: &self.neighborhoods,
             nameNormalizer:
                { name in
                    return name
                },
             onComplete:
                { _ in
                    onComplete()
                }
        )
    }
    
    static func loadCensusTractBoundaries (onComplete: () -> Void) {
        load("census",
             cache: &self.tracts,
             nameNormalizer:
            { name in
                return normalizeTractId(name)
            },
             onComplete:
            { _ in
                onComplete()
            }
        )
    }
    
    static func getPolygons(mapType: MapType) -> [Polygon] {
        switch (mapType) {
        case .Neighborhoods:
            return neighborhoods.data
        case .CensusTracts:
            return tracts.data
        }
    }
    
    static private func load (file:String!, inout cache:PolyCache, nameNormalizer: (String) -> String, onComplete: () -> Void) {
        if cache.data.count > 0 {
            onComplete()
            return
        }
        
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "kml") {
            KMLDocument.parse(NSURL(fileURLWithPath: path), callback: { (kml) in
                for placemark in kml.placemarks {
                    cache.data.append(Polygon(id: nameNormalizer(placemark.name), name: placemark.name))
                }
                
                for (index, overlay) in kml.overlays.enumerate() {
                    if index < cache.data.count {
                        cache.data[index].overlay = overlay
                    } else {
                        logger.error("Mismatched number of polygons to placemarks in KML: " + file)
                    }
                }
                
                onComplete()
            })
        }
    }
    
    /*
     * Census tract identifiers in KML do not exactly match those in the JSON. This function
     * translates a KML-encoded ID to a JSON-recognized on.
     * 
     * Two differences: a) KML ID is prefixed with "Census Tract " and b) tract numbers under
     * 1000 lack a preceedinging '0'. (i.e., 719 -> 0719)
     */
    static private func normalizeTractId (id: String) -> String {
        var normalizedId = id
        
        // Remove the "Census Tract " prefix from the data
        normalizedId.removeRange(normalizedId.startIndex..<normalizedId.startIndex.advancedBy("Census Tract ".characters.count))
        
        // And add a leading zero for sub-1000 tract ids
        if (Double(normalizedId) < 1000) {
            normalizedId = "0" + normalizedId
        }
        
        return normalizedId
    }
}