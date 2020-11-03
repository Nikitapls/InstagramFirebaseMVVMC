//
//  Extensions.swift
//  Instagram_Firebase
//
//  Created by iosDev on 6/12/20.
//  Copyright © 2020 iosDev. All rights reserved.
//

import UIKit
import RxSwift
extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat?, paddingLeft: CGFloat?, paddingBottom: CGFloat?, paddingRight: CGFloat?, width: CGFloat?, height: CGFloat?) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let currentAnchor = top, let padding = paddingTop {
            self.topAnchor.constraint(equalTo: currentAnchor, constant: padding).isActive = true
        }
        
        if let currentAnchor = left, let padding = paddingLeft {
            self.leftAnchor.constraint(equalTo: currentAnchor, constant: padding).isActive = true
        }
        
        if let currentAnchor = bottom, let padding = paddingBottom {
            self.bottomAnchor.constraint(equalTo: currentAnchor, constant: -padding).isActive = true
        }
        
        if let currentAnchor = right, let padding = paddingRight {
            self.rightAnchor.constraint(equalTo: currentAnchor, constant: -padding).isActive = true
        }
        
        if let width = width, width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height, height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
}

extension UIImage {
    static func assetImage(_ imageName: AssetImagesNames) -> UIImage? {
        return UIImage(named: imageName.rawValue)
    }
}

extension UIViewController {
  func presentInFullScreen(_ viewController: UIViewController,
                           animated: Bool,
                           completion: (() -> Void)? = nil) {
    viewController.modalPresentationStyle = .fullScreen
    present(viewController, animated: animated, completion: completion)
  }
}
extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else {
            quotient = secondsAgo / month
            unit = "month"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
        
    }
}
extension Array where Element == PostWithPostImage {
    func sortedByCreationDate(order: ComparisonResult) -> Array<Element> {
        return self.sorted { (lhs, rhs) -> Bool in
            return lhs.post.creationDate.compare(rhs.post.creationDate) == order
        }
    }
}

extension Array where Element == PostWithPostAndUserImage {
    func sortedByCreationDate(order: ComparisonResult) -> Array<Element> {
        return self.sorted { (lhs, rhs) -> Bool in
            return lhs.post.creationDate.compare(rhs.post.creationDate) == order
        }
    }
}

