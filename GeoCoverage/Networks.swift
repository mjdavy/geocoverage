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
    let stations: [Station]
}

struct Networks : Codable {
    let networks: [Network]
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
