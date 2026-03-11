import Foundation
import WidgetKit

struct WidgetCalculatorState: Codable {
    var displayText = "0"
    var expressionText = ""
    var expressionTokens: [WidgetExpressionToken] = []
    var currentInput = "0"
    var isTypingNumber = false
    var justEvaluated = false

    mutating func handle(key: String) {
        switch key {
        case "0"..."9":
            inputDigit(key)
        case "00":
            inputDigit("0")
            inputDigit("0")
        case ".":
            inputDecimal()
        case "clear":
            clear()
        case "sign":
            toggleSign()
        case "percent":
            applyPercent()
        case "divide":
            applyOperation(.divide)
        case "multiply":
            applyOperation(.multiply)
        case "subtract":
            applyOperation(.subtract)
        case "add":
            applyOperation(.add)
        case "equals":
            evaluate()
        default:
            break
        }
    }

    mutating func inputDigit(_ digit: String) {
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

    mutating func inputDecimal() {
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

    mutating func applyOperation(_ operation: WidgetCalculatorOperation) {
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

    mutating func toggleSign() {
        guard currentInput != "0" else { return }

        if currentInput.hasPrefix("-") {
            currentInput.removeFirst()
        } else {
            currentInput = "-" + currentInput
        }

        displayText = currentInput
        updateExpressionPreview()
    }

    mutating func applyPercent() {
        guard let value = Double(currentInput) else {
            setErrorState()
            return
        }

        currentInput = format(value / 100)
        displayText = currentInput
        isTypingNumber = true
        updateExpressionPreview()
    }

    mutating func clear() {
        if expressionText.isEmpty && displayText == "0" && !isTypingNumber {
            resetAll()
            return
        }

        currentInput = "0"
        displayText = currentInput
        isTypingNumber = false
        justEvaluated = false
        updateExpressionPreview()
    }

    mutating func evaluate() {
        var tokens = expressionTokens

        if isTypingNumber || tokens.isEmpty {
            tokens.append(.number(currentInput))
        } else if case .operation = tokens.last {
            tokens.removeLast()
        }

        guard !tokens.isEmpty else { return }

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

    private mutating func resetAll() {
        displayText = "0"
        expressionText = ""
        expressionTokens = []
        currentInput = "0"
        isTypingNumber = false
        justEvaluated = false
    }

    private mutating func updateExpressionPreview() {
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

    private func render(tokens: [WidgetExpressionToken]) -> String {
        tokens.map { token in
            switch token {
            case .number(let value):
                value
            case .operation(let operation):
                operation.symbol
            }
        }
        .joined(separator: " ")
    }

    private func evaluate(tokens: [WidgetExpressionToken]) throws -> Double {
        var values: [Double] = []
        var operations: [WidgetCalculatorOperation] = []

        func applyTopOperation() throws {
            guard
                let operation = operations.popLast(),
                let rhs = values.popLast(),
                let lhs = values.popLast()
            else {
                throw WidgetCalculatorError.invalidExpression
            }

            values.append(try operation.apply(lhs: lhs, rhs: rhs))
        }

        for token in tokens {
            switch token {
            case .number(let rawValue):
                guard let value = Double(rawValue) else {
                    throw WidgetCalculatorError.invalidExpression
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

        guard let result = values.last, values.count == 1 else {
            throw WidgetCalculatorError.invalidExpression
        }

        return result
    }

    private func format(_ value: Double) -> String {
        if value.isInfinite || value.isNaN {
            return "Error"
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 10
        formatter.maximumIntegerDigits = 12

        let rounded = abs(value) < 0.0000000001 ? 0 : value
        if let text = formatter.string(from: NSNumber(value: rounded)) {
            return text
        }
        return String(rounded)
    }

    private mutating func setErrorState() {
        displayText = "Error"
        expressionText = ""
        expressionTokens = []
        currentInput = "0"
        isTypingNumber = false
        justEvaluated = false
    }
}

enum WidgetCalculatorStore {
    private static let key = "HaloCalc.widget.state"
    private static let defaults = UserDefaults.standard

    static func load() -> WidgetCalculatorState {
        guard
            let data = defaults.data(forKey: key),
            let state = try? JSONDecoder().decode(WidgetCalculatorState.self, from: data)
        else {
            return WidgetCalculatorState()
        }
        return state
    }

    static func save(_ state: WidgetCalculatorState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: key)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

enum WidgetCalculatorOperation: String, Codable {
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
                throw WidgetCalculatorError.divideByZero
            }
            return lhs / rhs
        }
    }
}

enum WidgetExpressionToken: Codable {
    case number(String)
    case operation(WidgetCalculatorOperation)

    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    private enum TokenType: String, Codable {
        case number
        case operation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(TokenType.self, forKey: .type)
        switch type {
        case .number:
            self = .number(try container.decode(String.self, forKey: .value))
        case .operation:
            self = .operation(try container.decode(WidgetCalculatorOperation.self, forKey: .value))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .number(let value):
            try container.encode(TokenType.number, forKey: .type)
            try container.encode(value, forKey: .value)
        case .operation(let value):
            try container.encode(TokenType.operation, forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
}

private enum WidgetCalculatorError: Error {
    case invalidExpression
    case divideByZero
}
