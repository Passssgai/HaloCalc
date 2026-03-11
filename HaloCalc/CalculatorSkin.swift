import Foundation
import SwiftUI

enum CalculatorKeyStyle {
    case digit
    case utility
    case `operator`
    case equals
}

enum CalculatorPattern {
    case none
    case grid
    case scanlines
    case dots
    case checker
}

enum CalculatorChromeStyle {
    case glass
    case arcade
    case retroDesk
    case neon
    case editorial
}

struct CalculatorButtonPalette {
    let colors: [Color]
    let foreground: Color
    let shadow: Color
    let borderColors: [Color]

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var borderGradient: LinearGradient {
        LinearGradient(colors: borderColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct CalculatorBackdropBlob: Identifiable {
    let id: String
    let color: Color
    let size: CGFloat
    let blur: CGFloat
    let startOffset: CGSize
    let endOffset: CGSize
}

struct CalculatorTheme {
    let name: String
    let caption: String
    let badge: String
    let chrome: CalculatorChromeStyle
    let displayLabel: String
    let displaySubLabel: String
    let colorScheme: ColorScheme
    let backgroundColors: [Color]
    let ambientBlobs: [CalculatorBackdropBlob]
    let overlayColor: Color
    let pattern: CalculatorPattern
    let patternTint: Color
    let patternOpacity: Double
    let panelColor: Color
    let panelStrokeColors: [Color]
    let panelShadow: Color
    let headlineColor: Color
    let supportingTextColor: Color
    let controlColor: Color
    let controlStrokeColors: [Color]
    let highlightColors: [Color]
    let highlightForeground: Color
    let displayGlow: Color
    let titleFontDesign: Font.Design
    let displayFontDesign: Font.Design
    let buttonFontDesign: Font.Design
    let titleWeight: Font.Weight
    let displayWeight: Font.Weight
    let buttonWeight: Font.Weight
    let panelCornerRadius: CGFloat
    let keyCornerRadius: CGFloat
    let selectorCornerRadius: CGFloat
    let panelBorderWidth: CGFloat
    let buttonBorderWidth: CGFloat
    let digitPalette: CalculatorButtonPalette
    let utilityPalette: CalculatorButtonPalette
    let operatorPalette: CalculatorButtonPalette
    let equalsPalette: CalculatorButtonPalette

    var backgroundGradient: LinearGradient {
        LinearGradient(colors: backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var panelStroke: LinearGradient {
        LinearGradient(colors: panelStrokeColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var controlStroke: LinearGradient {
        LinearGradient(colors: controlStrokeColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var previewGradient: LinearGradient {
        LinearGradient(colors: highlightColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    func palette(for style: CalculatorKeyStyle) -> CalculatorButtonPalette {
        switch style {
        case .digit:
            return digitPalette
        case .utility:
            return utilityPalette
        case .operator:
            return operatorPalette
        case .equals:
            return equalsPalette
        }
    }
}

enum CalculatorSkin: String, CaseIterable, Identifiable {
    case modern
    case pixel
    case retro
    case neon
    case paper

    var id: String { rawValue }

    var theme: CalculatorTheme {
        switch self {
        case .modern:
            return CalculatorTheme(
                name: "Modern",
                caption: "Glass motion",
                badge: "MOD",
                chrome: .glass,
                displayLabel: "HALO CALC",
                displaySubLabel: "Adaptive glass interface",
                colorScheme: .dark,
                backgroundColors: [color(7, 20, 38), color(16, 44, 76), color(24, 82, 112)],
                ambientBlobs: [
                    CalculatorBackdropBlob(id: "sky", color: color(95, 199, 255).opacity(0.40), size: 320, blur: 42, startOffset: CGSize(width: -148, height: -222), endOffset: CGSize(width: -92, height: -278)),
                    CalculatorBackdropBlob(id: "ember", color: color(255, 157, 95).opacity(0.30), size: 250, blur: 42, startOffset: CGSize(width: 116, height: -62), endOffset: CGSize(width: 166, height: -22)),
                    CalculatorBackdropBlob(id: "mint", color: color(85, 240, 208).opacity(0.24), size: 356, blur: 58, startOffset: CGSize(width: -8, height: 214), endOffset: CGSize(width: -70, height: 256))
                ],
                overlayColor: Color.white.opacity(0.03),
                pattern: .none,
                patternTint: .clear,
                patternOpacity: 0,
                panelColor: Color.white.opacity(0.09),
                panelStrokeColors: [Color.white.opacity(0.34), Color.white.opacity(0.08)],
                panelShadow: Color.black.opacity(0.28),
                headlineColor: .white,
                supportingTextColor: Color.white.opacity(0.70),
                controlColor: Color.white.opacity(0.08),
                controlStrokeColors: [Color.white.opacity(0.22), Color.white.opacity(0.05)],
                highlightColors: [color(63, 182, 255), color(33, 126, 229), color(48, 210, 199)],
                highlightForeground: color(8, 23, 41),
                displayGlow: color(67, 192, 255).opacity(0.22),
                titleFontDesign: .rounded,
                displayFontDesign: .rounded,
                buttonFontDesign: .rounded,
                titleWeight: .bold,
                displayWeight: .light,
                buttonWeight: .semibold,
                panelCornerRadius: 34,
                keyCornerRadius: 30,
                selectorCornerRadius: 28,
                panelBorderWidth: 1,
                buttonBorderWidth: 1,
                digitPalette: CalculatorButtonPalette(
                    colors: [color(34, 49, 77), color(13, 20, 36)],
                    foreground: .white,
                    shadow: Color.black.opacity(0.24),
                    borderColors: [Color.white.opacity(0.24), Color.white.opacity(0.05)]
                ),
                utilityPalette: CalculatorButtonPalette(
                    colors: [color(77, 102, 138), color(32, 46, 73)],
                    foreground: .white,
                    shadow: color(16, 31, 58).opacity(0.32),
                    borderColors: [Color.white.opacity(0.26), Color.white.opacity(0.06)]
                ),
                operatorPalette: CalculatorButtonPalette(
                    colors: [color(255, 184, 82), color(240, 102, 55)],
                    foreground: color(35, 18, 10),
                    shadow: color(190, 75, 37).opacity(0.34),
                    borderColors: [Color.white.opacity(0.28), Color.white.opacity(0.08)]
                ),
                equalsPalette: CalculatorButtonPalette(
                    colors: [color(92, 236, 204), color(27, 163, 205)],
                    foreground: color(8, 28, 36),
                    shadow: color(17, 129, 154).opacity(0.32),
                    borderColors: [Color.white.opacity(0.26), Color.white.opacity(0.08)]
                )
            )

        case .pixel:
            return CalculatorTheme(
                name: "Pixel",
                caption: "8-bit arcade",
                badge: "PIX",
                chrome: .arcade,
                displayLabel: "INSERT COIN",
                displaySubLabel: "Hi-score keypad",
                colorScheme: .dark,
                backgroundColors: [color(8, 14, 8), color(19, 43, 26), color(36, 74, 48)],
                ambientBlobs: [
                    CalculatorBackdropBlob(id: "green", color: color(126, 247, 140).opacity(0.14), size: 260, blur: 24, startOffset: CGSize(width: -130, height: -160), endOffset: CGSize(width: -95, height: -190)),
                    CalculatorBackdropBlob(id: "amber", color: color(255, 205, 90).opacity(0.12), size: 200, blur: 24, startOffset: CGSize(width: 120, height: -40), endOffset: CGSize(width: 150, height: -16))
                ],
                overlayColor: color(6, 11, 6).opacity(0.18),
                pattern: .checker,
                patternTint: color(126, 247, 140),
                patternOpacity: 0.10,
                panelColor: color(17, 31, 18).opacity(0.92),
                panelStrokeColors: [color(166, 255, 179).opacity(0.50), color(71, 127, 78).opacity(0.65)],
                panelShadow: color(0, 0, 0).opacity(0.36),
                headlineColor: color(208, 255, 180),
                supportingTextColor: color(150, 209, 138).opacity(0.82),
                controlColor: color(19, 35, 21).opacity(0.96),
                controlStrokeColors: [color(143, 222, 135).opacity(0.46), color(61, 96, 58).opacity(0.80)],
                highlightColors: [color(173, 255, 103), color(113, 206, 86), color(255, 205, 88)],
                highlightForeground: color(17, 30, 15),
                displayGlow: color(132, 255, 156).opacity(0.10),
                titleFontDesign: .monospaced,
                displayFontDesign: .monospaced,
                buttonFontDesign: .monospaced,
                titleWeight: .heavy,
                displayWeight: .bold,
                buttonWeight: .bold,
                panelCornerRadius: 14,
                keyCornerRadius: 10,
                selectorCornerRadius: 14,
                panelBorderWidth: 2.2,
                buttonBorderWidth: 2.2,
                digitPalette: CalculatorButtonPalette(
                    colors: [color(32, 58, 33), color(19, 34, 20)],
                    foreground: color(212, 255, 186),
                    shadow: color(0, 0, 0).opacity(0.18),
                    borderColors: [color(162, 255, 174), color(60, 105, 64)]
                ),
                utilityPalette: CalculatorButtonPalette(
                    colors: [color(79, 90, 40), color(52, 61, 27)],
                    foreground: color(255, 237, 160),
                    shadow: color(0, 0, 0).opacity(0.18),
                    borderColors: [color(255, 234, 148), color(115, 102, 54)]
                ),
                operatorPalette: CalculatorButtonPalette(
                    colors: [color(255, 146, 84), color(188, 78, 36)],
                    foreground: color(42, 20, 9),
                    shadow: color(0, 0, 0).opacity(0.16),
                    borderColors: [color(255, 210, 183), color(148, 61, 29)]
                ),
                equalsPalette: CalculatorButtonPalette(
                    colors: [color(109, 226, 250), color(26, 149, 190)],
                    foreground: color(10, 33, 40),
                    shadow: color(0, 0, 0).opacity(0.16),
                    borderColors: [color(190, 248, 255), color(32, 118, 147)]
                )
            )

        case .retro:
            return CalculatorTheme(
                name: "Retro",
                caption: "Coffee desk",
                badge: "RET",
                chrome: .retroDesk,
                displayLabel: "DESK-82",
                displaySubLabel: "Warm analogue mood",
                colorScheme: .light,
                backgroundColors: [color(246, 234, 214), color(220, 189, 148), color(165, 110, 76)],
                ambientBlobs: [
                    CalculatorBackdropBlob(id: "cream", color: Color.white.opacity(0.22), size: 300, blur: 34, startOffset: CGSize(width: -140, height: -210), endOffset: CGSize(width: -100, height: -246)),
                    CalculatorBackdropBlob(id: "rose", color: color(193, 97, 79).opacity(0.16), size: 240, blur: 34, startOffset: CGSize(width: 112, height: -40), endOffset: CGSize(width: 152, height: -10))
                ],
                overlayColor: color(255, 247, 235).opacity(0.16),
                pattern: .dots,
                patternTint: color(135, 95, 67),
                patternOpacity: 0.12,
                panelColor: color(255, 248, 236).opacity(0.84),
                panelStrokeColors: [Color.white.opacity(0.92), color(164, 118, 85).opacity(0.26)],
                panelShadow: color(114, 74, 50).opacity(0.18),
                headlineColor: color(71, 46, 31),
                supportingTextColor: color(110, 78, 59).opacity(0.78),
                controlColor: color(255, 248, 238).opacity(0.92),
                controlStrokeColors: [Color.white.opacity(0.90), color(169, 125, 92).opacity(0.22)],
                highlightColors: [color(205, 121, 80), color(150, 84, 58), color(242, 192, 123)],
                highlightForeground: .white,
                displayGlow: color(219, 188, 140).opacity(0.24),
                titleFontDesign: .serif,
                displayFontDesign: .serif,
                buttonFontDesign: .serif,
                titleWeight: .bold,
                displayWeight: .semibold,
                buttonWeight: .semibold,
                panelCornerRadius: 28,
                keyCornerRadius: 18,
                selectorCornerRadius: 24,
                panelBorderWidth: 1.4,
                buttonBorderWidth: 1.5,
                digitPalette: CalculatorButtonPalette(
                    colors: [color(255, 249, 241), color(240, 220, 199)],
                    foreground: color(77, 52, 37),
                    shadow: color(182, 133, 104).opacity(0.18),
                    borderColors: [Color.white.opacity(0.90), color(193, 153, 125).opacity(0.16)]
                ),
                utilityPalette: CalculatorButtonPalette(
                    colors: [color(238, 214, 187), color(222, 186, 155)],
                    foreground: color(86, 57, 40),
                    shadow: color(167, 115, 87).opacity(0.18),
                    borderColors: [Color.white.opacity(0.75), color(189, 151, 121).opacity(0.14)]
                ),
                operatorPalette: CalculatorButtonPalette(
                    colors: [color(206, 121, 80), color(155, 82, 56)],
                    foreground: .white,
                    shadow: color(126, 67, 47).opacity(0.24),
                    borderColors: [Color.white.opacity(0.32), color(238, 199, 171).opacity(0.16)]
                ),
                equalsPalette: CalculatorButtonPalette(
                    colors: [color(96, 74, 61), color(56, 42, 35)],
                    foreground: color(251, 239, 214),
                    shadow: color(77, 58, 48).opacity(0.20),
                    borderColors: [Color.white.opacity(0.22), color(166, 125, 102).opacity(0.14)]
                )
            )

        case .neon:
            return CalculatorTheme(
                name: "Neon",
                caption: "Club glow",
                badge: "NEO",
                chrome: .neon,
                displayLabel: "AFTER DARK",
                displaySubLabel: "Night grid operator",
                colorScheme: .dark,
                backgroundColors: [color(6, 6, 16), color(20, 12, 42), color(12, 34, 68)],
                ambientBlobs: [
                    CalculatorBackdropBlob(id: "cyan", color: color(67, 238, 255).opacity(0.30), size: 300, blur: 42, startOffset: CGSize(width: -144, height: -220), endOffset: CGSize(width: -102, height: -272)),
                    CalculatorBackdropBlob(id: "pink", color: color(255, 89, 180).opacity(0.28), size: 240, blur: 46, startOffset: CGSize(width: 138, height: -52), endOffset: CGSize(width: 176, height: -10)),
                    CalculatorBackdropBlob(id: "violet", color: color(128, 102, 255).opacity(0.20), size: 340, blur: 54, startOffset: CGSize(width: 0, height: 218), endOffset: CGSize(width: -56, height: 250))
                ],
                overlayColor: Color.black.opacity(0.14),
                pattern: .grid,
                patternTint: color(77, 235, 255),
                patternOpacity: 0.12,
                panelColor: color(11, 10, 25).opacity(0.84),
                panelStrokeColors: [color(255, 109, 193).opacity(0.40), color(61, 229, 255).opacity(0.24)],
                panelShadow: color(0, 0, 0).opacity(0.42),
                headlineColor: .white,
                supportingTextColor: Color.white.opacity(0.74),
                controlColor: color(14, 14, 31).opacity(0.84),
                controlStrokeColors: [color(255, 111, 195).opacity(0.36), color(65, 232, 255).opacity(0.22)],
                highlightColors: [color(67, 235, 255), color(255, 87, 174), color(255, 171, 74)],
                highlightForeground: color(24, 18, 39),
                displayGlow: color(77, 235, 255).opacity(0.34),
                titleFontDesign: .rounded,
                displayFontDesign: .monospaced,
                buttonFontDesign: .rounded,
                titleWeight: .heavy,
                displayWeight: .medium,
                buttonWeight: .bold,
                panelCornerRadius: 30,
                keyCornerRadius: 22,
                selectorCornerRadius: 26,
                panelBorderWidth: 1.4,
                buttonBorderWidth: 1.2,
                digitPalette: CalculatorButtonPalette(
                    colors: [color(25, 25, 47), color(11, 11, 26)],
                    foreground: .white,
                    shadow: color(0, 0, 0).opacity(0.30),
                    borderColors: [color(77, 235, 255).opacity(0.26), color(255, 109, 193).opacity(0.12)]
                ),
                utilityPalette: CalculatorButtonPalette(
                    colors: [color(51, 30, 78), color(19, 16, 46)],
                    foreground: color(228, 218, 255),
                    shadow: color(0, 0, 0).opacity(0.30),
                    borderColors: [color(255, 106, 189).opacity(0.26), color(74, 234, 255).opacity(0.10)]
                ),
                operatorPalette: CalculatorButtonPalette(
                    colors: [color(66, 235, 255), color(17, 137, 255)],
                    foreground: color(13, 24, 44),
                    shadow: color(0, 0, 0).opacity(0.22),
                    borderColors: [Color.white.opacity(0.24), color(68, 213, 255).opacity(0.18)]
                ),
                equalsPalette: CalculatorButtonPalette(
                    colors: [color(255, 89, 181), color(255, 151, 90)],
                    foreground: color(48, 16, 31),
                    shadow: color(0, 0, 0).opacity(0.20),
                    borderColors: [Color.white.opacity(0.22), color(255, 186, 120).opacity(0.18)]
                )
            )

        case .paper:
            return CalculatorTheme(
                name: "Paper",
                caption: "Editorial calm",
                badge: "PPR",
                chrome: .editorial,
                displayLabel: "EDITORIAL",
                displaySubLabel: "Quiet paper stack",
                colorScheme: .light,
                backgroundColors: [color(245, 244, 239), color(226, 227, 219), color(197, 203, 201)],
                ambientBlobs: [
                    CalculatorBackdropBlob(id: "fog", color: Color.white.opacity(0.30), size: 320, blur: 48, startOffset: CGSize(width: -140, height: -220), endOffset: CGSize(width: -100, height: -264)),
                    CalculatorBackdropBlob(id: "sage", color: color(155, 173, 155).opacity(0.16), size: 250, blur: 40, startOffset: CGSize(width: 120, height: -68), endOffset: CGSize(width: 158, height: -24))
                ],
                overlayColor: Color.white.opacity(0.12),
                pattern: .scanlines,
                patternTint: color(120, 130, 128),
                patternOpacity: 0.10,
                panelColor: Color.white.opacity(0.86),
                panelStrokeColors: [Color.white.opacity(0.90), color(154, 164, 158).opacity(0.18)],
                panelShadow: color(120, 130, 128).opacity(0.14),
                headlineColor: color(36, 44, 46),
                supportingTextColor: color(90, 99, 100).opacity(0.72),
                controlColor: Color.white.opacity(0.92),
                controlStrokeColors: [Color.white.opacity(0.94), color(156, 166, 160).opacity(0.16)],
                highlightColors: [color(90, 110, 117), color(154, 173, 155), color(214, 176, 120)],
                highlightForeground: .white,
                displayGlow: color(160, 170, 163).opacity(0.10),
                titleFontDesign: .serif,
                displayFontDesign: .default,
                buttonFontDesign: .default,
                titleWeight: .bold,
                displayWeight: .medium,
                buttonWeight: .semibold,
                panelCornerRadius: 24,
                keyCornerRadius: 14,
                selectorCornerRadius: 22,
                panelBorderWidth: 1,
                buttonBorderWidth: 1,
                digitPalette: CalculatorButtonPalette(
                    colors: [Color.white.opacity(0.98), color(236, 236, 231)],
                    foreground: color(42, 49, 51),
                    shadow: color(131, 140, 135).opacity(0.12),
                    borderColors: [Color.white.opacity(0.92), color(171, 179, 173).opacity(0.12)]
                ),
                utilityPalette: CalculatorButtonPalette(
                    colors: [color(225, 228, 220), color(205, 210, 201)],
                    foreground: color(60, 68, 68),
                    shadow: color(124, 132, 129).opacity(0.12),
                    borderColors: [Color.white.opacity(0.82), color(166, 173, 169).opacity(0.10)]
                ),
                operatorPalette: CalculatorButtonPalette(
                    colors: [color(95, 112, 120), color(56, 70, 74)],
                    foreground: .white,
                    shadow: color(97, 110, 112).opacity(0.16),
                    borderColors: [Color.white.opacity(0.18), color(164, 178, 180).opacity(0.12)]
                ),
                equalsPalette: CalculatorButtonPalette(
                    colors: [color(214, 177, 120), color(185, 131, 88)],
                    foreground: color(71, 50, 29),
                    shadow: color(171, 136, 92).opacity(0.16),
                    borderColors: [Color.white.opacity(0.24), color(232, 205, 166).opacity(0.14)]
                )
            )
        }
    }
}

@MainActor
final class CalculatorSkinManager: ObservableObject {
    @Published private(set) var selectedSkin: CalculatorSkin
    @Published private(set) var isAutoCycling: Bool

    let autoCycleInterval: TimeInterval = 8

    private let defaults: UserDefaults
    private let selectedSkinKey = "HaloCalc.selectedSkin"
    private let autoCycleKey = "HaloCalc.autoCycle"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let savedSkin = defaults.string(forKey: selectedSkinKey), let skin = CalculatorSkin(rawValue: savedSkin) {
            selectedSkin = skin
        } else {
            selectedSkin = .modern
        }

        if defaults.object(forKey: autoCycleKey) == nil {
            isAutoCycling = true
        } else {
            isAutoCycling = defaults.bool(forKey: autoCycleKey)
        }
    }

    var theme: CalculatorTheme {
        selectedSkin.theme
    }

    func select(_ skin: CalculatorSkin) {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
            selectedSkin = skin
            isAutoCycling = false
        }
        persist()
    }

    func toggleAutoCycling() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            isAutoCycling.toggle()
        }
        persist()
    }

    func advanceIfNeeded() {
        guard isAutoCycling else { return }
        advance()
    }

    private func advance() {
        let skins = CalculatorSkin.allCases
        guard let currentIndex = skins.firstIndex(of: selectedSkin) else { return }
        let nextIndex = skins.index(after: currentIndex)
        let resolvedIndex = nextIndex == skins.endIndex ? skins.startIndex : nextIndex

        withAnimation(.spring(response: 0.7, dampingFraction: 0.86)) {
            selectedSkin = skins[resolvedIndex]
        }
        persist()
    }

    private func persist() {
        defaults.set(selectedSkin.rawValue, forKey: selectedSkinKey)
        defaults.set(isAutoCycling, forKey: autoCycleKey)
    }
}

private func color(_ red: Double, _ green: Double, _ blue: Double) -> Color {
    Color(red: red / 255, green: green / 255, blue: blue / 255)
}
