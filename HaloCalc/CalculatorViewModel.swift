import Combine
import Foundation

final class CalculatorViewModel: ObservableObject {
    @Published private(set) var displayText = "0"
    @Published private(set) var expressionText = ""

    var clearButtonTitle: String {
        if expressionText.isEmpty && displayText == "0" && !isTypingNumber {
            return "AC"
        }
        return "C"
    }

    private var expressionTokens: [ExpressionToken] = []
    private var currentInput = "0"
    private var isTypingNumber = false
    private var justEvaluated = false
    private var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 10
        formatter.maximumIntegerDigits = 12
        return formatter
    }()

    func inputDigit(_ digit: String) {
        if justEvaluated {
            resetAll()
        }

        if !isTypingNumber || currentInput == "0" {
            currentInput = digit
        } else if currentInput.count < 16 {
            currentInput.append(digit)
        }

        isTypingNumber = true
        displayText = currentInput
        updateExpressionPreview()
    }

    func inputDecimal() {
        if justEvaluated {
            resetAll()
        }

        if !isTypingNumber {
            currentInput = "0."
            isTypingNumber = true
        } else if !currentInput.contains(".") {
            currentInput.append(".")
        }

        displayText = currentInput
        updateExpressionPreview()
    }

    func applyOperation(_ operation: CalculatorOperation) {
        justEvaluated = false

        if expressionTokens.isEmpty {
            expressionTokens.append(.number(currentInput))
        } else if isTypingNumber {
            expressionTokens.append(.number(currentInput))
        } else if case .operation = expressionTokens.last {
            expressionTokens.removeLast()
        }

        expressionTokens.append(.operation(operation))
        isTypingNumber = false
        expressionText = render(tokens: expressionTokens)
    }

    func toggleSign() {
        if currentInput == "0" {
            return
        }

        if currentInput.hasPrefix("-") {
            currentInput.removeFirst()
        } else {
            currentInput = "-" + currentInput
        }

        displayText = currentInput
        updateExpressionPreview()
    }

    func applyPercent() {
        guard let value = Double(currentInput) else {
            setErrorState()
            return
        }

        currentInput = format(value / 100)
        displayText = currentInput
        isTypingNumber = true
        updateExpressionPreview()
    }

    func clear() {
        if clearButtonTitle == "AC" || (displayText == "0" && !isTypingNumber) {
            resetAll()
            return
        }

        currentInput = "0"
        displayText = currentInput
        isTypingNumber = false
        justEvaluated = false
        updateExpressionPreview()
    }

    func evaluate() {
        var tokens = expressionTokens

        if isTypingNumber || tokens.isEmpty {
            tokens.append(.number(currentInput))
        } else if case .operation = tokens.last {
            tokens.removeLast()
        }

        guard !tokens.isEmpty else {
            return
        }

        do {
            let result = try evaluate(tokens: tokens)
            expressionText = render(tokens: tokens) + " ="
            currentInput = format(result)
            displayText = currentInput
            expressionTokens = []
            isTypingNumber = false
            justEvaluated = true
        } catch {
            setErrorState()
        }
    }

    private func resetAll() {
        displayText = "0"
        expressionText = ""
        currentInput = "0"
        expressionTokens = []
        isTypingNumber = false
        justEvaluated = false
    }

    private func updateExpressionPreview() {
        var tokens = expressionTokens

        if isTypingNumber || tokens.isEmpty {
            if tokens.isEmpty {
                expressionText = currentInput == "0" ? "" : currentInput
                return
            }

            if case .operation = tokens.last {
                tokens.append(.number(currentInput))
            } else if !tokens.isEmpty {
                tokens.removeLast()
                tokens.append(.number(currentInput))
            }
        }

        expressionText = render(tokens: tokens)
    }

    private func render(tokens: [ExpressionToken]) -> String {
        tokens.map { token in
            switch token {
            case .number(let value):
                return value
            case .operation(let operation):
                return operation.symbol
            }
        }
        .joined(separator: " ")
    }

    private func evaluate(tokens: [ExpressionToken]) throws -> Double {
        var values: [Double] = []
        var operations: [CalculatorOperation] = []

        func applyTopOperation() throws {
            guard
                let operation = operations.popLast(),
                let rhs = values.popLast(),
                let lhs = values.popLast()
            else {
                throw CalculatorError.invalidExpression
            }

            values.append(try operation.apply(lhs: lhs, rhs: rhs))
        }

        for token in tokens {
            switch token {
            case .number(let rawValue):
                guard let value = Double(rawValue) else {
                    throw CalculatorError.invalidExpression
                }
                values.append(value)

            case .operation(let operation):
                while let previous = operations.last, previous.precedence >= operation.precedence {
                    try applyTopOperation()
                }
                operations.append(operation)
            }
        }

        while !operations.isEmpty {
            try applyTopOperation()
        }

        guard let finalValue = values.last, values.count == 1 else {
            throw CalculatorError.invalidExpression
        }

        return finalValue
    }

    private func format(_ value: Double) -> String {
        if value.isInfinite || value.isNaN {
            return "Error"
        }

        let rounded = abs(value) < 0.0000000001 ? 0 : value
        if let text = formatter.string(from: NSNumber(value: rounded)) {
            return text
        }
        return String(rounded)
    }

    private func setErrorState() {
        displayText = "Error"
        expressionText = ""
        currentInput = "0"
        expressionTokens = []
        isTypingNumber = false
        justEvaluated = false
    }
}

enum CalculatorOperation: String {
    case add
    case subtract
    case multiply
    case divide

    var symbol: String {
        switch self {
        case .add:
            return "+"
        case .subtract:
            return "-"
        case .multiply:
            return "x"
        case .divide:
            return "÷"
        }
    }

    var precedence: Int {
        switch self {
        case .add, .subtract:
            return 1
        case .multiply, .divide:
            return 2
        }
    }

    func apply(lhs: Double, rhs: Double) throws -> Double {
        switch self {
        case .add:
            return lhs + rhs
        case .subtract:
            return lhs - rhs
        case .multiply:
            return lhs * rhs
        case .divide:
            guard rhs != 0 else {
                throw CalculatorError.divideByZero
            }
            return lhs / rhs
        }
    }
}

private enum ExpressionToken {
    case number(String)
    case operation(CalculatorOperation)
}

private enum CalculatorError: Error {
    case invalidExpression
    case divideByZero
}
