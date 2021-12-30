import SwiftUI

class ViewModel: ObservableObject {
    
    let buttons: [[CalculatorButton]] = [
        [.leftParenthesis, .rightParenthesis, .negative, .add],
        [.seven, .eight, .nine, .subtract],
        [.four, .five, .six, .mutliply],
        [.one, .two, .three, .divide],
        [.zero, .decimal, .clear, .equal],
    ]
    
    let buttonSpacing: CGFloat = 15
    let buttonFontSize: CGFloat = 32
    let displayFontSize: CGFloat = 64
    let displayColor = Color.white
    let inputFontSize: CGFloat = 24
    let inputColor = Color.gray
    
    @Published var inputArray: [String] = []
    @Published var result = "0"
    @Published var showPicture = false
    private var parenthesis = 0
    private let FAILED = "ERROR!"
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 10
        return formatter
    }()
    
    var input: String {
        var value = ""
        for str in inputArray {
            value += "+–x÷=".contains(str) ? " \(str) " : str
        }
        return value
    }
    
    func onTap(button: CalculatorButton) {
        if !inputArray.isEmpty && inputArray.last == "=" {
            if button == .equal {
                return
            }
            
            if button == .clear {
                inputArray.removeLast()
                result = "0"
                return
            }
            
            inputArray.removeAll()
            
            if result != FAILED && (button == .add || button == .subtract || button == .mutliply || button == .divide) {
                inputArray.append(result)
            }
            
            result = "0"
        }
        
        switch button {
        case .one, .two, .three, .four, .five, .six, .seven, .eight, .nine, .zero:
            if inputArray.isEmpty {
                inputArray.append(button.rawValue)
                return
            }
            
            let last = inputArray.last!
            
            if "(+–x÷".contains(last) {
                inputArray.append(button.rawValue)
                return
            }
            
            if last == "0" {
                inputArray[inputArray.count - 1] = button.rawValue
                return
            }
            
            if last == "-0" {
                inputArray[inputArray.count - 1] = "-\(button.rawValue)"
                return
            }
            
            if last == ")" {
                //error
                return
            }
            
            inputArray[inputArray.count - 1].append(button.rawValue)
            break
            
        case .decimal:
            if inputArray.isEmpty {
                inputArray.append(button.rawValue)
                return
            }
            
            let last = inputArray.last!
            
            if "(+–x÷".contains(last) {
                inputArray.append(button.rawValue)
                return
            }
            
            if last == ")" || last.contains(".") {
                //error
                return
            }
            
            inputArray[inputArray.count - 1].append(button.rawValue)
            break
            
        case .add, .subtract, .mutliply, .divide:
            if inputArray.isEmpty {
                // error
                return
            }
            
            let last = inputArray.last!
            
            if "(-".contains(last) {
                // error
                return
            }
            
            if "+–x÷".contains(last) {
                inputArray[inputArray.count - 1] = button.rawValue
                return
            }
            
            inputArray.append(button.rawValue)
            break
            
        case .clear:
            if inputArray.isEmpty {
                return
            }
            
            let last = inputArray.last!
            
            if last == "(" {
                parenthesis -= 1
                inputArray.removeLast()
                return
            }
            
            if last == ")" {
                parenthesis += 1
                inputArray.removeLast()
                return
            }
            
            inputArray[inputArray.count - 1].removeLast()
            
            if inputArray[inputArray.count - 1].isEmpty {
                inputArray.removeLast()
            }
            
        case .negative:
            if inputArray.isEmpty {
                inputArray.append("-")
                return
            }
            
            let last = inputArray.last!
            
            if "(+–x÷".contains(last) {
                inputArray.append("-")
                return
            }
            
            if ")".contains(last) {
                // error
                return
            }
            
            if last.first == "-" {
                inputArray[inputArray.count - 1].removeFirst()
                return
            }
            
            inputArray[inputArray.count - 1] = "-\(inputArray[inputArray.count - 1])"
            break
            
        case .leftParenthesis:
            if inputArray.isEmpty {
                parenthesis += 1
                inputArray.append(button.rawValue)
                return
            }
            
            let last = inputArray.last!
            
            if "(+–x÷".contains(last) {
                parenthesis += 1
                inputArray.append(button.rawValue)
                return
            }
            
            // error
            break
            
        case .rightParenthesis:
            if inputArray.isEmpty {
                // error
                return
            }
            
            let last = inputArray.last!
            
            if "(+–x÷-".contains(last) || parenthesis < 1 {
                // error
                return
            }
            
            parenthesis -= 1
            inputArray.append(button.rawValue)
            
        case .equal:
            if inputArray.isEmpty {
                self.result = "0"
                return
            }
            
            if parenthesis != 0 {
                self.result = FAILED
                return
            }
            
            var last = inputArray.last!
            
            if "+–x÷-.".contains(last) {
                self.result = FAILED
                return
            }
             
            do {
                guard let result = try calculate() else {
                    self.result = "0"
                    return
                }
                
                inputArray.append("=")
                
                if let str = numberFormatter.string(from: NSNumber(value: result)) {
                    self.result = str
                }
            }
            catch {
                self.result = FAILED
            }
        }
    }
    
    enum CalculatorError: Error {
        case invalidOperator(String)
        case invalidOperand(String)
        case missingOperand
        case parenthesisNotMatch
        case tooManyOperators
        case tooManyOperands
    }
    
    private func operate(_ a: Double, _ b: Double, oper: String) throws -> Double {
        switch oper {
        case "+":
            return a + b
        case "–":
            return a - b
        case "x":
            return a * b
        case "÷":
            return a / b
        default:
            throw CalculatorError.invalidOperator(oper)
        }
    }
    
    private func calculate() throws -> Double? {
        var operands: [Double] = []
        var operators: [String] = []
        
        for str in inputArray {
            switch str {
            case "+", "–":
                if operators.isEmpty || operators.first == "(" {
                    operators.append(str)
                }
                else if operands.count < 2 {
                    throw CalculatorError.missingOperand
                }
                else {
                    while !operators.isEmpty && operators.last != "(" {
                        let a = operands[operands.count - 2]
                        let b = operands[operands.count - 1]
                        
                        operands[operands.count - 2] = try operate(a, b, oper: operators.last!)
                        operands.removeLast()
                        operators.removeLast()
                    }
                    
                    operators.append(str)
                }
                
            case "x", "÷":
                if operators.isEmpty || operators.first == "(" || operators.first == "+" || operators.first == "–" {
                    operators.append(str)
                }
                else if operands.count < 2 {
                    throw CalculatorError.missingOperand
                }
                else {
                    let a = operands[operands.count - 2]
                    let b = operands[operands.count - 1]
                    
                    operands[operands.count - 2] = try operate(a, b, oper: operators.last!)
                    operands.removeLast()
                    operators[operators.count - 1] = str
                }
                
            case "(":
                operators.append(str)
                
            case ")":
                while !operators.isEmpty && operators.last != "(" {
                    let a = operands[operands.count - 2]
                    let b = operands[operands.count - 1]
                    
                    operands[operands.count - 2] = try operate(a, b, oper: operators.last!)
                    operands.removeLast()
                    operators.removeLast()
                }
                
                if operators.isEmpty {
                    throw CalculatorError.parenthesisNotMatch
                }
                
                operators.removeLast()
                
            default:
                if let d = Double(str) {
                    operands.append(d)
                }
                else {
                    throw CalculatorError.invalidOperand(str)
                }
            }
        }
        
        if operators.isEmpty {
            if operands.count > 1 {
                throw CalculatorError.tooManyOperands
            }
            
            return operands[0]
        }
        
        while !operators.isEmpty {
            let a = operands[operands.count - 2]
            let b = operands[operands.count - 1]
            
            operands[operands.count - 2] = try operate(a, b, oper: operators.last!)
            operands.removeLast()
            operators.removeLast()
        }
        
        return operands[0]
    }
    
    func allClear() {
        inputArray = []
        result = "0"
    }
}
