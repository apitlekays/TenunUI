import SwiftUI

extension Color {
    public init(_ rgb: RGB) {
        self.init(.sRGB, red: rgb.red, green: rgb.green, blue: rgb.blue, opacity: rgb.alpha)
    }

    /// A colour that follows the system appearance wherever it is used.
    public init(light: RGB, dark: RGB) {
        #if os(macOS)
        self.init(nsColor: NSColor(name: nil) { appearance in
            let rgb = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
            return NSColor(srgbRed: rgb.red, green: rgb.green, blue: rgb.blue, alpha: rgb.alpha)
        })
        #else
        self.init(uiColor: UIColor { traits in
            let rgb = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: rgb.alpha)
        })
        #endif
    }
}

extension TenunTheme {
    /// One token as a SwiftUI colour that follows the appearance, e.g. `theme.color(\.mutedForeground)`.
    public func color(_ token: KeyPath<Palette, RGB>) -> Color {
        Color(light: resolved(.light)[keyPath: token], dark: resolved(.dark)[keyPath: token])
    }
}

extension EnvironmentValues {
    @Entry public var tenunTheme: TenunTheme = .neutral
}

extension View {
    /// Sets the theme for every TenunUI component inside.
    public func tenunTheme(_ theme: TenunTheme) -> some View {
        environment(\.tenunTheme, theme)
    }
}

extension ColorScheme {
    var tenunAppearance: TenunTheme.Appearance { self == .dark ? .dark : .light }
}

/// Text styles for controls: shadcn's `text-sm` (14 px) and `text-xs` (12 px). The nearest
/// Dynamic Type styles are used, so text still grows with the reader's setting.
enum TenunText {
    static func control(_ density: TenunTheme.Density) -> Font {
        #if os(macOS)
        .body
        #else
        .subheadline
        #endif
    }

    static func small(_ density: TenunTheme.Density) -> Font {
        .caption
    }

    static func title(_ density: TenunTheme.Density) -> Font {
        #if os(macOS)
        .headline
        #else
        density == .compact ? .subheadline.weight(.semibold) : .headline
        #endif
    }
}
