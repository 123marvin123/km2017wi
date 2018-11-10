//
//  ViewController.swift
//  km2017wi
//
//  Created by Marvin Haschker on 10.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        log.info("Trying to connect...")
        machine.connect(onSuccess: {
            log.info("Successfully connected 😇")
        })
    }



}
