//
//  MeetupNetworkRequests.swift
//  OptOutside
//
//  Created by Josiah Mory on 11/9/17.
//  Copyright © 2017 kickinbahk Productions. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Keys

class MeetupNetworkRequests {
    
    let keys = OptOutsideKeys()
    
    enum BackendError: Error {
        case urlError(reason: String)
        case objectSerialization(reason: String)
    }
    
    func performSearch(zip: String, radius: String, keyword: String, completed: @escaping ([Result]?, Error?) -> Void) {
        // Download meetup data
        let url = meetupURL(zip: zip, radius: radius, keywords: keyword)
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completed(nil, error!)
                return
            }
            
            guard let responseData = data else {
                print("Error: did not receive data")
                let error = BackendError.objectSerialization(reason: "No data in response")
                completed(nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                
                let results = try decoder.decode([Result].self, from: responseData)
                completed(results, nil)
            } catch {
                print("error trying to convert data to JSON")
                print(error)
            }
        }
        task.resume()
    }
    
    func meetupURL(zip: String, radius: String, keywords: String) -> URL {
        let meetupURL = "https://api.meetup.com/find/groups?"
        let zipString = "zip=\(zip)"
        let radiusString = "&radius=\(radius)"
        let keywordsString = "&keywords=\(keywords)"
        let key = "&key=\(keys.meetupKey)"
        let sign = "&sign=true"
        let resultsNum = "&page=20"
        
        let urlString = "\(meetupURL)\(zipString)\(radiusString)\(keywordsString)\(key)\(sign)\(resultsNum)"
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        print("URL:\(url!)")
        return url!
    }
    
}
