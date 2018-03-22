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
    @IBOutlet weak var termTextFieldHeightConstraint: NSLayoutConstraint!
    
    private let numPadToolBar = UIToolbar()
    private var calculatorViewModel: CalculatorViewModelProtocol?
    private var needsReset = false
    private var isSmallDevice: Bool?
    private var coreMenuItems: [UIBarButtonItem] {
        return [
            UIBarButtonItem(title: userActionString(from: .clear), style: .done, target: self, action: #selector(clear)),
            UIBarButtonItem(title: userActionString(from: .plus), style: .plain, target: self, action: #selector(plus)),
            UIBarButtonItem(title: userActionString(from: .minus), style: .plain, target: self, action: #selector(minus)),
            UIBarButtonItem(title: userActionString(from: .multiply), style: .plain, target: self, action: #selector(multiply)),
            UIBarButtonItem(title: userActionString(from: .divide), style: .plain, target: self, action: #selector(divide)),
            UIBarButtonItem(title: userActionString(from: .calculate), style: .done, target: self, action: #selector(calc))
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculatorViewModel = CalculatorViewModel()
        resultLabel.text = "Calculator"
        resultTextField.isEnabled = false
        createDecimalPad()
        isSmallDevice = (UIScreen.main.bounds.width <= UIScreen.main.bounds.height ? UIScreen.main.bounds.height : UIScreen.main.bounds.width) < 650
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adjustLayoutFor(newSize: UIScreen.main.bounds)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        adjustLayoutFor(newSize: CGRect(origin: CGPoint(), size: size))
    }

    private func createDecimalPad() {
        termTextField.keyboardType = .decimalPad
        numPadToolBar.sizeToFit()
        termTextField.inputAccessoryView = numPadToolBar
        termTextField.becomeFirstResponder()
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

    //MARK: UI Updates
    private func updateTextViews(_ action: UserAction) {
        if needsReset {
            resultTextField.text = ""
            needsReset = false
        }
        guard let text = termTextField.text else { return }
        termTextField.text = ""
        if let previous = resultTextField.text, previous != "" {
            resultTextField.text = "\(previous) \(text) \(userActionString(from: action))"
        } else {
            resultTextField.text = "\(text) \(userActionString(from: action))"
        }
    }

    private func adjustLayoutFor(newSize newDimensions: CGRect) {
        updateSpacingForNumPadToolBar(screenWidth: newDimensions.width)
        if isSmallDevice ?? false {
            termTextFieldHeightConstraint.constant = CGFloat(UIDevice.current.orientation.isLandscape ? 0 : 50)
        }
    }

    private func updateSpacingForNumPadToolBar(screenWidth: CGFloat) {
        let spacingSize = screenWidth/13
        let spacing = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        spacing.width = CGFloat(spacingSize)
        var spacedItems = [UIBarButtonItem]([spacing])
        for item in coreMenuItems {
            spacedItems.append(item)
            spacedItems.append(spacing)
        }
        numPadToolBar.items = nil
        numPadToolBar.items = spacedItems
    }

    // MARK: UserAction to String Helper
    private func userActionString(from action: UserAction) -> String {
        switch action {
        case .clear:
            return "c"
        case .plus:
            return "+"
        case .minus:
            return "-"
        case .multiply:
            return "x"
        case .divide:
            return ":"
        case .calculate:
            return "="
        case .error:
            return "ERROR"
        }
    }
}


