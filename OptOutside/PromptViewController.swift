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

class PromptViewController: UIViewController {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var promptTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    // Meetup categories 9 = Fitness, 11 = Games, 14 = Health & Wellbeing, 15 = Hobbies & Crafts,
    // 17 = Lifestyle, 22 = New Age & Spirituality
    
    let keys = OptOutsideKeys()
    private var results = [Result]()
    private var typeOfEvent: String = ""
    private var whatZip: String = ""
    private var distanceToEvent: String = ""
    private var whichPrompt = Question.what
    let distanceId = "1019156"
    let distanceModelId = "PENJXZ6JJFVCS3JUN5UQLXCEWA"
    let activityId = "1018910"
    let activityModelId = "5VATS6FRNDYHIMIFTOKXMOU2NE"


    private enum Question {
        case what, zip, distance
    }
    
    
    enum BackendError: Error {
        case urlError(reason: String)
        case objectSerialization(reason: String)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        getActivityDataFromEinstein()
        promptLabel.text = Prompts.whatToDo.randomElement
        
    }
    
    @IBAction func next(_ sender: UIButton) {
        switch whichPrompt {
        case .what:
            if let text = promptTextField.text {
                typeOfEvent = text
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
            }
            promptTextField.resignFirstResponder()
            performSearch(zip: 312313123, radius: 5, category: 25) { (results, error)  in
                if let error = error {
                    print(error)
                    return
                }
                guard let results = results else {
                    print("error getting all results: result is nil")
                    return
                }
                self.results = results
                self.showResults(results: results) // Todo: Calling here not ideal since not on main thread
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
    
    private func performSearch(zip: Int, radius: Int, category: Int, completed: @escaping ([Result]?, Error?) -> Void) {
        // Download meetup data
        let url = meetupURL(zipNum: zip, radiusNum: radius, categoryNum: category)
        
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
    
    private func meetupURL(zipNum: Int, radiusNum: Int, categoryNum: Int) -> URL {
        let meetupURL = "https://api.meetup.com/find/groups?"
        let zip = "zip=\(zipNum)"
        let radius = "&radius=\(radiusNum)"
        let category = "&category=\(categoryNum)"
        let key = "&key=\(keys.meetupKey)"
        let sign = "&sign=true"
        
        let urlString = "\(meetupURL)\(zip)\(radius)\(category)\(key)\(sign)"
        let url = URL(string: urlString)
        print("URL:\(url!)")
        return url!
    }
    

    
    private func showResults(results: [Result]) {
        let actionController = CustomSpotifyActionController()
        actionController.settings.cancelView.title = "Start Over"
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
                
                let size = CGSize(width: 15, height: 15)
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
        
        
         present(actionController, animated: true, completion: nil)
    }
    
    private func getActivityDataFromEinstein() {
        let url = "https://api.einstein.ai/v2/language/datasets/"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer HTXIZJ2NJWXK7K5ONYCLZCNFAXIL5XO3OYFRAY566QSWLXLIYFRDOVZY5I5XIPA4PUURQG2MNGOTXAY3IG4QZLGL5LMR5OXB4OT7CBY",
            "Cache-Control": "no-cache",

        ]
        

        
        
        //        curl -X GET -H "Authorization: Bearer HTXIZJ2NJWXK7K5ONYCLZCNFAXIL5XO3OYFRAY566QSWLXLIYFRDOVZY5I5XIPA4PUURQG2MNGOTXAY3IG4QZLGL5LMR5OXB4OT7CBY" -H "Cache-Control: no-cache" https://api.einstein.ai/v2/language/datasets/1018907

        // Example taken from René Winkelmeyer's Github Example:
        // https://github.com/muenzpraeger/salesforce-einstein-vision-swift/blob/master/SalesforceEinsteinVision/Classes/http/HttpClient.swift
        
        Alamofire.request("\(url)\(activityId)", headers: headers).responseJSON { response in
                        debugPrint(response)
        }
        
//        Alamofire.upload(
//            multipartFormData: { multipartFormData in },
//            to: "\(url)\(activityId)",
//            method: .post,
//            headers: headers,
//            encodingCompletion: { encodingResult in
//                switch encodingResult {
//                case .success(let upload, _, _):
//                    upload.responseString { (request: DataResponse<String>) in
//                        debugPrint(request.result)
//
//                        let statusCode = NSNumber(value: (request.response?.statusCode)!)
//                        debugPrint(statusCode)
//                        if let dataFromString = request.result.value!.data(using: .utf8, allowLossyConversion: false) {
//                            debugPrint(dataFromString)
//                        }
//                    }
//
//                case .failure(let encodingError):
//                    print(encodingError)
//                }
//        })
    }
    
}

extension PromptViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hitting return on keyboard also 'clicks' Next button
        next(nextButton)
        return true
    }
}
