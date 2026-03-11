import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = CalculatorViewModel()
    @StateObject private var skinManager = CalculatorSkinManager()
    @State private var isSkinDrawerExpanded = false

    private let autoSwitchTimer = Timer.publish(every: 8, on: .main, in: .common).autoconnect()

    var body: some View {
        let theme = skinManager.theme

        GeometryReader { geometry in
            let compact = geometry.size.height < 760
            let maxPanelWidth = min(geometry.size.width - 24, 460)
            let bottomInset = max(geometry.safeAreaInsets.bottom, 12)
            let dockPeekHeight: CGFloat = compact ? 58 : 64

            ZStack(alignment: .bottom) {
                CalculatorBackground(theme: theme)

                if isSkinDrawerExpanded {
                    Color.black.opacity(theme.colorScheme == .dark ? 0.24 : 0.12)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                isSkinDrawerExpanded = false
                            }
                        }
                }

                VStack(spacing: compact ? 14 : 18) {
                    Spacer(minLength: compact ? 0 : 8)
                    displayCard(theme: theme, maxWidth: maxPanelWidth, compact: compact)
                    keypad(theme: theme, maxWidth: maxPanelWidth, compact: compact)
                }
                .padding(.horizontal, 12)
                .padding(.top, 18)
                .padding(.bottom, dockPeekHeight + bottomInset + 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)

                skinDock(
                    theme: theme,
                    maxWidth: maxPanelWidth,
                    compact: compact,
                    bottomInset: bottomInset
                )
            }
        }
        .preferredColorScheme(theme.colorScheme)
        .onReceive(autoSwitchTimer) { _ in
            skinManager.advanceIfNeeded()
        }
        .animation(.spring(response: 0.65, dampingFraction: 0.84), value: skinManager.theme.name)
        .animation(.easeInOut(duration: 0.25), value: skinManager.isAutoCycling)
        .animation(.spring(response: 0.4, dampingFraction: 0.86), value: isSkinDrawerExpanded)
    }

    private func skinDock(theme: CalculatorTheme, maxWidth: CGFloat, compact: Bool, bottomInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            Button {
                Haptics.selection()
                withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
                    isSkinDrawerExpanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Text(skinManager.selectedSkin.theme.name)
                                .font(.system(size: 18, weight: theme.titleWeight, design: theme.titleFontDesign))
                                .foregroundStyle(theme.headlineColor)

                            Text(skinManager.selectedSkin.theme.badge)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(skinManager.isAutoCycling ? theme.highlightForeground : theme.headlineColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background {
                                    Capsule(style: .continuous)
                                        .fill(skinManager.isAutoCycling ? AnyShapeStyle(theme.previewGradient) : AnyShapeStyle(theme.controlColor))
                                }
                        }

                        Text(
                            skinManager.isAutoCycling
                            ? "自动轮播开启中"
                            : skinManager.selectedSkin.theme.caption
                        )
                        .font(.system(size: 12, weight: .medium, design: theme.buttonFontDesign))
                        .foregroundStyle(theme.supportingTextColor)
                    }

                    Spacer(minLength: 10)

                    HStack(spacing: 8) {
                        Image(systemName: skinManager.isAutoCycling ? "arrow.triangle.2.circlepath" : "paintpalette.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(theme.headlineColor)

                        Image(systemName: isSkinDrawerExpanded ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(theme.headlineColor)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, compact ? 11 : 12)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)

            if isSkinDrawerExpanded {
                Divider()
                    .overlay(theme.supportingTextColor.opacity(0.16))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Text("风格皮肤")
                            .font(.system(size: 13, weight: .semibold, design: theme.buttonFontDesign))
                            .foregroundStyle(theme.supportingTextColor)

                        Spacer()

                        Button {
                            Haptics.selection()
                            skinManager.toggleAutoCycling()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: skinManager.isAutoCycling ? "sparkles" : "hand.tap")
                                    .font(.system(size: 12, weight: .bold))
                                Text(skinManager.isAutoCycling ? "自动" : "手动")
                                    .font(.system(size: 11, weight: .bold, design: theme.buttonFontDesign))
                            }
                            .foregroundStyle(skinManager.isAutoCycling ? theme.highlightForeground : theme.headlineColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background {
                                Capsule(style: .continuous)
                                    .fill(skinManager.isAutoCycling ? AnyShapeStyle(theme.previewGradient) : AnyShapeStyle(theme.controlColor))
                                    .overlay {
                                        Capsule(style: .continuous)
                                            .strokeBorder(
                                                skinManager.isAutoCycling ? AnyShapeStyle(Color.white.opacity(0.22)) : AnyShapeStyle(theme.controlStroke),
                                                lineWidth: 1
                                            )
                                    }
                            }
                        }
                        .buttonStyle(CalculatorPressStyle())
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(CalculatorSkin.allCases) { skin in
                                SkinPreviewCard(
                                    skin: skin,
                                    currentTheme: theme,
                                    isSelected: skin == skinManager.selectedSkin
                                ) {
                                    Haptics.selection()
                                    skinManager.select(skin)
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                        isSkinDrawerExpanded = false
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                    .frame(height: compact ? 96 : 104)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, compact ? 8 : 10)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxWidth: maxWidth)
        .background {
            CalculatorSurface(
                theme: theme,
                cornerRadius: theme.selectorCornerRadius,
                shadowRadius: 20,
                shadowYOffset: 10,
                borderWidth: theme.panelBorderWidth
            )
        }
        .padding(.horizontal, 12)
        .padding(.bottom, bottomInset)
    }

    private func displayCard(theme: CalculatorTheme, maxWidth: CGFloat, compact: Bool) -> some View {
        VStack(alignment: .trailing, spacing: compact ? 10 : 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.displayLabel)
                        .font(.system(size: 11, weight: .heavy, design: theme.buttonFontDesign))
                        .tracking(theme.chrome == .arcade ? 1.8 : 0.8)
                        .foregroundStyle(theme.supportingTextColor)

                    Text(theme.displaySubLabel)
                        .font(.system(size: 10, weight: .medium, design: theme.buttonFontDesign))
                        .foregroundStyle(theme.supportingTextColor.opacity(0.78))
                }

                Spacer()

                Text(theme.badge)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(theme.highlightForeground)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background {
                        Capsule(style: .continuous)
                            .fill(theme.previewGradient)
                    }
            }
            .frame(maxWidth: .infinity)

            Text(viewModel.expressionText.isEmpty ? " " : viewModel.expressionText)
                .font(.system(size: compact ? 17 : 19, weight: .medium, design: theme.buttonFontDesign))
                .foregroundStyle(theme.supportingTextColor)
                .monospacedDigit()
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Text(viewModel.displayText)
                .font(.system(size: displayFontSize(compact: compact), weight: theme.displayWeight, design: theme.displayFontDesign))
                .foregroundStyle(theme.headlineColor)
                .monospacedDigit()
                .minimumScaleFactor(0.35)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, compact ? 20 : 24)
        .padding(.vertical, compact ? 22 : 26)
        .frame(maxWidth: maxWidth, minHeight: compact ? 160 : 190, alignment: .bottomTrailing)
        .background {
            CalculatorSurface(
                theme: theme,
                cornerRadius: theme.panelCornerRadius,
                shadowRadius: compact ? 18 : 24,
                shadowYOffset: compact ? 12 : 18,
                borderWidth: theme.panelBorderWidth
            )
        }
        .overlay {
            displayChromeOverlay(theme: theme, compact: compact)
        }
    }

    private func keypad(theme: CalculatorTheme, maxWidth: CGFloat, compact: Bool) -> some View {
        let spacing: CGFloat = compact ? 12 : 14
        let baseWidth = (maxWidth - spacing * 3) / 4

        return VStack(spacing: spacing) {
            keypadRow([
                .utility(viewModel.clearButtonTitle, action: .clear),
                .utility("+/-", action: .toggleSign),
                .utility("%", action: .percent),
                .operator("÷", action: .operation(.divide))
            ], theme: theme, baseWidth: baseWidth, spacing: spacing, compact: compact)

            keypadRow([
                .digit("7"),
                .digit("8"),
                .digit("9"),
                .operator("x", action: .operation(.multiply))
            ], theme: theme, baseWidth: baseWidth, spacing: spacing, compact: compact)

            keypadRow([
                .digit("4"),
                .digit("5"),
                .digit("6"),
                .operator("-", action: .operation(.subtract))
            ], theme: theme, baseWidth: baseWidth, spacing: spacing, compact: compact)

            keypadRow([
                .digit("1"),
                .digit("2"),
                .digit("3"),
                .operator("+", action: .operation(.add))
            ], theme: theme, baseWidth: baseWidth, spacing: spacing, compact: compact)

            keypadRow([
                .digit("0", widthMultiplier: 2),
                .digit("."),
                .equals
            ], theme: theme, baseWidth: baseWidth, spacing: spacing, compact: compact)
        }
        .frame(maxWidth: maxWidth)
    }

    private func keypadRow(_ items: [CalculatorKey], theme: CalculatorTheme, baseWidth: CGFloat, spacing: CGFloat, compact: Bool) -> some View {
        HStack(spacing: spacing) {
            ForEach(items) { item in
                CalculatorKeyButton(
                    item: item,
                    palette: theme.palette(for: item.style),
                    theme: theme,
                    width: item.widthMultiplier == 2 ? baseWidth * 2 + spacing : baseWidth,
                    height: compact ? baseWidth * 0.94 : baseWidth
                ) {
                    trigger(item.action, style: item.style)
                }
            }
        }
    }

    private func displayFontSize(compact: Bool) -> CGFloat {
        let count = viewModel.displayText.count

        switch count {
        case 0...6:
            return compact ? 66 : 74
        case 7...9:
            return compact ? 58 : 66
        case 10...12:
            return compact ? 50 : 56
        default:
            return compact ? 44 : 48
        }
    }

    @ViewBuilder
    private func displayChromeOverlay(theme: CalculatorTheme, compact: Bool) -> some View {
        switch theme.chrome {
        case .glass:
            RoundedRectangle(cornerRadius: theme.panelCornerRadius, style: .continuous)
                .stroke(theme.displayGlow, lineWidth: 1)
                .blur(radius: 16)

        case .arcade:
            RoundedRectangle(cornerRadius: theme.panelCornerRadius, style: .continuous)
                .inset(by: 12)
                .stroke(theme.displayGlow, lineWidth: 2)
                .overlay(alignment: .topLeading) {
                    Rectangle()
                        .fill(theme.displayGlow.opacity(0.75))
                        .frame(width: 74, height: 6)
                        .offset(x: 18, y: 18)
                }

        case .retroDesk:
            RoundedRectangle(cornerRadius: theme.panelCornerRadius, style: .continuous)
                .stroke(theme.displayGlow.opacity(0.8), lineWidth: 1.4)
                .padding(12)
                .overlay(alignment: .bottomTrailing) {
                    Capsule(style: .continuous)
                        .fill(theme.displayGlow.opacity(0.45))
                        .frame(width: compact ? 86 : 108, height: 16)
                        .blur(radius: 10)
                        .offset(x: -18, y: -18)
                }

        case .neon:
            RoundedRectangle(cornerRadius: theme.panelCornerRadius, style: .continuous)
                .stroke(theme.previewGradient, lineWidth: 1.3)
                .shadow(color: theme.displayGlow, radius: 18, x: 0, y: 0)
                .padding(8)

        case .editorial:
            VStack {
                Rectangle()
                    .fill(theme.supportingTextColor.opacity(0.15))
                    .frame(height: 1)
                Spacer()
                Rectangle()
                    .fill(theme.supportingTextColor.opacity(0.15))
                    .frame(height: 1)
            }
            .padding(.vertical, compact ? 46 : 52)
            .padding(.horizontal, 18)
        }
    }

    private func trigger(_ action: CalculatorAction, style: CalculatorKeyStyle) {
        Haptics.play(for: style)

        switch action {
        case .digit(let value):
            if value == "." {
                viewModel.inputDecimal()
            } else {
                viewModel.inputDigit(value)
            }
        case .clear:
            viewModel.clear()
        case .toggleSign:
            viewModel.toggleSign()
        case .percent:
            viewModel.applyPercent()
        case .operation(let operation):
            viewModel.applyOperation(operation)
        case .equals:
            viewModel.evaluate()
        }
    }
}

private struct CalculatorBackground: View {
    let theme: CalculatorTheme

    @State private var animate = false

    var body: some View {
        ZStack {
            theme.backgroundGradient
                .ignoresSafeArea()

            ForEach(theme.ambientBlobs) { blob in
                Circle()
                    .fill(blob.color)
                    .frame(width: blob.size, height: blob.size)
                    .blur(radius: blob.blur)
                    .offset(
                        x: animate ? blob.endOffset.width : blob.startOffset.width,
                        y: animate ? blob.endOffset.height : blob.startOffset.height
                    )
            }

            CalculatorPatternOverlay(
                pattern: theme.pattern,
                tint: theme.patternTint,
                opacity: theme.patternOpacity
            )
            .ignoresSafeArea()

            Rectangle()
                .fill(theme.overlayColor)
                .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

private struct CalculatorPatternOverlay: View {
    let pattern: CalculatorPattern
    let tint: Color
    let opacity: Double

    var body: some View {
        GeometryReader { _ in
            switch pattern {
            case .none:
                Color.clear

            case .grid:
                Canvas { context, size in
                    let spacing: CGFloat = 26
                    var path = Path()

                    for x in stride(from: 0, through: size.width, by: spacing) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                    }

                    for y in stride(from: 0, through: size.height, by: spacing) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }

                    context.stroke(path, with: .color(tint.opacity(opacity)), lineWidth: 0.7)
                }

            case .scanlines:
                Canvas { context, size in
                    let spacing: CGFloat = 6
                    var path = Path()

                    for y in stride(from: 0, through: size.height, by: spacing) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                    }

                    context.stroke(path, with: .color(tint.opacity(opacity)), lineWidth: 0.5)
                }

            case .dots:
                Canvas { context, size in
                    let spacing: CGFloat = 22
                    let radius: CGFloat = 1.2

                    for x in stride(from: 0, through: size.width, by: spacing) {
                        for y in stride(from: 0, through: size.height, by: spacing) {
                            let rect = CGRect(x: x, y: y, width: radius * 2, height: radius * 2)
                            context.fill(Path(ellipseIn: rect), with: .color(tint.opacity(opacity)))
                        }
                    }
                }

            case .checker:
                Canvas { context, size in
                    let spacing: CGFloat = 18

                    for column in stride(from: 0, to: size.width, by: spacing) {
                        for row in stride(from: 0, to: size.height, by: spacing) {
                            let isVisible = (Int(column / spacing) + Int(row / spacing)).isMultiple(of: 2)
                            guard isVisible else { continue }
                            let rect = CGRect(x: column, y: row, width: spacing / 2.5, height: spacing / 2.5)
                            context.fill(Path(rect), with: .color(tint.opacity(opacity)))
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct CalculatorSurface: View {
    let theme: CalculatorTheme
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let shadowYOffset: CGFloat
    let borderWidth: CGFloat

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    var body: some View {
        shape
            .fill(theme.panelColor)
            .background(.ultraThinMaterial, in: shape)
            .overlay {
                shape
                    .strokeBorder(theme.panelStroke, lineWidth: borderWidth)
            }
            .overlay {
                switch theme.chrome {
                case .glass:
                    shape
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.8)
                        .blur(radius: 2)

                case .arcade:
                    shape
                        .inset(by: 8)
                        .strokeBorder(theme.highlightColors[0].opacity(0.24), lineWidth: 1.4)

                case .retroDesk:
                    shape
                        .fill(LinearGradient(colors: [Color.white.opacity(0.18), .clear], startPoint: .top, endPoint: .center))

                case .neon:
                    shape
                        .strokeBorder(theme.previewGradient, lineWidth: 1.2)
                        .blur(radius: 6)

                case .editorial:
                    shape
                        .inset(by: 10)
                        .strokeBorder(theme.supportingTextColor.opacity(0.14), lineWidth: 1)
                }
            }
            .shadow(color: theme.panelShadow, radius: shadowRadius, x: 0, y: shadowYOffset)
    }
}

private struct SkinPreviewCard: View {
    let skin: CalculatorSkin
    let currentTheme: CalculatorTheme
    let isSelected: Bool
    let action: () -> Void

    private var skinTheme: CalculatorTheme {
        skin.theme
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: max(10, skinTheme.keyCornerRadius * 0.6), style: .continuous)
                        .fill(skinTheme.previewGradient)
                        .frame(width: 72, height: 72)
                        .overlay {
                            CalculatorPatternOverlay(
                                pattern: skinTheme.pattern,
                                tint: skinTheme.patternTint,
                                opacity: min(skinTheme.patternOpacity + 0.06, 0.22)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: max(10, skinTheme.keyCornerRadius * 0.6), style: .continuous))
                        }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(skinTheme.badge)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(skinTheme.highlightForeground)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(skinTheme.previewGradient)
                            )

                        Spacer()

                        HStack(spacing: 5) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(skinTheme.palette(for: .digit).gradient)
                                .frame(width: 20, height: 10)
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(skinTheme.palette(for: .utility).gradient)
                                .frame(width: 14, height: 10)
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(skinTheme.palette(for: .operator).gradient)
                                .frame(width: 14, height: 10)
                        }
                    }
                    .padding(8)

                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(currentTheme.highlightForeground)
                                    .padding(6)
                            }
                            Spacer()
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(skinTheme.name)
                        .font(.system(size: 14, weight: .bold, design: skinTheme.titleFontDesign))
                        .foregroundStyle(currentTheme.headlineColor)
                        .lineLimit(1)

                    Text(skinTheme.caption)
                        .font(.system(size: 11, weight: .medium, design: skinTheme.buttonFontDesign))
                        .foregroundStyle(currentTheme.supportingTextColor)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(width: 170, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: max(14, currentTheme.selectorCornerRadius - 4), style: .continuous)
                    .fill(currentTheme.controlColor.opacity(isSelected ? 0.98 : 0.78))
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: max(14, currentTheme.selectorCornerRadius - 4), style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: max(14, currentTheme.selectorCornerRadius - 4), style: .continuous)
                            .strokeBorder(
                                isSelected ? AnyShapeStyle(currentTheme.previewGradient) : AnyShapeStyle(currentTheme.controlStroke),
                                lineWidth: isSelected ? 1.6 : 1
                            )
                    }
                    .shadow(color: currentTheme.panelShadow.opacity(0.8), radius: 8, x: 0, y: 6)
            }
        }
        .buttonStyle(CalculatorPressStyle())
    }
}

private struct CalculatorKeyButton: View {
    let item: CalculatorKey
    let palette: CalculatorButtonPalette
    let theme: CalculatorTheme
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(item.label)
                .font(.system(size: buttonFontSize, weight: theme.buttonWeight, design: theme.buttonFontDesign))
                .tracking(theme.chrome == .arcade ? 1.4 : 0)
                .foregroundStyle(palette.foreground)
                .frame(maxWidth: .infinity, alignment: item.widthMultiplier == 2 ? .leading : .center)
                .padding(.leading, item.widthMultiplier == 2 ? 24 : 0)
                .frame(width: width, height: height)
                .background(
                    RoundedRectangle(cornerRadius: theme.keyCornerRadius, style: .continuous)
                        .fill(palette.gradient)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: theme.keyCornerRadius, style: .continuous)
                        .strokeBorder(palette.borderGradient, lineWidth: theme.buttonBorderWidth)
                }
                .overlay {
                    buttonChromeOverlay
                }
                .shadow(color: palette.shadow, radius: theme.keyCornerRadius * 0.6, x: 0, y: theme.keyCornerRadius * 0.4)
        }
        .buttonStyle(CalculatorPressStyle())
    }

    private var buttonFontSize: CGFloat {
        switch theme.chrome {
        case .arcade:
            return item.style == .digit ? 28 : 21
        case .editorial:
            return item.style == .digit ? 29 : 22
        default:
            return item.style == .digit ? 32 : 24
        }
    }

    @ViewBuilder
    private var buttonChromeOverlay: some View {
        switch theme.chrome {
        case .glass:
            RoundedRectangle(cornerRadius: theme.keyCornerRadius, style: .continuous)
                .fill(LinearGradient(colors: [Color.white.opacity(0.12), .clear], startPoint: .top, endPoint: .bottom))

        case .arcade:
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 6)
                Spacer()
            }
            .clipShape(RoundedRectangle(cornerRadius: theme.keyCornerRadius, style: .continuous))

        case .retroDesk:
            RoundedRectangle(cornerRadius: theme.keyCornerRadius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.35), lineWidth: 0.8)

        case .neon:
            RoundedRectangle(cornerRadius: theme.keyCornerRadius, style: .continuous)
                .strokeBorder(theme.previewGradient, lineWidth: item.style == .equals || item.style == .operator ? 1.2 : 0.8)
                .blur(radius: item.style == .equals || item.style == .operator ? 4 : 2)

        case .editorial:
            RoundedRectangle(cornerRadius: theme.keyCornerRadius, style: .continuous)
                .offset(x: 2, y: 2)
                .blendMode(.multiply)
                .foregroundStyle(theme.supportingTextColor.opacity(0.10))
        }
    }
}

private struct CalculatorPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.spring(response: 0.22, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

private struct CalculatorKey: Identifiable {
    let id: String
    let label: String
    let style: CalculatorKeyStyle
    let action: CalculatorAction
    let widthMultiplier: CGFloat

    static func digit(_ label: String, widthMultiplier: CGFloat = 1) -> CalculatorKey {
        let action: CalculatorAction = label == "." ? .digit(".") : .digit(label)
        return CalculatorKey(id: "digit-\(label)-\(Int(widthMultiplier))", label: label, style: .digit, action: action, widthMultiplier: widthMultiplier)
    }

    static func utility(_ label: String, action: CalculatorAction) -> CalculatorKey {
        CalculatorKey(id: "utility-\(label)", label: label, style: .utility, action: action, widthMultiplier: 1)
    }

    static func `operator`(_ label: String, action: CalculatorAction) -> CalculatorKey {
        CalculatorKey(id: "operator-\(label)", label: label, style: .operator, action: action, widthMultiplier: 1)
    }

    static let equals = CalculatorKey(id: "equals", label: "=", style: .equals, action: .equals, widthMultiplier: 1)
}

private enum CalculatorAction {
    case digit(String)
    case clear
    case toggleSign
    case percent
    case operation(CalculatorOperation)
    case equals
}

private enum Haptics {
    static func play(for style: CalculatorKeyStyle) {
        switch style {
        case .digit:
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        case .utility:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .operator:
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        case .equals:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
