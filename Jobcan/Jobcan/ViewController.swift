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
    @IBOutlet private weak var statusLabel: NSTextField!
    
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
        sender.isEnabled = false
        statusLabel.stringValue = "通信中…"
        
        guard let punchType = PunchType(rawValue: typeSegmentedControl.selectedSegment) else {
            statusLabel.stringValue = "エラーが発生しました"
            sender.isEnabled = true
            return
        }
        
        DispatchQueue.global().async {
            let pipe = Pipe()
            let file = pipe.fileHandleForReading
            
            let process = Process()
            process.launchPath = "/bin/bash"
            process.arguments = ["-c", "\(self.scriptPathTextField.stringValue) -m \(self.mailAddressTextField.stringValue) -p \(self.passwordTextField.stringValue) -t \(punchType.commandArgument)"]
            process.standardOutput = pipe;
            
            process.launch()
            
            let data = file.readDataToEndOfFile()
            file.closeFile()
            
            DispatchQueue.main.async {
                if let output = String(data: data, encoding: .utf8), output.contains("Succeeded!") {
                    print(output)
                    self.statusLabel.stringValue = "\(punchType.stringValue)しました！"
                } else {
                    self.statusLabel.stringValue = "通信に失敗しました"
                }
                
                sender.isEnabled = true
            }
        }
    }

}

extension ViewController {
    
    enum PunchType: Int {
        case start = 0
        case end = 1
        
        var stringValue: String {
            switch self {
            case .start:
                return "出勤"
            case .end:
                return "退勤"
            }
        }
        
        var commandArgument: String {
            switch self {
            case .start:
                return "start"
            case .end:
                return "end"
            }
        }
    }
    
}

