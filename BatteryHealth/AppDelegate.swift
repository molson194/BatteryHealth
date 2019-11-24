//
//  AppDelegate.swift
//  BatteryHealth
//
//  Created by Matthew Olson on 10/1/19.
//  Copyright © 2019 Molson. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    var statusBarItem: NSStatusItem!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(
            withLength: NSStatusItem.squareLength)
        statusBarItem.button?.title = "⚡️"

        let statusBarMenu = NSMenu(title: "Cap Status Bar Menu")
        statusBarItem.menu = statusBarMenu
        
        var timeRemaining = 0
        var maxCapacity = 0
        var designCapacity = 0
        var designCycleCount = 0
        var cycleCount = 0
        
        let batteryStatsString = shell("ioreg -irc IOPMPowerSource")
        let batteryStatsSplit = batteryStatsString.split(separator: "\n")
        for line in batteryStatsSplit {
            print(line)
            print("------------------------")
            
            if line.contains("TimeRemaining") {
                timeRemaining = Int(String(line).components(separatedBy: " = ")[1]) ?? 0
            } else if line.contains("MaxCapacity") {
                maxCapacity = Int(String(line).components(separatedBy: " = ")[1]) ?? 0
            } else if line.contains("DesignCapacity\" = ") {
                designCapacity = Int(String(line).components(separatedBy: " = ")[1]) ?? 0
            } else if line.contains("DesignCycleCount") {
                designCycleCount = Int(String(line).components(separatedBy: " = ")[1]) ?? 0
            } else if line.contains("CycleCount\" =") {
                cycleCount = Int(String(line).components(separatedBy: " = ")[1]) ?? 0
            }
        }
        
        print(String(timeRemaining))
        print(String(maxCapacity))
        print(String(designCapacity))
        print(String(designCycleCount))
        print(String(cycleCount))
        
        if (timeRemaining == 0) && (maxCapacity == 0) && (designCapacity == 0) && (designCycleCount == 0) && (cycleCount == 0) {
            statusBarMenu.addItem(
                withTitle: "Battery Information Not Available",
                action: nil,
                keyEquivalent: "")
        } else {
            // TODO: Rows about battery
            let maxCap = (Float(maxCapacity) * 100 / Float(designCapacity)).rounded()
            var health = "Healthy"
            if (cycleCount > designCycleCount) || (maxCap < 70) {
                health = "Unhealthy"
            }
            
            let view = NSTextField(string:"  Battery Status = " + health + "\n  Charge Cycles = " + String(cycleCount) + "\n  Maximum Capacity = " + String(maxCap).components(separatedBy: ".")[0] + "%")
            

            let menuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
            menuItem.view = view
            
            statusBarMenu.addItem(menuItem)
        }
        
        statusBarMenu.addItem(
            withTitle: "Quit",
            action: #selector(AppDelegate.quit),
            keyEquivalent: "")
        
    }
    
    func shell(_ command: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

        return output
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

