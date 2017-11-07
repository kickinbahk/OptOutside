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
    
    let keys = OptOutsideKeys()
    private var results = [Result]()
    private var typeOfEvent: String = ""
    private var dayOfEvent: String = ""
    private var distanceToEvent: String = ""
    private var whichPrompt = Question.what
    
    private enum Question {
        case what, when, distance
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
                updatePrompt(newPrompt: Prompts.whenToDo.randomElement)
            }
            whichPrompt = .when
        case .when:
            if let text = promptTextField.text {
                dayOfEvent = text
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
            performSearch(zip: 11211, radius: 5, category: 25) { (results, error)  in
                if let error = error {
                    print(error)
                    return
                }
                guard let results = results else {
                    print("error getting all results: result is nil")
                    return
                }
                
                for result in results {
                    print(result)
                }
                
                print(results)
                print(results.count)
                self.results = results
            }
            showResults(results: results)
            whichPrompt = Question.what
            promptLabel.text = Prompts.whatToDo.randomElement
            nextButton.setTitle("Next", for: .normal)
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
        let sigToken = "&sig=\(keys.meetupSIGToken)"
        let sigID = "&sig_id=\(keys.meetupSIG_ID)"
        
        let urlString = "\(meetupURL)\(zip)\(sigToken)\(sigID)\(radius)\(category)"
        let url = URL(string: urlString)
        print("URL:\(url!)")
        return url!
    }
    
    private func showResults(results: [Result]) {
        let actionController = CustomSpotifyActionController()
        actionController.settings.cancelView.title = "Start Over"
        actionController.settings.behavior.scrollEnabled = true
        actionController.headerData = SpotifyHeaderData(title: "Results for...",
                                                        subtitle: "\(typeOfEvent), \(dayOfEvent) within \(distanceToEvent) miles",
                                                        image: UIImage(named: "image-placeholder")!)
        for result in results {
            var groupImage = UIImage()
            if let imageURL = result.group_photo?.thumb_link {
                if let image = try? Data(contentsOf: URL(string: imageURL)!) {
                    groupImage = UIImage(data: image)!
                }
            } else {
                groupImage = UIImage(named: "image-placeholder-sm")!
            }

            actionController.addAction(Action(ActionData(title: "\(result.name)",
                                                         image: groupImage),
                                                         style: .default,
                                                         handler: { action in }))
        }
        
        
         present(actionController, animated: true, completion: nil)
    }
    
    
}

extension PromptViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hitting return on keyboard also 'clicks' Next button
        next(nextButton)
        return true
    }
}
