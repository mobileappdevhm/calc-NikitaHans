//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Nikita Hans on 16.03.18.
//  Copyright © 2018 Nikita Hans. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var resultTextField: UITextField!
    @IBOutlet weak var termTextField: UITextField!
    
    private let numPadToolBar = UIToolbar()
    private var calculatorViewModel: CalculatorViewModelProtocol?
    private var needsReset = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculatorViewModel = CalculatorViewModel()
        resultLabel.text = "Calculator"
        resultTextField.isEnabled = false
        createDecimalPad()
    }
    
    private func createDecimalPad() {
        termTextField.keyboardType = .decimalPad
        setUpNumPadToolBar()
        termTextField.inputAccessoryView = numPadToolBar
        termTextField.becomeFirstResponder()
    }
    
    private func setUpNumPadToolBar() {
        numPadToolBar.sizeToFit()
        numPadToolBar.items = [
            UIBarButtonItem(title: buttonLabel(.clear), style: .done, target: self, action: #selector(clear)),
            UIBarButtonItem(title: buttonLabel(.plus), style: .plain, target: self, action: #selector(plus)),
            UIBarButtonItem(title: buttonLabel(.minus), style: .plain, target: self, action: #selector(minus)),
            UIBarButtonItem(title: buttonLabel(.multiply), style: .plain, target: self, action: #selector(multiply)),
            UIBarButtonItem(title: buttonLabel(.divide), style: .plain, target: self, action: #selector(divide)),
            UIBarButtonItem(title: buttonLabel(.calculate), style: .done, target: self, action: #selector(calc))
        ]
    }

    //MARK: User Button Functions
    @objc func clear() {
        termTextField.text = ""
        resultTextField.text = ""
        guard let viewModel = calculatorViewModel else { return }
        viewModel.clear()
        needsReset = false
    }
    
    @objc func plus() {
        guard let viewModel = calculatorViewModel else { return }
        viewModel.addToTerm(userInput: termTextField.text, mathAction: .plus)
        updateTextViews(.plus)
    }
    
    @objc func minus() {
        guard let viewModel = calculatorViewModel else { return }
        viewModel.addToTerm(userInput: termTextField.text, mathAction: .minus)
        updateTextViews(.minus)
    }
    
    @objc func multiply() {
        guard let viewModel = calculatorViewModel else { return }
        viewModel.addToTerm(userInput: termTextField.text, mathAction: .multiply)
        updateTextViews(.multiply)
    }

    @objc func divide() {
        guard let viewModel = calculatorViewModel else { return }
        viewModel.addToTerm(userInput: termTextField.text, mathAction: .divide)
        updateTextViews(.divide)
    }
    
    @objc func calc() {
        guard let viewModel = calculatorViewModel else { return }
        viewModel.addToTerm(userInput: termTextField.text, mathAction: .calculate)
        if let prefix = resultTextField.text, let value = termTextField.text {
            resultTextField.text = "\(prefix) \(value) ="
        }
        termTextField.text = "\(viewModel.calculate())"
        needsReset = true
    }
    
    //MARK: TextViewUpdate
    private func updateTextViews(_ action: UserAction) {
        if needsReset {
            resultTextField.text = ""
            needsReset = false
        }
        guard let text = termTextField.text else { return }
        termTextField.text = ""
        if let previous = resultTextField.text, previous != "" {
            resultTextField.text = "\(previous) \(text) \(symbol(from: action))"
        } else {
            resultTextField.text = "\(text) \(symbol(from: action))"
        }
    }
    
    // MARK: UserAction to String Helper Functions
    private func symbol(from action: UserAction) -> String {
        return buttonLabel(action).trimmingCharacters(in: .whitespaces)
    }

    private func buttonLabel(_ action: UserAction) -> String {
        let spacing = "     "
        switch action {
        case .clear:
            return "\(spacing)reset"
        case .plus:
            return "\(spacing)+"
        case .minus:
            return "\(spacing)-"
        case .multiply:
            return "\(spacing)x"
        case .divide:
            return "\(spacing):"
        case .calculate:
            return "\(spacing)="
        case .error:
            return "\(spacing)ERROR"
        }
    }
}


