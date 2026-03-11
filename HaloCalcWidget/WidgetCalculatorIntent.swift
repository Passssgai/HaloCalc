import AppIntents

struct WidgetCalculatorIntent: AppIntent {
    static var title: LocalizedStringResource = "Calculator Key"
    static var openAppWhenRun = false

    @Parameter(title: "Key")
    var key: String

    init() {}

    init(key: String) {
        self.key = key
    }

    func perform() async throws -> some IntentResult {
        var state = WidgetCalculatorStore.load()
        state.handle(key: key)
        WidgetCalculatorStore.save(state)
        return .result()
    }
}
