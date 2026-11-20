import Foundation

/// The design tokens every TenunUI component draws with: shadcn/ui's semantic roles, one value
/// per appearance, and a radius scale derived from one base radius as shadcn derives it.
public struct TenunTheme: Equatable, Sendable {
    public enum Appearance: CaseIterable, Sendable { case light, dark }

    public struct Palette: Equatable, Sendable {
        public var background: RGB
        public var foreground: RGB
        public var card: RGB
        public var cardForeground: RGB
        public var primary: RGB
        public var primaryForeground: RGB
        public var secondary: RGB
        public var secondaryForeground: RGB
        public var muted: RGB
        public var mutedForeground: RGB
        public var accent: RGB
        public var accentForeground: RGB
        /// Destructive text and icons.
        public var destructive: RGB
        /// Behind a destructive button's label. May be translucent; it is laid over `background`.
        public var destructiveFill: RGB
        public var destructiveForeground: RGB
        /// Card edges and separators: decoration, so no contrast minimum.
        public var border: RGB
        /// The edge that shows where a field is: 3:1 against the background.
        public var input: RGB
        /// The focus outline: 3:1 against the background.
        public var ring: RGB

        public init(
            background: RGB, foreground: RGB, card: RGB, cardForeground: RGB,
            primary: RGB, primaryForeground: RGB, secondary: RGB, secondaryForeground: RGB,
            muted: RGB, mutedForeground: RGB, accent: RGB, accentForeground: RGB,
            destructive: RGB, destructiveFill: RGB, destructiveForeground: RGB,
            border: RGB, input: RGB, ring: RGB
        ) {
            self.background = background
            self.foreground = foreground
            self.card = card
            self.cardForeground = cardForeground
            self.primary = primary
            self.primaryForeground = primaryForeground
            self.secondary = secondary
            self.secondaryForeground = secondaryForeground
            self.muted = muted
            self.mutedForeground = mutedForeground
            self.accent = accent
            self.accentForeground = accentForeground
            self.destructive = destructive
            self.destructiveFill = destructiveFill
            self.destructiveForeground = destructiveForeground
            self.border = border
            self.input = input
            self.ring = ring
        }
    }

    /// shadcn's scale: sm 0.6, md 0.8, lg 1, xl 1.4 times the base (`--radius`).
    public struct Radius: Equatable, Sendable {
        public var base: Double
        public init(base: Double) { self.base = base }
        public var sm: Double { base * 0.6 }
        public var md: Double { base * 0.8 }
        public var lg: Double { base }
        public var xl: Double { base * 1.4 }
    }

    /// shadcn's spacing (`comfortable`), or a tighter one for screens that show a lot at once.
    public enum Density: Sendable {
        case comfortable, compact

        /// Inside a card (shadcn: px-6 py-6).
        public var cardPadding: Double { self == .comfortable ? 24 : 14 }
        /// Between a card's parts (shadcn: gap-6).
        public var cardSpacing: Double { self == .comfortable ? 24 : 12 }
    }

    public var light: Palette
    public var dark: Palette
    public var radius: Radius
    public var density: Density
    /// shadcn lifts cards with `shadow-sm`. An app that keeps its surfaces flat turns it off.
    public var cardShadow: Bool

    public init(light: Palette, dark: Palette, radius: Radius = Radius(base: 10), density: Density = .comfortable, cardShadow: Bool = true) {
        self.light = light
        self.dark = dark
        self.radius = radius
        self.density = density
        self.cardShadow = cardShadow
    }

    /// The palette for one appearance, with translucent fills laid over the background, as
    /// the screen shows them. Edges (`border`, `input`) stay translucent so they suit any surface.
    public func resolved(_ appearance: Appearance) -> Palette {
        var palette = appearance == .light ? light : dark
        palette.destructiveFill = palette.destructiveFill.over(palette.background)
        return palette
    }
}

extension TenunTheme {
    /// shadcn/ui's default neutral theme (ui.shadcn.com/docs/theming, read 2026-11-20), with
    /// four values moved just far enough to meet WCAG, each marked "TenunUI:" below. shadcn's
    /// own values measured: muted text on muted 4.34:1, field edge 1.26:1 (light) and 1.49:1
    /// (dark), focus ring 2.60:1.
    public static let neutral = TenunTheme(
        light: Palette(
            background: OKLCH(1, 0, 0).rgb,
            foreground: OKLCH(0.145, 0, 0).rgb,
            card: OKLCH(1, 0, 0).rgb,
            cardForeground: OKLCH(0.145, 0, 0).rgb,
            primary: OKLCH(0.205, 0, 0).rgb,
            primaryForeground: OKLCH(0.985, 0, 0).rgb,
            secondary: OKLCH(0.97, 0, 0).rgb,
            secondaryForeground: OKLCH(0.205, 0, 0).rgb,
            muted: OKLCH(0.97, 0, 0).rgb,
            mutedForeground: OKLCH(0.545, 0, 0).rgb, // TenunUI: 0.556 gave 4.34:1 on muted
            accent: OKLCH(0.97, 0, 0).rgb,
            accentForeground: OKLCH(0.205, 0, 0).rgb,
            destructive: OKLCH(0.577, 0.245, 27.325).rgb,
            destructiveFill: OKLCH(0.577, 0.245, 27.325).rgb,
            destructiveForeground: .white,
            border: OKLCH(0.922, 0, 0).rgb,
            input: OKLCH(0.66, 0, 0).rgb, // TenunUI: 0.922, a field's only outline, gave 1.26:1
            ring: OKLCH(0.66, 0, 0).rgb // TenunUI: 0.708 gave 2.60:1
        ),
        dark: Palette(
            background: OKLCH(0.145, 0, 0).rgb,
            foreground: OKLCH(0.985, 0, 0).rgb,
            card: OKLCH(0.205, 0, 0).rgb,
            cardForeground: OKLCH(0.985, 0, 0).rgb,
            primary: OKLCH(0.922, 0, 0).rgb,
            primaryForeground: OKLCH(0.205, 0, 0).rgb,
            secondary: OKLCH(0.269, 0, 0).rgb,
            secondaryForeground: OKLCH(0.985, 0, 0).rgb,
            muted: OKLCH(0.269, 0, 0).rgb,
            mutedForeground: OKLCH(0.708, 0, 0).rgb,
            accent: OKLCH(0.269, 0, 0).rgb,
            accentForeground: OKLCH(0.985, 0, 0).rgb,
            destructive: OKLCH(0.704, 0.191, 22.216).rgb,
            destructiveFill: OKLCH(0.704, 0.191, 22.216, alpha: 0.6).rgb, // dark:bg-destructive/60
            destructiveForeground: .white,
            border: OKLCH(1, 0, 0, alpha: 0.1).rgb,
            input: OKLCH(1, 0, 0, alpha: 0.35).rgb, // TenunUI: 15% gave 1.49:1
            ring: OKLCH(0.556, 0, 0).rgb
        )
    )
}
