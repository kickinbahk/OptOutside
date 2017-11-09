//
//  UIImage+crop.swift
//  OptOutside
//
//  Created by Josiah Mory on 11/7/17.
//  Copyright © 2017 kickinbahk Productions. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func crop(to:CGSize) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        let contextSize: CGSize = contextImage.size
        
        //Set to square
        var position: CGPoint = .zero
        let cropAspect: CGFloat = to.width / to.height
        
        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height
        
        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            position.y = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            position.x = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                position.x = (contextSize.width - cropWidth) / 2
            } else { //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                position.y = (contextSize.height - cropHeight) / 2
            }
        }
        
        let rect: CGRect = CGRect(x : position.x, y : position.y, width : cropWidth, height : cropHeight)
        
        // Create bitmap image from context using the rect
        guard let imageRef: CGImage = contextImage.cgImage?.cropping(to: rect)? else {
            return self
        }
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)

        guard !CGSize.zero.equalTo(to) else {
            return self
        }
        
        cropped.draw(in: CGRect(x : 0, y : 0, width : to.width, height : to.height))
        
        return cropped
    }
}
