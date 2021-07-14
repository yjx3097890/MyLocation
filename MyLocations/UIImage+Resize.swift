//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by yan jixian on 2021/7/14.
//

import UIKit

extension UIImage {
    func resized(withBounds bounds: CGSize) -> UIImage {
        let hRatio = bounds.width / size.width
        let vRatio = bounds.height / size.height
        //  aspect fit: 显式图像所有部分
        let ratio = min(hRatio, vRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
