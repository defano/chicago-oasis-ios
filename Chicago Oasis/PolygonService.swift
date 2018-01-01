//
//  PolygonService.swift
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

class PolygonService {
    
    static let sharedInstance = PolygonService()
    private init() {}
    
    private var neighborhoods = PolygonHolder()
    private var tracts = PolygonHolder()

    var neighborhoodCachePath:String {
        var cacheUrl:URL = try! FileManager().url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        cacheUrl = cacheUrl.appendingPathComponent("neighborhoods.cache")
        if !FileManager().fileExists(atPath: cacheUrl.path) {
            FileManager().createFile(atPath: cacheUrl.path, contents: nil, attributes: nil)
        }
        try! (cacheUrl as NSURL).setResourceValue(NSNumber(value: true as Bool), forKey: URLResourceKey.isExcludedFromBackupKey)
        return cacheUrl.path
    }

    var censusCachePath:String {
        var cacheUrl:URL = try! FileManager().url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        cacheUrl = cacheUrl.appendingPathComponent("census-tracts.cache")
        if !FileManager().fileExists(atPath: cacheUrl.path) {
            FileManager().createFile(atPath: cacheUrl.path, contents: nil, attributes: nil)
        }
        try! (cacheUrl as NSURL).setResourceValue(NSNumber(value: true as Bool), forKey: URLResourceKey.isExcludedFromBackupKey)
        return cacheUrl.path
    }

    func loadNeighborhoodBoundaries (_ onComplete: @escaping () -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            logger.debug("Loading neighborhood boundaries.")
            
            if let hoods = self.unarchive(self.neighborhoodCachePath) {
                logger.debug("Loaded neighborhood boundaries from cache.")
                self.neighborhoods.data = hoods
                DispatchQueue.main.async {
                    onComplete()
                }
            }
            else {
                self.load("neighborhoods",
                     holder: self.neighborhoods,
                     idNormalizer:
                        { name in
                            return name
                        },
                     onComplete:
                        { 
                            logger.debug("Loaded neighborhood boundaries from KML. Archiving to cache.")
                            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                                NSKeyedArchiver.archiveRootObject(self.neighborhoods.data, toFile: self.neighborhoodCachePath)
                                logger.debug("Archived neighborhood boundaires to cache.")
                            }
                            onComplete()
                        }
                )
            }
        }
    }
    
    func loadCensusTractBoundaries (_ onComplete: @escaping () -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            logger.debug("Loading census boundaries.")

            if let tracts = self.unarchive(self.censusCachePath) {
                logger.debug("Loaded census boundaries from cache.")
                self.tracts.data = tracts
                DispatchQueue.main.async {
                    onComplete()
                }
            }
            else {
                self.load("census",
                     holder: self.tracts,
                     idNormalizer:
                        { name in
                            return self.normalizeTractId(name)
                        },
                     onComplete:
                        { 
                            logger.debug("Loaded census boundaries from KML. Archiving to cache.")
                            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                                NSKeyedArchiver.archiveRootObject(self.tracts.data, toFile: self.censusCachePath)
                                logger.debug("Archived census boundaires to cache.")
                            }
                            onComplete()
                        }
                )
            }
        }
    }
    
    func getPolygons(_ mapType: MapType) -> [Polygon] {
        switch (mapType) {
        case .neighborhoods:
            return neighborhoods.data
        case .censusTracts:
            return tracts.data
        }
    }
    
    private func unarchive (_ file: String) -> [Polygon]? {
        if (!UserDefaults.polygonCacheEnabled) {
            logger.debug("Polygon cache disabled in settings. Loading from KML.")
            return nil
        }
        
        if let data = NSKeyedUnarchiver.unarchiveObject(withFile: file) as? [Polygon] {
            return data.count > 0 ? data : nil
        }

        return nil
    }
    
    private func load (_ file:String, holder: PolygonHolder, idNormalizer: @escaping (String) -> String, onComplete: @escaping () -> Void) {
        
        if holder.data.count > 0 {
            onComplete()
            return
        }
        
        if let path = Bundle.main.path(forResource: file, ofType: "kml") {
            KMLDocument.parse(URL(fileURLWithPath: path), callback: { (kml) in
                
                for placemark in kml.placemarks {
                    holder.data.append(Polygon(id: idNormalizer(placemark.name), name: placemark.name))
                }
                
                for (index, overlay) in kml.overlays.enumerated() {
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
     * 1000 lack a preceedinging '0'. Thus, "Census Tract 719" becomes "0719"
     */
    private func normalizeTractId (_ id: String) -> String {
        var normalizedId = id
        
        // Remove the "Census Tract " prefix from the data
        normalizedId.removeSubrange(normalizedId.startIndex..<normalizedId.characters.index(normalizedId.startIndex, offsetBy: "Census Tract ".characters.count))
        
        // And add a leading zero for sub-1000 tract ids
        if (Double(normalizedId) ?? 1000) < 1000 {
            normalizedId = "0" + normalizedId
        }
      
        return normalizedId
    }
}
