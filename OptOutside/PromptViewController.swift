//
//  PromptViewController.swift
//  OptOutside
//
//  Created by Josiah Mory on 11/4/17.
//  Copyright © 2017 kickinbahk Productions. All rights reserved.
//

import UIKit
import Alamofire
import Keys
import XLActionController
import SwiftyJSON

class PromptViewController: UIViewController {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var promptTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    let keys = OptOutsideKeys()
    private var results = [Result]()
    private var typeOfEvent: String = ""
    private var whatZip: String = ""
    private var distanceToEvent: String = ""
    private var whichPrompt = Question.what
    let distanceId = "1019173"
    let distanceModelId = "ITW2WPKETSYEC2GT5V5IDQSJUI"
    let activityId = "1019185"
    let activityModelId = "XP3A7B65FK5UPY7UFHFGWWVKEA"

    private enum Question {
        case what, zip, distance
    }
    
    
    enum BackendError: Error {
        case urlError(reason: String)
        case objectSerialization(reason: String)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        promptLabel.text = Prompts.whatToDo.randomElement
        
    }
    
    @IBAction func next(_ sender: UIButton) {
        switch whichPrompt {
        case .what:
            if let text = promptTextField.text {
                typeOfEvent = text
                // Get a random element from the array provide a more interactive experience
                getActivityDataFromEinstein(activity: typeOfEvent, modelId: activityModelId)
                updatePrompt(newPrompt: Prompts.whatIsZip.randomElement)
            }
            whichPrompt = .zip
        case .zip:
            if let text = promptTextField.text {
                whatZip = text
                updatePrompt(newPrompt: Prompts.howFarAway.randomElement)
            }
            // Change button to indicate last question
            nextButton.setTitle("Get Results", for: .normal)
            whichPrompt = .distance
        case .distance:
            if let text = promptTextField.text {
                distanceToEvent = text
                getDistanceDataFromEinstein(distance: distanceToEvent, modelId: distanceModelId)
            }
            promptTextField.resignFirstResponder()
            performSearch(zip: whatZip, radius: "5", keyword: typeOfEvent) { (results, error)  in
                if let error = error {
                    print(error)
                    return
                }
                guard let results = results else {
                    print("error getting all results: result is nil")
                    return
                }
                DispatchQueue.main.async {
                    self.results = results
                    self.showResults(results: results)
                }
            }
            self.whichPrompt = Question.what
            self.promptLabel.text = Prompts.whatToDo.randomElement
            self.nextButton.setTitle("Next", for: .normal)
        }
        promptTextField.text = ""
    }

    private func updatePrompt(newPrompt: String) {
        promptLabel.text = newPrompt
    }
    
    private func performSearch(zip: String, radius: String, keyword: String, completed: @escaping ([Result]?, Error?) -> Void) {
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
    
    private func meetupURL(zip: String, radius: String, keywords: String) -> URL {
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
    

    
    private func showResults(results: [Result]) {
        let actionController = CustomSpotifyActionController()
        actionController.settings.behavior.scrollEnabled = true
        actionController.headerData = SpotifyHeaderData(title: "Results for...",
                                                        subtitle: "\(typeOfEvent), \(whatZip) within \(distanceToEvent) miles",
                                                        image: UIImage(named: "image-placeholder")!)
        if results.count > 0 {
            for result in results {
                var groupImage = UIImage()
                if let imageURL = result.group_photo?.thumb_link {
                    if let image = try? Data(contentsOf: URL(string: imageURL)!) {
                        groupImage = UIImage(data: image)!
                    }
                } else {
                    groupImage = UIImage(named: "image-placeholder-sm")!
                }
                
                let size = CGSize(width: 44, height: 44)
                actionController.addAction(Action(ActionData(title: "\(result.name)",
                                                             image: groupImage.crop(to: size)),
                                                             style: .default,
                                                             handler: { action in }))
            }
        } else {
            actionController.addAction(Action(ActionData(title: "No Results",
                                                         image: UIImage(named: "image-placeholder-sm")!),
                                                         style: .default,
                                                         handler: { action in }))
        }
        
        actionController.settings.cancelView.title = "Change phrase for different results..."
        present(actionController, animated: true, completion: nil)
    }
    
    private func getActivityDataFromEinstein(activity: String, modelId: String) {
        // Sample call
        // curl -X POST -H "Authorization: Bearer <TOKEN>" -H "Cache-Control: no-cache" -H "Content-Type: multipart/form-data" -F "modelId=WEQ6PHPBGFYVX5C7QDP6XU3NXY" -F "document=what is the weather in los angeles" https://api.einstein.ai/v2/language/intent
        
        let url = "https://api.einstein.ai/v2/language/intent"
        
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
                        debugPrint(statusCode)
                        if let dataFromString = request.result.value!.data(using: .utf8, allowLossyConversion: false) {
                            let json = JSON(data: dataFromString)
                            let probableMatch = json["probabilities"][0]["label"].stringValue
                            print(probableMatch)
                            self.typeOfEvent = probableMatch
                        }
                    }

                case .failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
    private func getDistanceDataFromEinstein(distance: String, modelId: String) {
        // Sample call
        // curl -X POST -H "Authorization: Bearer <TOKEN>" -H "Cache-Control: no-cache" -H "Content-Type: multipart/form-data" -F "modelId=WEQ6PHPBGFYVX5C7QDP6XU3NXY" -F "document=what is the weather in los angeles" https://api.einstein.ai/v2/language/intent
        
        let url = "https://api.einstein.ai/v2/language/intent"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(keys.einsteinToken)",
            "Cache-Control": "no-cache",
            
            ]
        
        // Example taken from René Winkelmeyer's Github Example:
        // https://github.com/muenzpraeger/salesforce-einstein-vision-swift/blob/master/SalesforceEinsteinVision/Classes/http/HttpClient.swift
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                let modelId = modelId.data(using: String.Encoding.utf8)
                let document = distance.data(using: String.Encoding.utf8)
                
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
                        debugPrint(statusCode)
                        if let dataFromString = request.result.value!.data(using: .utf8, allowLossyConversion: false) {
                            let json = JSON(data: dataFromString)
                            let probableMatch = json["probabilities"][0]["label"].stringValue
                            print(probableMatch)
                            self.distanceToEvent = probableMatch
                        }
                    }
                    
                case .failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
}

extension PromptViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hitting return on keyboard also 'clicks' Next button
        next(nextButton)
        return true
    }
}
