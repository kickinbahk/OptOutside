//
//  CustomSpotifyActionController+resetOnCancel.swift
//  OptOutside
//
//  Created by Josiah Mory on 11/7/17.
//  Copyright © 2017 kickinbahk Productions. All rights reserved.
//

import Foundation
import XLActionController

class CustomSpotifyActionController: SpotifyActionController {
    open override func onDidDismissView() {
        // Retained for potential added functionality later
        print("Dismiss View Called")
    }
}
