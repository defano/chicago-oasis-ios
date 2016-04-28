//
//  DetailViewController.swift
//  Chicago Oasis
//
//  Created by Matt DeFano on 4/23/16.
//  Copyright © 2016 Matt DeFano. All rights reserved.
//

import UIKit
import MapKit
import CoreGraphics
import Kml_swift

class DetailViewController: UIViewController, MKMapViewDelegate {

    // Default centerpoint of the displayed map; Chicago Loop
    let chicagoLatitude = 41.883229, chicagoLongitude = -87.63239799999999
    
    let zoomMeters = 10000.0   // Zoom level of the map; number of meters visible in the longest visible dimension
    let bucketCount = 5.0      // Number of distinct shades used when coloring the map
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var mapTypeSelection: UISegmentedControl!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet weak var earliestYearLabel: UILabel!
    @IBOutlet weak var latestYearLabel: UILabel!
    @IBOutlet weak var criticalBusinessSelection: UISwitch!
    @IBOutlet weak var relativeShadingSelection: UISwitch!
    @IBOutlet weak var yearSelection: UISlider!
    
    var selectedYear = 0
    var selectedMap: MapType = MapType.Neighborhoods
    
    var neighborhoodIndexes: [String:Double]?
    var censusIndexes: [String:Double]?
    var license: LicenseRecord?
    
    // MARK: - View
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Possible on iPad devices where detail view is initially shown
        if (license == nil) {
            license = LicenseDAO.licenses[0]
        }
        
        centerMap(CLLocationCoordinate2D(latitude: chicagoLatitude, longitude: chicagoLongitude), latMeters: zoomMeters, lngMeters: zoomMeters)

        map.delegate = self
        map.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMapWasTapped)))

        yearRangeChanged()
        redrawMap(true)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        reshadeVisiblePolygons()
    }
    
    @IBAction func onYearSelectionChanged(sender: UISlider) {
        if (self.selectedYear != Int(yearSelection.value)) {
            self.selectedYear = Int(yearSelection.value)
            redrawMap(false)
        }
    }
    
    @IBAction func onMapTypeSelectionChanged() {
        switch mapTypeSelection.selectedSegmentIndex {
        case 0:
            self.selectedMap = MapType.Neighborhoods
            break;
        default:
            self.selectedMap = MapType.CensusTracts
            break;
        }
        
        redrawMap(true)
    }

    @IBAction func onShowCriticalChanged(sender: AnyObject) {
        updateCriticalBusinesses()
    }
    
    
    @IBAction func onRelativeShadingChanged(sender: AnyObject) {
        reshadeVisiblePolygons()
    }
    
    // MARK: - Map
    
    func onMapWasTapped (tap: UIGestureRecognizer) {
        let tapPoint:CGPoint = tap.locationInView(map)
        let tapCoordinate:CLLocationCoordinate2D = map.convertPoint(tapPoint, toCoordinateFromView: map)
        let tapCoordinateRegion: MKCoordinateRegion = MKCoordinateRegionMake(tapCoordinate, MKCoordinateSpanMake(0, 0))
        let touchMapRect: MKMapRect = MKMapRectForCoordinateRegion(tapCoordinateRegion)
        
        for (index, overlay) in map.overlays.enumerate() {
            if overlay.isKindOfClass(KMLOverlayPolygon) {
                let polygon:MKPolygon = overlay as! MKPolygon
                if (polygon.intersectsMapRect(touchMapRect)) {
                    onPolygonWasTapped(PolygonDAO.getPolygons(selectedMap)[index].id)
                    return
                }
            }
        }
    }
    
    func onPolygonWasTapped(polygonId: String) {
        if (selectedMap == MapType.Neighborhoods) {
            print(SocioeconomicDAO.data[polygonId]?.perCapitaIncome)
        }
    }
    
    func MKMapRectForCoordinateRegion(region: MKCoordinateRegion!) -> MKMapRect {
        let a:MKMapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta / 2, region.center.longitude - region.span.longitudeDelta / 2))
        
        let b:MKMapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta / 2, region.center.longitude + region.span.longitudeDelta / 2))
        
        return MKMapRectMake(min(a.x, b.x), min(a.y,b.y), abs(a.x-b.x), abs(a.y-b.y))
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polygonView = MKPolygonRenderer(overlay: overlay)
        let grey = UIColor.grayColor()
        let alphaGrey = grey.colorWithAlphaComponent(0.5)
        
        polygonView.strokeColor = grey
        polygonView.lineWidth=2.0
        polygonView.fillColor = alphaGrey
        
        return polygonView
    }
    
    func centerMap (coordinates: CLLocationCoordinate2D!, latMeters: Double!, lngMeters: Double!) {
        let visibleRegion = MKCoordinateRegionMakeWithDistance(coordinates, latMeters, lngMeters)
        map.setRegion(map.regionThatFits(visibleRegion), animated: false)
    }
    
    // MARK: - UI Updates
    
    private func updateSelectionLabel() {
        switch mapTypeSelection.selectedSegmentIndex {
        case 0:
            selectionLabel.text = "\((license?.title)!) accessibility in \(selectedYear)"
            break;
        case 1:
            selectionLabel.text = "\((license?.title)!) accessibility in \(selectedYear)"
            break
        default:
            break
        }
    }
    
    // Reshade (color) polygons visible on the map using current data selections
    func reshadeVisiblePolygons() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            let visiblePolygons = self.visiblePolygons()
            let activePolygons = self.relativeShadingSelection.on ? visiblePolygons : PolygonDAO.getPolygons(self.selectedMap)
            
            var minIndex = 0.0, maxIndex = 0.0
            
            self.indexRangeForPolygons(activePolygons, minIndex: &minIndex, maxIndex: &maxIndex)
            
            for poly in visiblePolygons {
                if let renderer = self.map.rendererForOverlay(poly.overlay!) as? MKPolygonRenderer, index = self.accessabilityIndexForArea(poly.id) {
                    renderer.strokeColor = UIColor.whiteColor()
                    renderer.lineWidth=2.0
                    renderer.fillColor = UIColor(red:0.4, green:0.6, blue:1.0, alpha:CGFloat(self.alphaForAccessibilityIndex(index, minIndex: minIndex, maxIndex: maxIndex)))
                }
            }
        }
    }
    

    /*
     * Removes and redraws all polygon overlays (neighborhoods or census tracts) on
     * the map. This is expensive and should be invoked only when the neighborhood/census
     * selection is changed.
     */
    func redrawPolygons() {
        self.map.removeOverlays(self.map.overlays)
        
        for poly in PolygonDAO.getPolygons(self.selectedMap) {
            self.map.addOverlay(poly.overlay!)
        }
        
        reshadeVisiblePolygons()
    }
    
    
    /*
     * Invoke to indicate range of available data years changed (typically the result of
     * selecting a new license type. Sets the current year selection to the midpoint 
     * between available years.
     */
    func yearRangeChanged () {
        yearSelection.maximumValue = Float((license?.latestYear)!)
        yearSelection.minimumValue = Float((license?.earliestYear)!)
        earliestYearLabel.text = license?.earliestYear.description
        latestYearLabel.text = license?.latestYear.description
        
        selectedYear = (license!.earliestYear + license!.latestYear) / 2
        yearSelection.setValue(Float(selectedYear), animated: false)
    }

    /*
     * Shows or hides critical businesses based on the state of the toggle; when visible, 
     * refreshes the data based on current license and year selections.
     */
    private func updateCriticalBusinesses() {
        self.map.removeAnnotations(self.map.annotations)

        if (criticalBusinessSelection.on) {
            CriticalBusinessDAO.getCriticalBusinesses(selectedYear, licenseType: license?.id, onSuccess: { (businesses) in
                for business in businesses {
                    let location = CLLocationCoordinate2DMake(business.lat, business.lng)
                    let pin = MKPointAnnotation()
                    pin.coordinate = location
                    pin.title = business.dbaName
                    
                    self.map.addAnnotation(pin)
                }
            
                }) {
                    // TODO: Handle error case
                    print("Failed to get critical businesses")
            }
        }
    }
    
    
    /*
     * Refreshes business accessibility data given current year, map type and license selections
     * and refreshes the map. When resetPolygons: is true, all polygons (neighborhood/census 
     * boundaries) will be removed and redrawn; set to true only when changing map types.
     */
    private func redrawMap (redrawPolygons: Bool) {
        AccessibilityDAO.getAccessibility(selectedMap, year: selectedYear, licenseType: license?.id, onSuccess:
            { (indexes) in

                switch self.selectedMap {
                case MapType.Neighborhoods:
                    self.neighborhoodIndexes = indexes
                    break
                case MapType.CensusTracts:
                    self.censusIndexes = indexes
                    break
                }
                
                if (redrawPolygons) {
                    self.redrawPolygons()
                } else {
                    self.reshadeVisiblePolygons()
                }
                
                self.updateCriticalBusinesses()
                self.updateSelectionLabel()
            }) {
                // TODO: Handle error case
                print("Fail!")
        }
    }
    
    // MARK: - Data
    
    /*
     * Determines the "accessability index" for the identified boundary (either the neighborhood
     * name like 'LINCOLN PARK' or the normalized census tract number like '0719').
     *
     * The access index is a relative floating point value meaningful only when comparing one
     * area with another. It has no absolute meaning and is not comparable across business
     * licenses or across map types
     */
    private func accessabilityIndexForArea (id: String) -> Double? {
        switch selectedMap {
        case .Neighborhoods:
            return neighborhoodIndexes?[id]
        case .CensusTracts:
            return censusIndexes?[id]
        }
    }
    
    /*
     * Returns the set of polygons whose boundaries intersect the visible region of the map.
     */
    func visiblePolygons() -> [Polygon] {
        var visiblePolygons: [Polygon] = []
        
        for (index, overlay) in map.overlays.enumerate() {
            let polygonRect = overlay.boundingMapRect
            let mapRect = map.visibleMapRect
            if (MKMapRectIntersectsRect(mapRect, polygonRect)) {
                visiblePolygons.append(PolygonDAO.getPolygons(selectedMap)[index])
            }
        }
        
        return visiblePolygons
    }
    
    /*
     * Determines the alpha value (shade) for the given accessability index in the context
     * of given minimum and maximum indicies. 
     *
     * This function will return a value between 0.05 and 0.95 in bucketed amounts determined by 
     * the number alphaBuckets. The intent is to bucket each index so that each polygon/area 
     * drawn on the map is assigned one of 'bucketCount' shades.
     */
    func alphaForAccessibilityIndex (index: Double, minIndex: Double, maxIndex: Double) -> Double {
        let normalizedIndex = (index - minIndex) / (maxIndex - minIndex)
        let bucket = round(normalizedIndex / (1 / bucketCount)) * (1 / bucketCount)
        return (bucket == 0.0) ? 0.05 : (bucket == 1.0) ? 0.95 : bucket
    }
    
    /*
     * Determines the minimum and maximum accessibility indicies present within the given set
     * of polygons.
     */
    func indexRangeForPolygons(polygons: [Polygon], inout minIndex: Double, inout maxIndex: Double) {
        minIndex = Double.infinity
        maxIndex = 0
        
        for polygon in polygons {
            if let accessIndex = accessabilityIndexForArea(polygon.id) {
                if accessIndex < minIndex {
                    minIndex = accessIndex
                }
                
                if accessIndex > maxIndex {
                    maxIndex = accessIndex
                }
            }
        }
    }
}

