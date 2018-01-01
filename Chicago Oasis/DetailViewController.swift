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
import XCGLogger

class DetailViewController: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {
    
    // Default centerpoint of the displayed map; Chicago Loop
    let chicagoLatitude = 41.870311265875358, chicagoLongitude = -87.68412364213323
    
    let zoomMeters = 20000.0                    // Zoom level of the map; number of meters visible in the longest visible dimension
    let bucketCount = 5.0                       // Number of distinct shades used when coloring the map
    let polygonBorderWidth: CGFloat = 2.0       // Outline stroke width of polygons
    let disabledPolyAlpha: CGFloat = 0.5        // Transparency of disabled (greyed out) polys
    let polygonRedComp: CGFloat = 0.4           // Red color component of shaded polygons
    let polygonGreenComp: CGFloat = 0.6         // Green color component of shaded polygons
    let polygonBlueComp: CGFloat = 1.0          // Blue color component of shaded polygons
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var mapTypeSelection: UISegmentedControl!
    @IBOutlet weak var earliestYearLabel: UILabel!
    @IBOutlet weak var latestYearLabel: UILabel!
    @IBOutlet weak var criticalBusinessSelection: UISwitch!
    @IBOutlet weak var relativeShadingSelection: UISwitch!
    @IBOutlet weak var yearSelection: UISlider!
    
    var selectedYear = 0
    var selectedMap: MapType = MapType.neighborhoods
    
    var neighborhoodIndexes: [String:AccessibilityRecord]?
    var censusIndexes: [String:AccessibilityRecord]?
    var criticalBusinesses: [String:CriticalBusiness] = [:]
    var license: License?
    
    // MARK: - UIViewController
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Possible on iPad devices where detail view is initially shown
        if (license == nil) {
            license = LicenseService.sharedInstance.licenses[0]
        }
        
        let centerCoordinate = CLLocationCoordinate2D(latitude: chicagoLatitude, longitude: chicagoLongitude)
        let visibleRegion = MKCoordinateRegionMakeWithDistance(centerCoordinate, zoomMeters, zoomMeters)
        map.setRegion(map.regionThatFits(visibleRegion), animated: false)
        
        map.delegate = self
        map.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMapWasTapped)))

        yearRangeChanged()
        redrawMap(true)
    }
    
    // MARK: - IB Actions
    
    @IBAction func onYearSelectionChanged(_ sender: UISlider) {
        if (self.selectedYear != Int(round(yearSelection.value))) {
            self.selectedYear = Int(round(yearSelection.value))
            redrawMap(false)
        }
    }
    
    @IBAction func onMapTypeSelectionChanged() {
        switch mapTypeSelection.selectedSegmentIndex {
        case 0:
            self.selectedMap = MapType.neighborhoods
            break;
        default:
            self.selectedMap = MapType.censusTracts
            break;
        }
        
        redrawMap(true)
    }

    @IBAction func onShowCriticalChanged(_ sender: AnyObject) {
        updateCriticalBusinesses()
    }
    
    
    @IBAction func onRelativeShadingChanged(_ sender: AnyObject) {
        reshadeVisiblePolygons()
    }
    
    // MARK: - Map Interaction
    
  @objc func onMapWasTapped (_ tap: UIGestureRecognizer) {
        let tapPoint:CGPoint = tap.location(in: map)
        let tapCoordinate:CLLocationCoordinate2D = map.convert(tapPoint, toCoordinateFrom: map)
        let tapCoordinateRegion: MKCoordinateRegion = MKCoordinateRegionMake(tapCoordinate, MKCoordinateSpanMake(0, 0))
        let touchMapRect: MKMapRect = MKMapRectForCoordinateRegion(tapCoordinateRegion)
        
        for annotation in map.annotations {
            if let annotationView = map.view(for: annotation) {
                let annotationBounds = annotationView.convert(annotationView.bounds, to: map)
                if annotationBounds.intersects(CGRect(x: tapPoint.x, y: tapPoint.y, width: 0, height: 0)) {
                    annotationView.canShowCallout = false
                    annotationWasTapped(annotationView)
                    return
                }
            }
        }
        
        for (index, overlay) in map.overlays.enumerated() {
            if overlay.isKind(of: MKPolygon.self) {
                let polygon:MKPolygon = overlay as! MKPolygon
                if (polygon.intersects(touchMapRect)) {
                    polygonWasTapped(PolygonService.sharedInstance.getPolygons(selectedMap)[index])
                    return
                }
            }
        }
    }
    
    func annotationWasTapped(_ annotationView: MKAnnotationView) {
        let popover = storyboard!.instantiateViewController(withIdentifier: "businessPopover") as! BusinessPopoverController
        
        popover.criticalBusiness = criticalBusinesses[annotationView.annotation!.title!!]

        presentAnnotationPopover(popover, annotation: annotationView)
    }
    
    func polygonWasTapped(_ polygon: Polygon) {
        
        // Instantiate the popover
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var areaPopover: AreaPopoverController
        
        guard accessibilityForArea(polygon.id) != nil else {
            // Nothing to show if no data available for this polygon
            return
        }
        
        if (selectedMap == MapType.neighborhoods) {
            areaPopover = storyboard.instantiateViewController(withIdentifier: "neighborhoodPopover") as! NeighborhoodPopoverController
        } else {
            areaPopover = storyboard.instantiateViewController(withIdentifier: "censusPopover") as! CensusPopoverController
        }
        
        // Initialize it with statistical data
        var minIndex = 0.0, maxIndex = 0.0
        indexRangeForPolygons(PolygonService.sharedInstance.getPolygons(selectedMap), minIndex: &minIndex, maxIndex: &maxIndex)
            
        areaPopover.record = SocioeconomicService.sharedInstance.data[polygon.id]
        areaPopover.accessibilityRecord = accessibilityForArea(polygon.id)
        areaPopover.polygon = polygon
        areaPopover.accessibilityAlpha = alphaForAccessibilityIndex(accessibilityForArea(polygon.id)?.index, minIndex: minIndex, maxIndex: maxIndex)
        areaPopover.selectedYear = Int(yearSelection.value)
        
        // ... and display it
        presentPolygonPopover(areaPopover, polygon: polygon)
    }
    
    func presentAnnotationPopover(_ popover: UIViewController, annotation: MKAnnotationView) {
        
        let anchorPoint = map.convert(annotation.annotation!.coordinate, toPointTo: self.view)
        let anchorRect = CGRect(x: anchorPoint.x, y: anchorPoint.y, width: 0, height: 0)
        
        presentPopover(popover, anchor: anchorRect)
    }
    
    func presentPolygonPopover (_ popover: UIViewController, polygon: Polygon) {
        
        let centroidRect = zeroSizedMapRectForCoordinate(polygon.overlay!.coordinate)
        let centroidMapRect = MKCoordinateRegionForMapRect(centroidRect)
        let centroidViewRect = map.convertRegion(centroidMapRect, toRectTo: self.view)
        
        presentPopover(popover, anchor: centroidViewRect)
    }
    
    func presentPopover (_ popover: UIViewController, anchor: CGRect) {
        popover.modalPresentationStyle = UIModalPresentationStyle.popover

        // Anchor the popover
        popover.popoverPresentationController?.sourceView = self.view
        popover.popoverPresentationController?.sourceRect = anchor
        popover.popoverPresentationController?.delegate = self
        
        self.present(popover, animated: true, completion: nil)
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return .none
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        reshadeVisiblePolygons()
    }
    
    func MKMapRectForCoordinateRegion(_ region: MKCoordinateRegion!) -> MKMapRect {
        let a:MKMapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta / 2, region.center.longitude - region.span.longitudeDelta / 2))
        
        let b:MKMapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta / 2, region.center.longitude + region.span.longitudeDelta / 2))
        
        return MKMapRectMake(min(a.x, b.x), min(a.y,b.y), abs(a.x-b.x), abs(a.y-b.y))
    }
    
    func zeroSizedMapRectForCoordinate (_ point: CLLocationCoordinate2D) -> MKMapRect {
        let p1 = MKMapPointForCoordinate (point);
        let p2 = MKMapPointForCoordinate (point);
        
        return MKMapRectMake(fmin(p1.x,p2.x), fmin(p1.y,p2.y), fabs(p1.x-p2.x), fabs(p1.y-p2.y));
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polygonView = MKPolygonRenderer(overlay: overlay)
        
        // By default, area polys are shaded grey; if they don't change color its because we're missing data
        polygonView.strokeColor = UIColor.gray
        polygonView.lineWidth = polygonBorderWidth
        polygonView.fillColor = UIColor.gray.withAlphaComponent(disabledPolyAlpha)
        
        return polygonView
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for thisAnnotationView in views {
            thisAnnotationView.canShowCallout = false
        }
    }
    
    // MARK: - UI Updates
    
    /*
     * Updates the selection label (at the top of the map) to represent current selections.
     */
    private func updateSelectionLabel() {
        self.navigationItem.title = "\((license?.title)!) - \(selectedYear)"
    }
    
    /*
     * Reshades (colors) polygons visible on the map using current data selections
     */
    func reshadeVisiblePolygons() {
        let visiblePolygons = self.visiblePolygons()
        let activePolygons = self.relativeShadingSelection.isOn ? visiblePolygons : PolygonService.sharedInstance.getPolygons(self.selectedMap)
      
        var minIndex = 0.0, maxIndex = 0.0
      
        self.indexRangeForPolygons(activePolygons, minIndex: &minIndex, maxIndex: &maxIndex)
      
        for poly in visiblePolygons {
            if let renderer = self.map.renderer(for: poly.overlay!) as? MKPolygonRenderer, let index = self.accessibilityForArea(poly.id)?.index {
                renderer.strokeColor = UIColor.white
                renderer.lineWidth=2.0
                renderer.fillColor = UIColor(red:self.polygonRedComp, green:self.polygonGreenComp, blue:self.polygonBlueComp, alpha:CGFloat(self.alphaForAccessibilityIndex(index, minIndex: minIndex, maxIndex: maxIndex)))
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
        
        for poly in PolygonService.sharedInstance.getPolygons(self.selectedMap) {
            self.map.add(poly.overlay!)
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
        
        selectedYear = (license!.earliestYear + license!.latestYear) / 2        // Initialize selection midway through available data
        yearSelection.setValue(Float(selectedYear), animated: true)
    }

    /*
     * Shows or hides critical businesses based on the state of the toggle; when visible, 
     * refreshes the data based on current license and year selections.
     */
    private func updateCriticalBusinesses() {
        self.map.removeAnnotations(self.map.annotations)

        if (criticalBusinessSelection.isOn) {
            CriticalBusinessService.sharedInstance.getCriticalBusinesses(selectedYear, licenseType: (license?.id)!, onSuccess: { (businesses) in
                
                self.criticalBusinesses = [:]
                for business in businesses {
                    let location = CLLocationCoordinate2DMake(business.lat, business.lng)
                    let pin = MKPointAnnotation()
                    
                    pin.coordinate = location
                    pin.title = business.dbaName
                    
                    self.criticalBusinesses[business.dbaName] = business
                    self.map.addAnnotation(pin)
                }
            
                }) {
                    logger.error("Failed to get critical businesses.")
            }
        }
    }
    
    /*
     * Refreshes business accessibility data given current year, map type and license selections
     * and refreshes the map. When resetPolygons: is true, all polygons (neighborhood/census 
     * boundaries) will be removed and redrawn; set to true only when changing map types.
     */
    private func redrawMap (_ redrawPolygons: Bool) {
        AccessibilityService.sharedInstance.getAccessibility(selectedMap, year: selectedYear, licenseType: (license?.id)!, onSuccess:
            { (indexes) in

                switch self.selectedMap {
                case MapType.neighborhoods:
                    self.neighborhoodIndexes = indexes
                    break
                case MapType.censusTracts:
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
              logger.error("Failed to get accessibility data for \(self.selectedMap) in year \(self.selectedYear) for license type \(self.license?.id ?? "(Unknown)")")
        }
    }
    
    // MARK: - Data Utilities
    
    /*
     * Determines the "accessability index" for the identified boundary (either the neighborhood
     * name like 'LINCOLN PARK' or the normalized census tract number like '0719').
     *
     * The access index is a relative floating point value meaningful only when comparing one
     * area with another. It has no absolute meaning and is not comparable across business
     * licenses or across map types
     */
    private func accessibilityForArea (_ id: String?) -> AccessibilityRecord? {
        guard id != nil else {
            return nil
        }
        
        switch selectedMap {
        case .neighborhoods:
            return neighborhoodIndexes?[id!]
        case .censusTracts:
            return censusIndexes?[id!]
        }
    }
    
    /*
     * Returns the set of polygons whose boundaries intersect the visible region of the map.
     */
    func visiblePolygons() -> [Polygon] {
        var visiblePolygons: [Polygon] = []
        
        for (index, overlay) in map.overlays.enumerated() {
            let polygonRect = overlay.boundingMapRect
            let mapRect = map.visibleMapRect
            if (MKMapRectIntersectsRect(mapRect, polygonRect)) {
                visiblePolygons.append(PolygonService.sharedInstance.getPolygons(selectedMap)[index])
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
    func alphaForAccessibilityIndex (_ index: Double?, minIndex: Double, maxIndex: Double) -> Double {        
        guard index != nil else {
            return 0.0
        }
        
        let penetration = (index! - minIndex) / (maxIndex - minIndex)
        let bucket = round(penetration / (1 / bucketCount)) * (1 / bucketCount)
        return (bucket == 0.0) ? 0.05 : (bucket == 1.0) ? 0.95 : bucket
    }
    
    /*
     * Determines the minimum and maximum accessibility indicies present within the given set
     * of polygons.
     */
    func indexRangeForPolygons(_ polygons: [Polygon], minIndex: inout Double, maxIndex: inout Double) {
        minIndex = Double.infinity
        maxIndex = 0
        
        for polygon in polygons {
            if let accessIndex = accessibilityForArea(polygon.id)?.index {
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

