import SwiftUI

enum CalculatorButton: String {
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case zero = "0"
    case decimal = "."
    case add = "+"
    case subtract = "–"
    case mutliply = "x"
    case divide = "÷"
    case equal = "="
    case clear = "C"
    case negative = "-/+"
    case leftParenthesis = "("
    case rightParenthesis = ")"
    
    var foregroundColor: Color {
        switch self {
        case .leftParenthesis, .rightParenthesis, .negative:
            return .black
        default:
            return .white
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .equal:
            return .green
        case .clear:
            return .red
        case .add, .subtract, .mutliply, .divide:
            return .orange
        case .negative, .leftParenthesis, .rightParenthesis:
            return Color(.lightGray)
        default:
            return Color(.darkGray)
        }
    }
}
