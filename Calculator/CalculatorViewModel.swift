//
//  CalculatorViewModel.swift
//  Calculator
//
//  Created by Nikita Hans on 17.03.18.
//  Copyright © 2018 Nikita Hans. All rights reserved.
//

import Foundation

enum UserAction {
    case clear
    case plus
    case minus
    case divide
    case multiply
    case calculate
    case error
}

protocol CalculatorViewModelProtocol {
    //Clears the mathematic and logic term currently saved
    func clear()
    //Adds a new Double as a value paired with a mathAction to the term, if String is invalid to be used as a Double the term is invalidated
    func addToTerm(userInput: String?, mathAction: UserAction)
    //Computes the current term to a rounded Double value which is returned as a String, the term is cleared after the computation
    func calculate() -> String
}

class CalculatorViewModel: CalculatorViewModelProtocol {
    private var term: [valueOperatorPair] = [valueOperatorPair]()
    private struct valueOperatorPair {
        let value: Double
        var usrActn: UserAction
    }
    
    func clear() {
        term = [valueOperatorPair]()
    }
    
    func addToTerm(userInput: String?, mathAction: UserAction) {
        if let validValue = Double(userInput ?? "0") {
            term.append(valueOperatorPair(value: validValue , usrActn: mathAction))
        } else {
            term.append(valueOperatorPair(value: 0.0001, usrActn: .error))
        }
    }
    
    func calculate() -> String {
                var lowPriorityTerm = [valueOperatorPair]()
                var result: Double = 0
                var prevValue: Double?
                var nextOp: UserAction = .clear
                //high Priority calc
                for elem in term {
                    var currentElement = elem
                    if let previous = prevValue {
                        if nextOp == .multiply {
                            currentElement = valueOperatorPair(value: previous * elem.value, usrActn: elem.usrActn)
                        } else if nextOp == .divide {
                            if elem.value == 0 {
                                currentElement = valueOperatorPair(value: previous, usrActn: .error)
                            } else {
                                currentElement = valueOperatorPair(value: previous / elem.value, usrActn: elem.usrActn)
                            }
                        }
                        prevValue = nil
                    }
                    if currentElement.usrActn == .multiply || currentElement.usrActn == .divide {
                        prevValue = currentElement.value
                        nextOp = currentElement.usrActn
                    } else {
                        lowPriorityTerm.append(currentElement)
                    }
                }
                //low Priority calc
                for (index,elem) in lowPriorityTerm.enumerated() {
                    if index != 0 {
                        switch nextOp{
                        case .plus:
                            result += elem.value
                        case .minus:
                            result -= elem.value
                        case .divide, .multiply:
                            print("found high priority  while calculating low priority ops")
                        case .calculate:
                            clear()
                        default:
                            print("found non math op in low priority ops term")
                        }
                    } else {
                        if elem.usrActn == .error {
                            clear()
                            term = [valueOperatorPair]()
                            return "ERROR"
                        }
                        result = elem.value
                    }
                    nextOp = elem.usrActn
                }
                term = [valueOperatorPair]()
                return ("\(Double(Int(result*1000))/1000)")
    }
}
