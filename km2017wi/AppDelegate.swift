//
//  AppDelegate.swift
//  km2017wi
//
//  Created by Marvin Haschker on 10.11.18.
//  Copyright © 2018 Marvin Haschker. All rights reserved.
//

import UIKit
import SwiftyBeaver

let log = SwiftyBeaver.self
let machine = Machine()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let console = ConsoleDestination()
        let file = FileDestination()

        console.format = "$DHH:mm:ss$d $L $M $X"
        console.levelString.verbose = "👻 VERBOSE"
        console.levelString.debug = "🤔 DEBUG"
        console.levelString.info = "🙂 INFO"
        console.levelString.warning = "😱 WARNING"
        console.levelString.error = "💥 ERROR"

        log.addDestination(console)
        log.addDestination(file)
        return true
    }


    func applicationWillResignActive(_ application: UIApplication) {

    }


    func applicationDidEnterBackground(_ application: UIApplication) {

    }


    func applicationWillEnterForeground(_ application: UIApplication) {

    }


    func applicationDidBecomeActive(_ application: UIApplication) {

    }


    func applicationWillTerminate(_ application: UIApplication) {

    }



}
