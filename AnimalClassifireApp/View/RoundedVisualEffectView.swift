//
//  RoundedVisualEffectView.swift
//  AnimalClassifireApp
//
//  Created by MacBook Pro on 8/20/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit

class RoundedVisualEffectView: UIVisualEffectView {

    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner]
        self.clipsToBounds = true
        
    }

}
