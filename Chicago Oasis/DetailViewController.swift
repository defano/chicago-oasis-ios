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

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var mapTypeSelection: UISegmentedControl!
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet weak var earliestYearLabel: UILabel!
    @IBOutlet weak var latestYearLabel: UILabel!
    @IBOutlet weak var criticalBusinessSelection: UISwitch!
    @IBOutlet weak var relativeShadingSelection: UISwitch!
    @IBOutlet weak var yearSelection: UISlider!

    let chicagoLatitude = 41.883229, chicagoLongitude = -87.63239799999999
    let zoomMeters = 10000.0
    
    var selectedYear = 0
    var selectedMap: MapType = MapType.Neighborhoods
    
    var maxIndex: Double?
    var minIndex: Double?
    var neighborhoodIndexes: [String:Double]?
    var censusIndexes: [String:Double]?
    var license: LicenseRecord?
    
    // MARK: - View
    
    override func viewDidAppear(animated: Bool) {
        
        // Possible on iPad devices where detail view is initially shown
        if (license == nil) {
            license = LicenseDAO.licenses[0]
        }
        
        centerMap(CLLocationCoordinate2D(latitude: chicagoLatitude, longitude: chicagoLongitude), latMeters: zoomMeters, lngMeters: zoomMeters)

        map.delegate = self
        map.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMapWasTapped)))

        updateYearRange()
        redrawMap()
    }
    
    @IBAction func onYearSelectionChanged(sender: UISlider) {
        if (self.selectedYear != Int(yearSelection.value)) {
            self.selectedYear = Int(yearSelection.value)
            redrawMap()
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
        
        redrawMap()
    }

    @IBAction func onShowCriticalChanged(sender: AnyObject) {
        // TODO: Implement critical business placemarks
    }
    
    
    @IBAction func onRelativeShadingChanged(sender: AnyObject) {
        // TODO: Implement relative shading
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
                    // TODO: Display demographic data
                    // let clickedId = PolygonDAO.getPolygons(selectedMap)[index].id
                    return
                }
            }
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
    
    // MARK: - UI Response
    
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
    
    func updatePolygons() {
        map.removeOverlays(map.overlays)
        
        for poly in PolygonDAO.getPolygons(selectedMap) {
            self.map.addOverlay(poly.overlay!)
            if let renderer = map.rendererForOverlay(poly.overlay!) as? MKPolygonRenderer, index = getAccessIndexForId(poly.id) {
                renderer.strokeColor = UIColor.whiteColor()
                renderer.lineWidth=2.0
                renderer.fillColor = UIColor(red:0.4, green:0.6, blue:1.0, alpha:CGFloat(getShadeForPolygon(index)))
            }
        }
    }
    
    func updateYearRange() {
        yearSelection.maximumValue = Float((license?.latestYear)!)
        yearSelection.minimumValue = Float((license?.earliestYear)!)
        earliestYearLabel.text = license?.earliestYear.description
        latestYearLabel.text = license?.latestYear.description
        
        selectedYear = (license!.earliestYear + license!.latestYear) / 2
        yearSelection.setValue(Float(selectedYear), animated: false)
    }

    private func redrawMap () {
        AccessabilityDAO.getAccessibility(selectedMap, year: selectedYear, licenseType: license?.id, onSuccess:
            { (indexes, min, max) in
                self.maxIndex = max
                self.minIndex = min
                
                switch self.selectedMap {
                case MapType.Neighborhoods:
                    self.neighborhoodIndexes = indexes
                    break
                case MapType.CensusTracts:
                    self.censusIndexes = indexes
                    break
                }
                
                self.updatePolygons()
                self.updateSelectionLabel()
            }) {
                // TODO: Handle error case
                print("Fail!")
        }
    }
    
    // MARK: - Data
    
    private func getAccessIndexForId (id: String) -> Double? {
        switch selectedMap {
        case .Neighborhoods:
            return neighborhoodIndexes?[id]
        case .CensusTracts:
            return censusIndexes?[id]
        }
    }
    
    func getShadeForPolygon (index: Double) -> Double {
        let bucketCount = 5.0
        let value = (index - minIndex!) / (maxIndex! - minIndex!)
        let bucket = round(value / (1 / bucketCount)) * (1 / bucketCount)
        let alpha = (bucket == 0.0) ? 0.05 : (bucket == 1.0) ? 0.95 : bucket
        return alpha
    }
}

