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
        
        // Si le caractère est un point, nous vérifions qu'il n'y a pas déjà de point dans le dernier nombre
        if number == "." {
            let numbers = text.split(separator: " ")
            if let lastNumber = numbers.last, lastNumber.contains(".") {
                delegate?.showAlert(title: "Erreur", message: "Un nombre ne peut pas avoir plus d'un point décimal.")
                return
            }
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
        // Étape 1 : calculer les opérations de haute priorité (multiplication et division)
        var operationsToReduce = processHighPriorityOperations(in: elements)
        if operationsToReduce.contains("Erreur") {
            delegate?.showAlert(title: "Erreur", message: "La division par zéro n'est pas possible")
            return
        }
        
        // Étape 2 : calculer les opérations de basse priorité (addition et soustraction)
        while operationsToReduce.count > 1 {
            let left = Double(operationsToReduce[0])!
            let operand = operationsToReduce[1]
            let right = Double(operationsToReduce[2])!
            let result = processLowPriorityOperation(left: left, right: right, operand: operand)
            
            operationsToReduce = Array(operationsToReduce.dropFirst(3))
            operationsToReduce.insert("\(result)", at: 0)
        }
        
        guard let result = operationsToReduce.first else {
            return
        }
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        guard let formattedResult = formatter.string(from: NSNumber(value: Double(result)!)) else {
            delegate?.showAlert(title: "Erreur", message: "Impossible de formater le résultat")
            return
        }
        
        let operationResult = " = \(formattedResult)"
        
        text.append(operationResult)
        delegate?.textHasBeenAdded(text: operationResult)
    }

    private func processHighPriorityOperations(in elements: [String]) -> [String] {
        var operations = elements
        while true {
            if let index = operations.firstIndex(where: { $0 == "*" || $0 == "/" }) {
                guard index > 0, index < operations.count - 1 else { return ["Erreur"] }
                let left = Double(operations[index - 1])!
                let operand = operations[index]
                let right = Double(operations[index + 1])!
                
                if operand == "/" && right == 0 {
                    return ["Erreur"]
                }
                
                let result = processOperation(left: left, right: right, operand: operand)
                operations.replaceSubrange(index-1...index+1, with: ["\(result)"])
            } else {
                return operations
            }
        }
    }

    private func processOperation(left: Double, right: Double, operand: String) -> Double {
        switch operand {
        case "+": return left + right
        case "-": return left - right
        case "*": return left * right
        case "/": return left / right
        default: fatalError("Unknown operator !")
        }
    }

    private func processLowPriorityOperation(left: Double, right: Double, operand: String) -> Double {
        switch operand {
        case "+": return left + right
        case "-": return left - right
        default: fatalError("Unknown operator !")
        }
    }




}

