import SwiftUI
import WidgetKit

struct HaloCalcWidgetEntry: TimelineEntry {
    let date: Date
    let state: WidgetCalculatorState
}

struct HaloCalcWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> HaloCalcWidgetEntry {
        HaloCalcWidgetEntry(date: .now, state: WidgetCalculatorState(displayText: "128", expressionText: "96 + 32"))
    }

    func getSnapshot(in context: Context, completion: @escaping (HaloCalcWidgetEntry) -> Void) {
        completion(HaloCalcWidgetEntry(date: .now, state: WidgetCalculatorStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HaloCalcWidgetEntry>) -> Void) {
        let entry = HaloCalcWidgetEntry(date: .now, state: WidgetCalculatorStore.load())
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct HaloCalcWidget: Widget {
    static let kind = "HaloCalcWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: HaloCalcWidgetProvider()) { entry in
            HaloCalcWidgetView(entry: entry)
        }
        .configurationDisplayName("星算器 StarCalc")
        .description("在桌面直接点按数字和基础运算。")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

private struct HaloCalcWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: HaloCalcWidgetEntry

    private let rows: [[WidgetKey]] = [
        [.utility("C", id: "clear"), .utility("+/-", id: "sign"), .utility("%", id: "percent"), .operator("÷", id: "divide")],
        [.digit("7"), .digit("8"), .digit("9"), .operator("x", id: "multiply")],
        [.digit("4"), .digit("5"), .digit("6"), .operator("-", id: "subtract")],
        [.digit("1"), .digit("2"), .digit("3"), .operator("+", id: "add")],
        [.digit("0"), .accent("00", id: "00"), .digit("."), .equals]
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.08, blue: 0.16), Color(red: 0.07, green: 0.22, blue: 0.34), Color(red: 0.12, green: 0.46, blue: 0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: family == .systemLarge ? 10 : 8) {
                displayPanel
                keyGrid
            }
            .padding(family == .systemLarge ? 16 : 12)
        }
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.08, blue: 0.16), Color(red: 0.07, green: 0.22, blue: 0.34), Color(red: 0.12, green: 0.46, blue: 0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var displayPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("STARCALC")
                    .font(.system(size: family == .systemLarge ? 12 : 10, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.72))
                Spacer()
                Text("LIVE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(red: 0.06, green: 0.16, blue: 0.25))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(red: 0.41, green: 0.91, blue: 0.89)))
            }

            Text(entry.state.expressionText.isEmpty ? " " : entry.state.expressionText)
                .font(.system(size: family == .systemLarge ? 13 : 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.7))
                .lineLimit(1)

            Text(entry.state.displayText)
                .font(.system(size: family == .systemLarge ? 34 : 28, weight: .light, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.55)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(family == .systemLarge ? 14 : 12)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private var keyGrid: some View {
        VStack(spacing: family == .systemLarge ? 8 : 6) {
            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack(spacing: family == .systemLarge ? 8 : 6) {
                    ForEach(rows[rowIndex]) { key in
                        Button(intent: WidgetCalculatorIntent(key: key.id)) {
                            keyLabel(for: key)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func keyLabel(for key: WidgetKey) -> some View {
        Text(key.label)
            .font(.system(size: family == .systemLarge ? 17 : 15, weight: .bold, design: .rounded))
            .foregroundStyle(key.foreground)
            .frame(maxWidth: .infinity)
            .frame(height: family == .systemLarge ? 34 : 28)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(key.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    )
            )
    }
}

private struct WidgetKey: Identifiable {
    let id: String
    let label: String
    let background: LinearGradient
    let foreground: Color

    static func digit(_ label: String) -> WidgetKey {
        WidgetKey(
            id: label,
            label: label,
            background: LinearGradient(colors: [Color(red: 0.15, green: 0.23, blue: 0.35), Color(red: 0.06, green: 0.10, blue: 0.18)], startPoint: .topLeading, endPoint: .bottomTrailing),
            foreground: .white
        )
    }

    static func utility(_ label: String, id: String) -> WidgetKey {
        WidgetKey(
            id: id,
            label: label,
            background: LinearGradient(colors: [Color(red: 0.35, green: 0.46, blue: 0.60), Color(red: 0.17, green: 0.24, blue: 0.35)], startPoint: .topLeading, endPoint: .bottomTrailing),
            foreground: .white
        )
    }

    static func `operator`(_ label: String, id: String) -> WidgetKey {
        WidgetKey(
            id: id,
            label: label,
            background: LinearGradient(colors: [Color(red: 0.98, green: 0.73, blue: 0.33), Color(red: 0.95, green: 0.40, blue: 0.22)], startPoint: .topLeading, endPoint: .bottomTrailing),
            foreground: Color(red: 0.20, green: 0.10, blue: 0.05)
        )
    }

    static let equals = WidgetKey(
        id: "equals",
        label: "=",
        background: LinearGradient(colors: [Color(red: 0.43, green: 0.93, blue: 0.83), Color(red: 0.12, green: 0.62, blue: 0.80)], startPoint: .topLeading, endPoint: .bottomTrailing),
        foreground: Color(red: 0.04, green: 0.18, blue: 0.25)
    )

    static func accent(_ label: String, id: String) -> WidgetKey {
        WidgetKey(
            id: id,
            label: label,
            background: LinearGradient(colors: [Color.white.opacity(0.22), Color.white.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing),
            foreground: .white
        )
    }
}
