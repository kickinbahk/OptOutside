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

class PromptViewController: UIViewController {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var promptTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var typeOfEvent: String = ""
    var dayOfEvent: String = ""
    var distanceToEvent: String = ""
    var whichPrompt = Question.what
    let keys = OptOutsideKeys()
    
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
                updatePrompt(newPrompt: Prompts.whenToDo.randomElement)
            }
            whichPrompt = .when
        case .when:
            if let text = promptTextField.text {
                dayOfEvent = text
                updatePrompt(newPrompt: Prompts.howFarAway.randomElement)
            }
            nextButton.setTitle("Get Results", for: .normal)
            whichPrompt = .distance
        case .distance:
            if let text = promptTextField.text {
                distanceToEvent = text
            }
            promptTextField.resignFirstResponder()
        }
        promptTextField.text = ""
    }

    private func updatePrompt(newPrompt: String) {
        promptLabel.text = newPrompt
    }
}

extension PromptViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        next(nextButton)
        return true
    }
}
