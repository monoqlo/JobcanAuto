//
//  ViewController.swift
//  Jobcan
//
//  Created by monoqlo on 2017/05/11.
//  Copyright © 2017年 SmartDrive inc. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {
    
    private let keyForScriptPath = "jobcanScriptPath"
    
    @IBOutlet private weak var scriptPathTextField: NSTextField!
    @IBOutlet private weak var typeSegmentedControl: NSSegmentedControl!
    @IBOutlet private weak var mailAddressTextField: NSTextField!
    @IBOutlet private weak var passwordTextField: NSSecureTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = UserDefaults.standard.value(forKey: keyForScriptPath) as? String {
            scriptPathTextField.stringValue = path
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func saveScriptPath(_ sender: NSButton) {
        UserDefaults.standard.set(scriptPathTextField.stringValue, forKey: keyForScriptPath)
        UserDefaults.standard.synchronize()
    }
    
    @IBAction private func SendRequest(_ sender: NSButton) {
        let type: String
        if typeSegmentedControl.selectedSegment == 0 {
            type = "start"
        } else {
            type = "end"
        }
        
        
        let pipe = Pipe()
        let file = pipe.fileHandleForReading
        
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", "\(scriptPathTextField.stringValue) -m \(mailAddressTextField.stringValue) -p \(passwordTextField.stringValue) -t \(type)"]
        process.standardOutput = pipe;
        
        process.launch()
        
        let data = file.readDataToEndOfFile()
        file.closeFile()
        
        if let output = String(data: data, encoding: .utf8) {
            print(output)
        } else {
            print("error")
        }
    }

}

