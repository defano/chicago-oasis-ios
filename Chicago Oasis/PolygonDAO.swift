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

private class PolygonHolder {
    var data:[Polygon] = []
}

class PolygonDAO {
    
    private static let logger = XCGLogger()
    private static var neighborhoods:PolygonHolder = PolygonHolder()
    private static var tracts:PolygonHolder = PolygonHolder()

    static var neighborhoodCache:String {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory + "neighborhoods.cache"
    }

    static var censusCache:String {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory + "census-tracts.cache"
    }

    static func loadNeighborhoodBoundaries (onComplete: () -> Void) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            logger.debug("Loading neighborhood boundaries.")
            
            if let hoods = unarchive(self.neighborhoodCache) {
                logger.debug("Loaded neighborhood boundaries from cache.")
                neighborhoods.data = hoods
                dispatch_async(dispatch_get_main_queue()) {
                    onComplete()
                }
            }
            else {
                load("neighborhoods",
                     holder: &self.neighborhoods,
                     idNormalizer:
                        { name in
                            return name
                        },
                     onComplete:
                        { _ in
                            logger.debug("Loaded neighborhood boundaries from KML. Archiving to cache.")
                            NSKeyedArchiver.archiveRootObject(neighborhoods.data, toFile: self.neighborhoodCache)
                            logger.debug("Archived neighborhood boundaires to cache.")
                            onComplete()
                        }
                )
            }
        }
    }
    
    static func loadCensusTractBoundaries (onComplete: () -> Void) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            logger.debug("Loading census boundaries.")

            if let tracts = unarchive(self.censusCache) {
                logger.debug("Loaded census boundaries from cache.")
                self.tracts.data = tracts
                dispatch_async(dispatch_get_main_queue()) {
                    onComplete()
                }
            }
            else {
                load("census",
                     holder: &self.tracts,
                     idNormalizer:
                        { name in
                            return normalizeTractId(name)
                        },
                     onComplete:
                        { _ in
                            logger.debug("Loaded census boundaries from KML. Archiving to cache.")
                            NSKeyedArchiver.archiveRootObject(tracts.data, toFile: self.censusCache)
                            logger.debug("Archived census boundaires to cache.")
                            onComplete()
                        }
                )
            }
        }
    }
    
    static func getPolygons(mapType: MapType) -> [Polygon] {
        switch (mapType) {
        case .Neighborhoods:
            return neighborhoods.data
        case .CensusTracts:
            return tracts.data
        }
    }
    
    static private func unarchive (file: String) -> [Polygon]? {
        if (!UserDefaults.polygonCacheEnabled) {
            logger.debug("Polygon cache disabled in settings. Loading from KML.")
            return nil
        }
        
        if let data = NSKeyedUnarchiver.unarchiveObjectWithFile(file) as? [Polygon] {
            return data.count > 0 ? data : nil
        }

        return nil
    }
    
    static private func load (file:String!, inout holder:PolygonHolder, idNormalizer: (String) -> String, onComplete: () -> Void) {
        if holder.data.count > 0 {
            onComplete()
            return
        }
        
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "kml") {
            KMLDocument.parse(NSURL(fileURLWithPath: path), callback: { (kml) in
                
                for placemark in kml.placemarks {
                    holder.data.append(Polygon(id: idNormalizer(placemark.name), name: placemark.name))
                }
                
                for (index, overlay) in kml.overlays.enumerate() {
                    if index < holder.data.count {
                        holder.data[index].overlay = overlay as? MKPolygon
                    } else {
                        logger.error("Mismatched number of polygons [\(kml.overlays.count)] to placemarks [\(kml.placemarks.count)] in KML: " + file)
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