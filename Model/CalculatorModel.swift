//
//  CalculatorModel.swift
//  CountOnMe
//
//  Created by FrancoisDev on 07/06/2023.
//  Copyright © 2023 Vincent Saluzzo. All rights reserved.
//

import Foundation

// YouTube: LetsBuildThatApp - Delegate Swift How it works
// How to implement delegate swift

// Gérer les priorités des opérations
// Ajouter la virgule
// Gestion des nombres négatifs?

protocol CalculatorModelDelegate: AnyObject {
    func textHasBeenAdded(text: String)
    func resetText()
    func showAlert(title: String, message: String)
}

class CalculatorModel {
    
    private var text: String = ""
    
    private weak var delegate: CalculatorModelDelegate?
    
    init(delegate: CalculatorModelDelegate?) {
        self.delegate = delegate
    }
    
    private var elements: [String] {
        return text.split(separator: " ").map { "\($0)" }
    }
    
    private var expressionIsCorrect: Bool {
        return elements.last != "+" && elements.last != "-"
    }
    
    private var expressionHaveEnoughElement: Bool {
        return elements.count >= 3
    }
    
    private var canAddOperator: Bool {
        return elements.last != "+" && elements.last != "-" && elements.last != "*" && elements.last != "/"
    }
    
    private var expressionHaveResult: Bool {
        return text.firstIndex(of: "=") != nil
    }
}

// MARK: - Public Interface

extension CalculatorModel {
    
    func add(number: String) {
        if expressionHaveResult {
            self.text = ""
            self.delegate?.resetText()
        }
        self.text.append(number)
        self.delegate?.textHasBeenAdded(text: number)
    }
    
    func add(sign: String) {
        if canAddOperator {
            text.append(" \(sign) ")
            delegate?.textHasBeenAdded(text: " \(sign) ")
        } else {
            delegate?.showAlert(
                title: "}!",
                message: "Un operateur est déja mis !"
            )
        }
    }
    
    func equal() {
        guard expressionIsCorrect else {
            delegate?.showAlert(
                title: "Zéro!",
                message: "Entrez une expression correcte !"
            )
            return
        }
        
        guard expressionHaveEnoughElement else {
            delegate?.showAlert(
                title: "Zéro!",
                message: "Démarrez un nouveau calcul !"
            )
            return
        }
        
        calculateResult()
    }
    
    func clear() {
        text = ""
        delegate?.resetText()
    }
}

// MARK: - Convenience Methods

extension CalculatorModel {
    
    private func calculateResult() {
        var operationsToReduce = elements
        
        while operationsToReduce.count > 1 {
            let left = Int(operationsToReduce[0])!
            let operand = operationsToReduce[1]
            let right = Int(operationsToReduce[2])!
            let result: Int
            switch operand {
            case "+": result = left + right
            case "-": result = left - right
            case "*": result = left * right
            case "/": result = left / right
            default: fatalError("Unknown operator !")
            }
            operationsToReduce = Array(operationsToReduce.dropFirst(3))
            operationsToReduce.insert("\(result)", at: 0)
        }
        
        guard let result = operationsToReduce.first else {
            return
        }
        
        let operationResult = " = \(result)"
        
        text.append(operationResult)
        delegate?.textHasBeenAdded(text: operationResult)
    }
}


