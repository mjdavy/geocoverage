//
//  Networks.swift
//  GeoCoverage
//
//  Created by Martin Davy on 10/7/23.
//

import Foundation
import MapKit

private let baseNetworksUrl = "https://api.citybik.es"
private let bikeNetworksUrl = baseNetworksUrl + "/v2/networks"
private let defaultUrl = "https://api.citybik.es/v2/networks/blue-bikes"


struct Network : Codable {
    let id: String
    let href : String
    
    struct Station : Codable {
        let id: String
        let latitude: Double
        let longitude: Double
    }
    struct Location: Codable {
        var city: String
        var country: String
        var latitude: Double
        var longitude: Double
    }
    let stations: [Station]
    let location: Location
}

struct NetworkInfo : Codable {
    let id: String
    let href : String
}

struct Networks : Codable {
    let networks: [NetworkInfo]
}


@Observable class Boundaries : Identifiable
{
    var boundaries: [MKPolygon] = []
}

func loadBikesData<T: Decodable>(fromNetworkUrl source: String, completion: @escaping (T?, Error?) -> Void) {
   guard let url = URL(string: source) else {
       completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
       return
   }
   
   let task = URLSession.shared.dataTask(with: url) { data, response, error in
       guard let data = data, error == nil else {
           completion(nil, error)
           return
       }
       
       do {
           print("decoding json data...")
           print(T.self)
           let decoder = JSONDecoder()
           let result = try decoder.decode(T.self, from: data)
           completion(result, nil)
       } catch {
           completion(nil, error)
       }
   }
   
   task.resume()
}

func generateGeoJSON(for polygons: [MKPolygon]) -> String {
    var coordinates: [[[[Double]]]] = []
    
    for polygon in polygons {
        var polygonCoordinates: [[Double]] = []
        
        let points = polygon.points()
        for i in 0..<polygon.pointCount {
            let coordinate = points[i].coordinate
            polygonCoordinates.append([coordinate.longitude, coordinate.latitude])
        }
        coordinates.append([polygonCoordinates])
    }
    
    let geoJSON: [String: Any] = [
        "type": "MultiPolygon",
        "coordinates": coordinates
    ]
    
    do {
        let data = try JSONSerialization.data(withJSONObject: geoJSON, options: [])
        let string = String(data: data, encoding: .utf8)!
        return string
    } catch {
        print("Error generating GeoJSON: \(error)")
        return ""
    }
}

func boundingRect(for stations: [Network.Station]) -> MKPolygon {
    var minX = stations[0].longitude
    var maxX = stations[0].longitude
    var minY = stations[0].latitude
    var maxY = stations[0].latitude
    
    for station in stations {
        if station.longitude < minX {
            minX = station.longitude
        }
        if station.longitude > maxX {
            maxX = station.longitude
        }
        if station.latitude < minY {
            minY = station.latitude
        }
        if station.latitude > maxY {
            maxY = station.latitude
        }
    }
    
    let topLeft = CLLocationCoordinate2D(latitude: maxY, longitude: minX)
    let topRight = CLLocationCoordinate2D(latitude: maxY, longitude: maxX)
    let bottomRight = CLLocationCoordinate2D(latitude: minY, longitude: maxX)
    let bottomLeft = CLLocationCoordinate2D(latitude: minY, longitude: minX)
    
    let coordinates = [topLeft, topRight, bottomRight, bottomLeft, topLeft]
    let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
    return polygon
}

private func processNetwork(href:String, boundaries:Boundaries)
{
    let url = baseNetworksUrl + href
    print("processing: \(url) ...")
    loadBikesData(fromNetworkUrl: url) { (networkMap: [String:Network]?, error: Error?) in
        if let networkMap = networkMap {
            if let network = networkMap["network"] {
                if network.location.city.contains("Moscow"){
                    print("getting boundary for: \(network.id)")
                    if !network.stations.isEmpty
                    {
                        let polygon = boundingRect(for: network.stations)
                        DispatchQueue.main.async {
                            boundaries.boundaries.append(polygon)
                        }
                    }
                }
            }
        }
    }
}


func load(boundaries: Boundaries)
{
    loadBikesData(fromNetworkUrl: bikeNetworksUrl) { (networkInfo: [String:[NetworkInfo]]?, error: Error?) in
        if let networkInfo = networkInfo {
            if let networks = networkInfo["networks"] {
                print("loaded \(networks.count) networks")
                for network in networks {
                    print("\(network.id), \(network.href)")
                    processNetwork(href: network.href, boundaries: boundaries)
                }
            }
        }
        else {
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                print("load failed - no further information")
            }
        }
    }
}
