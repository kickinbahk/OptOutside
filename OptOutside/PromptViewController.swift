//
//  PromptViewController.swift
//  OptOutside
//
//  Created by Josiah Mory on 11/4/17.
//  Copyright © 2017 kickinbahk Productions. All rights reserved.
//

import UIKit

class PromptViewController: UIViewController {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var promptTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var typeOfEvent: String = ""
    var dayOfEvent: String = ""
    var distanceToEvent: String = ""
    var whichPrompt = Question.what

    struct Prompts {
        static let whatToDo: String = "What activities do you like to do?"
        static let whenToDo: String = "When are you planning on doing this?"
        static let howFarAway: String = "How far away would you travel?"
    }
    
    enum Question {
        case what, when, distance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        promptLabel.text = Prompts.whatToDo
    }
    
    @IBAction func next(_ sender: UIButton) {
        switch whichPrompt {
        case .what:
            if let text = promptTextField.text {
                typeOfEvent = text
            }
        case .when:
            if let text = promptTextField.text {
                dayOfEvent = text
            }
        case .distance:
            if let text = promptTextField.text {
                distanceToEvent = text
            }
        }
        promptTextField.text = ""
    }


}

extension PromptViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
