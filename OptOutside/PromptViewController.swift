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
    var typeOfEvent: String = ""
    var dayOfEvent: String = ""
    var distanceToEvent: String = ""
    var whichPrompt = Question.what //

    
    enum Question {
        case what, when, distance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request("https://api.meetup.com/find/groups?zip=11211&sig_id=\(keys.meetupSIG_ID)"
            + "&radius=1&category=25&sig=\(keys.meetupSIGToken)").responseJSON { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")                         // response serialization result
                
                if let json = response.result.value {
                    print("JSON: \(json)") // serialized json response
                }
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)") // original server data as UTF8 string
                }
        }
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
            showResults()
        }
        promptTextField.text = ""
    }

    private func updatePrompt(newPrompt: String) {
        promptLabel.text = newPrompt
    }
    
    private func showResults() {
        let actionController = SpotifyActionController()
        actionController.headerData = SpotifyHeaderData(title: "The Fast And The Furious Soundtrack Collection",
                                                        subtitle: "Various Artists",
                                                        image: UIImage(named: "image-placeholder")!)
        actionController.addAction(Action(ActionData(title: "Save Full Album",
                                                     image: UIImage(named: "image-placeholder")!),
                                                     style: .default, handler: { action in }))
        actionController.addAction(Action(ActionData(title: "Remove",
                                                     image: UIImage(named: "image-placeholder")!),
                                                     style: .default,
                                                     handler: { action in }))
        actionController.addAction(Action(ActionData(title: "Share",
                                                     image: UIImage(named: "image-placeholder")!),
                                                     style: .default,
                                                     handler: { action in }))
        actionController.addAction(Action(ActionData(title: "Go to Album",
                                                     image: UIImage(named: "image-placeholder")!),
                                                     style: .default,
                                                     handler: { action in }))
        actionController.addAction(Action(ActionData(title: "Start radio",
                                                     image: UIImage(named: "image-placeholder")!),
                                                     style: .default,
                                                     handler: { action in }))
        
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
