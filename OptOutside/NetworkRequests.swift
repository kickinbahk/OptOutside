//
//  NetworkRequests.swift
//  OptOutside
//
//  Created by Josiah Mory on 11/9/17.
//  Copyright © 2017 kickinbahk Productions. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Keys

class NetworkRequests {
    
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
        let upcomingEvents = "upcoming_events=true"
        let resultsNum = "&page=20"
        
        let urlString = "\(meetupURL)\(zipString)\(radiusString)\(keywordsString)\(key)\(sign)\(upcomingEvents)\(resultsNum)"
        let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        print("URL:\(url!)")
        return url!
    }
    
    // MARK: - EINSTEIN REQUESTS
    
    func getActivityDataFromEinstein(activity: String, modelId: String) -> String {
        // Sample call
        // curl -X POST -H "Authorization: Bearer <TOKEN>" -H "Cache-Control: no-cache" -H "Content-Type: multipart/form-data" -F "modelId=WEQ6PHPBGFYVX5C7QDP6XU3NXY" -F "document=what is the weather in los angeles" https://api.einstein.ai/v2/language/intent
        
        let url = "https://api.einstein.ai/v2/language/intent"
        var probableActivity = ""
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(keys.einsteinToken)",
            "Cache-Control": "no-cache",
            
            ]
        
        // Example taken from René Winkelmeyer's Github Example:
        // https://github.com/muenzpraeger/salesforce-einstein-vision-swift/blob/master/SalesforceEinsteinVision/Classes/http/HttpClient.swift
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                let modelId = modelId.data(using: String.Encoding.utf8)
                let document = activity.data(using: String.Encoding.utf8)
                
                multipartFormData.append(modelId!, withName: "modelId")
                multipartFormData.append(document!, withName: "document")
        },
            to: "\(url)",
            method: .post,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):

                    upload.responseString { (request: DataResponse<String>) in
                        let statusCode = NSNumber(value: (request.response?.statusCode)!)
                        debugPrint("ACTIVITY: \(statusCode)")
                        if let dataFromString = request.result.value!.data(using: .utf8, allowLossyConversion: false) {
                            let json = JSON(data: dataFromString)
                            let probableMatch = json["probabilities"][0]["label"].stringValue
                            print(probableMatch)
                            probableActivity = probableMatch
                        }

                    }
                    
                case .failure(let encodingError):
                    print(encodingError)
                }
        })
        return probableActivity
    }
}
