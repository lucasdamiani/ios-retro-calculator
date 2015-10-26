//
//  ViewController.swift
//  Retro Calculator
//
//  Created by Lucas Damiani on 25/10/15.
//  Copyright © 2015 Lucas Damiani. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var outputLabel: UILabel!
    
    private var displayText = "" {
        didSet {
            outputLabel.text = displayText
        }
    }
    
    private var displayValue: Double? {
        get {
            return Double(displayText)
        }
        set {
            if let value = newValue {
                displayText = "\(value)"
            }
        }
    }
    
    private lazy var buttonPressedSound: AVAudioPlayer? = {
        let path = NSBundle.mainBundle().pathForResource("buttonPressed", ofType: "wav")
        let soundUrl = NSURL(fileURLWithPath: path!)
        
        do {
            let player = try AVAudioPlayer(contentsOfURL: soundUrl)
            player.prepareToPlay()
            
            return player
        } catch {
            return nil
        }
    }()
    
    // should be refactored in the future to use enums.
    typealias Operation = (Double, Double) -> Double
    private let knownOperations: [String : Operation] = {
        var operations = [String : Operation]()
        operations["add"] = {$0 + $1}
        operations["subtract"] = {$0 - $1}
        operations["multiply"] = {$0 * $1}
        operations["divide"] = {$0 / $1}
        
        return operations
    }()
    
    private var userIsInTheMiddleOfTyping = false
    private var operand1: Double = 0
    private var operand2: Double = 0
    private var currentOperation: Operation?
    
    @IBAction func onNumberPressed(sender: UIButton!) {
        playSound()
        let digit = "\(sender.tag)"
        
        if userIsInTheMiddleOfTyping {
            displayText += digit
        } else {
            displayText = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func onOperationPressed(sender: UIButton) {
        playSound()
        
        if let operand = displayValue, button = sender as? UIButtonWithStringTag, operationIdentifier = button.stringTag {
            operand1 = operand
            userIsInTheMiddleOfTyping = false
            currentOperation = knownOperations[operationIdentifier]
        }
    }
    
    @IBAction func onEqualPressed() {
        playSound()
        
        if let operand = displayValue, operation = currentOperation {
            operand2 = operand
            displayValue = operation(operand1, operand2)
            userIsInTheMiddleOfTyping = false
        }
    }
    
    @IBAction func onClear() {
        userIsInTheMiddleOfTyping = false
        operand1 = 0
        operand2 = 0
        currentOperation = nil
        displayText = ""
    }
    
    private func playSound() {
        buttonPressedSound?.play()
    }
    
}

