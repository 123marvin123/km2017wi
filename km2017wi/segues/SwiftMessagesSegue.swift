//
//  SwiftMessagesTopCardSegue.swift
//  km2017wi
//
//  Created by Marvin Haschker on 15.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit
import SwiftMessages

class SwiftMessagesTopCardSegue: SwiftMessagesSegue {
    override public  init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .topCard)
        containerView.cornerRadius = 10
    }
}

class SwiftMessagesMidCardSegue: SwiftMessagesSegue {
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .centered)
        containerView.cornerRadius = 10
    }
}
