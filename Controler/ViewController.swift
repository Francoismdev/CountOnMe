//
//  ViewController.swift
//  SimpleCalc
//
//  Created by Vincent Saluzzo on 29/03/2019.
//  Copyright © 2019 Vincent Saluzzo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var numberButtons: [UIButton]!
    
    private var calculatorModel: CalculatorModel!
    
    // View Life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController present.") // debug
        calculatorModel = CalculatorModel(delegate: self)
    }
    
    // View actions
    
    @IBAction func tappedNumberButton(_ button: UIButton) {
        guard let numberText = button.titleLabel?.text else {
            return
        }
        print("nombre taper: \(numberText)") // debug
        calculatorModel.add(number: numberText)
    }
    
    @IBAction func tappedMultiplyButton(_ sender: UIButton) {
        calculatorModel.add(sign: "*")
      

    }
    
    @IBAction func tappedDivisionButton(_ sender: UIButton) {
        calculatorModel.add(sign: "/")
    }
    
    @IBAction func tappedAdditionButton(_ sender: UIButton) {
        
        calculatorModel.add(sign: "+")
    }
    
    @IBAction func tappedSubstractionButton(_ sender: UIButton) {
        print("Substraction button tapped")
          calculatorModel.add(sign: "-")
      }
   
    
    @IBAction func tappedEqualButton(_ sender: UIButton) {
        calculatorModel.equal()
    }
 
    @IBAction func Point(_ sender: UIButton) {
        calculatorModel.add(number: ".")
    }
    
    
    
    @IBAction func tappedClearButton(_ sender: UIButton) {
        calculatorModel.clear()
    }
}



// MARK: - CalculatorModelDelegate

extension ViewController: CalculatorModelDelegate {
    func textHasBeenAdded(text: String) {
        self.textView.text.append(text)
    }
    
    func resetText() {
        self.textView.text = ""
    }
    
    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
}

