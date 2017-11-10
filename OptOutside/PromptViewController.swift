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

class PromptViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var promptTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    let keys = OptOutsideKeys()
    let networkRequests = MeetupNetworkRequests()
    let group = DispatchGroup()
    private var results = [Result]()
    private var typeOfEvent: String = ""
    private var whatZip: String = ""
    private var distanceToEvent: String = ""
    private var whichPrompt = Question.what
    let distanceId = "1019173"
    let distanceModelId = "ITW2WPKETSYEC2GT5V5IDQSJUI"
    let activityId = "1019185"
    let activityModelId = "XP3A7B65FK5UPY7UFHFGWWVKEA"
    var link = ""
    var meetupTitle = ""

    private enum Question {
        case what, zip, distance
    }
    
    


    override func viewDidLoad() {
        super.viewDidLoad()

        promptLabel.text = Prompts.whatToDo.randomElement
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView" {
            let webViewController = segue.destination as! WebViewController
            webViewController.url = link
            webViewController.meetupTitle = meetupTitle
        }
    }
    
    @IBAction func next(_ sender: UIButton) {
        switch whichPrompt {
        case .what:
            if let text = promptTextField.text {
                typeOfEvent = text
                getActivityDataFromEinstein(activity: typeOfEvent, modelId: activityModelId)
                // Get a random element from the array provide a more interactive experience
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
            group.notify(queue: .main) {
                self.networkRequests.performSearch(zip: self.whatZip,
                                              radius: self.distanceToEvent,
                                              keyword: self.typeOfEvent) { (results, error)  in
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
    
    private func showResults(results: [Result]) {
        let actionController = CustomSpotifyActionController()
        actionController.settings.behavior.scrollEnabled = true
        actionController.headerData = SpotifyHeaderData(title: "Results for...",
                                                        subtitle: "\(typeOfEvent), \(whatZip), & \(distanceToEvent)",
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
                                                             handler: { action in
                    self.link = result.link
                    self.meetupTitle = result.name
                    self.performSegue(withIdentifier: "showWebView", sender: nil)
                }))
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
    
    // MARK: - EINSTEIN REQUESTS
    
    private func getActivityDataFromEinstein(activity: String, modelId: String) {
        // Sample call
        // curl -X POST -H "Authorization: Bearer <TOKEN>" -H "Cache-Control: no-cache" -H "Content-Type: multipart/form-data" -F "modelId=WEQ6PHPBGFYVX5C7QDP6XU3NXY" -F "document=what is the weather in los angeles" https://api.einstein.ai/v2/language/intent
        
        let url = "https://api.einstein.ai/v2/language/intent"
        group.enter()
        
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
                            self.typeOfEvent = probableMatch
                            self.group.leave()
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
        group.enter()
        
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
                            self.group.leave()
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
