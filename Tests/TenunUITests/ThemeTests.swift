import Testing
@testable import TenunUI

/// shadcn/ui writes its theme in OKLCH. These are its neutral values next to the sRGB hex
/// Tailwind publishes for the same neutral steps, so the conversion is checked against both.
struct OKLCHTests {
    @Test(arguments: [
        (OKLCH(1, 0, 0), "#ffffff"),
        (OKLCH(0.985, 0, 0), "#fafafa"),
        (OKLCH(0.97, 0, 0), "#f5f5f5"),
        (OKLCH(0.922, 0, 0), "#e5e5e5"),
        (OKLCH(0.708, 0, 0), "#a1a1a1"),
        (OKLCH(0.556, 0, 0), "#737373"),
        (OKLCH(0.269, 0, 0), "#262626"),
        (OKLCH(0.205, 0, 0), "#171717"),
        (OKLCH(0.145, 0, 0), "#0a0a0a"),
    ])
    func convertsToTheSameSRGBAsTailwind(colour: OKLCH, hex: String) {
        #expect(colour.rgb.hex == hex)
    }

    @Test func aChromaticColourStaysInGamut() {
        let red = OKLCH(0.577, 0.245, 27.325).rgb // shadcn's destructive
        for channel in [red.red, red.green, red.blue] { #expect((0...1).contains(channel)) }
        #expect(red.red > 0.8 && red.green < 0.1)
    }
}

struct ContrastTests {
    @Test func blackOnWhiteIs21To1() {
        #expect(abs(RGB.black.contrast(with: .white) - 21) < 0.01)
    }

    @Test func aTranslucentColourIsMeasuredOverWhatIsBehindIt() {
        let grey = RGB(red: 0.5, green: 0.5, blue: 0.5)
        let half = RGB.white.withAlpha(0.5)
        #expect(half.over(.black).hex == RGB(red: 0.5, green: 0.5, blue: 0.5).hex)
        #expect(half.over(.black).contrast(with: grey) < 1.01)
    }
}

/// Every text and control pair the components draw, in both appearances. Text needs 4.5:1,
/// control edges 3:1 (WCAG 1.4.3 and 1.4.11).
struct NeutralThemeContrastTests {
    static let theme = TenunTheme.neutral

    @Test(arguments: TenunTheme.Appearance.allCases)
    func textMeets4Point5To1(appearance: TenunTheme.Appearance) {
        let t = Self.theme.resolved(appearance)
        let pairs: [(String, RGB, RGB)] = [
            ("foreground on background", t.foreground, t.background),
            ("card text", t.cardForeground, t.card),
            ("primary button", t.primaryForeground, t.primary),
            ("secondary button", t.secondaryForeground, t.secondary),
            ("muted text on background", t.mutedForeground, t.background),
            ("muted text on card", t.mutedForeground, t.card),
            ("muted text on muted", t.mutedForeground, t.muted),
            ("accent", t.accentForeground, t.accent),
            ("destructive button", t.destructiveForeground, t.destructiveFill),
            ("destructive text on card", t.destructive, t.card),
        ]
        for (name, text, back) in pairs {
            #expect(text.contrast(with: back) >= 4.5, "\(appearance) \(name): \(text.contrast(with: back))")
        }
    }

    @Test(arguments: TenunTheme.Appearance.allCases)
    func controlEdgesMeet3To1(appearance: TenunTheme.Appearance) {
        let t = Self.theme.resolved(appearance)
        #expect(t.input.contrast(with: t.background) >= 3, "\(appearance) input edge: \(t.input.contrast(with: t.background))")
        #expect(t.ring.contrast(with: t.background) >= 3, "\(appearance) focus ring: \(t.ring.contrast(with: t.background))")
    }

    @Test func theRadiusScaleFollowsShadcn() {
        let r = Self.theme.radius
        #expect(r.base == 10)
        #expect(r.sm == 6 && r.md == 8 && r.lg == 10 && r.xl == 14)
    }
}
