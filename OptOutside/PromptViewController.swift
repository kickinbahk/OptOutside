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
    private var typeOfEvent: String = ""
    private var dayOfEvent: String = ""
    private var distanceToEvent: String = ""
    private var whichPrompt = Question.what //

    
    enum Question {
        case what, when, distance
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
            showResults()
        }
        promptTextField.text = ""
    }

    private func updatePrompt(newPrompt: String) {
        promptLabel.text = newPrompt
    }
    
    private func performSearch() {
        
    }
    
    private func meetupURL(zipNum: Int, radiusNum: Int, categoryNum: Int) -> URL {
        let meetupURL = "https://api.meetup.com/find/groups?"
        let zip = "zip=\(zipNum)"
        let radius = "&\(radiusNum)"
        let category = "&\(categoryNum)"
        let sigToken = "&sig=\(keys.meetupSIGToken)"
        let sigID = "&sig_id=\(keys.meetupSIG_ID)"
        
        let urlString = "\(meetupURL)\(zip)\(sigToken)\(sigID)\(radius)\(category)"
        let url = URL(string: urlString)
        print("URL:\(url!)")
        return url!
    }
    
    private func showResults() {
        let url = URL(string: "https://secure.meetupstatic.com/photos/member/5/c/a/a/thumb_45923722.jpeg")
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch

        let actionController = SpotifyActionController()
        actionController.settings.cancelView.title = "Start Over"
        actionController.settings.behavior.scrollEnabled = true
        actionController.headerData = SpotifyHeaderData(title: "Results for...",
                                                        subtitle: "\(typeOfEvent), \(dayOfEvent) within \(distanceToEvent) miles",
                                                        image: UIImage(named: "image-placeholder")!)
        actionController.addAction(Action(ActionData(title: "Save Full Album",
                                                     image: UIImage(data: data!)!),
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
