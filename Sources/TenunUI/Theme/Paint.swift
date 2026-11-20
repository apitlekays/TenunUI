import Foundation

/// What a component paints: a fill behind it (none for ghost and link), its label, and an edge.
public struct TenunPaint: Equatable, Sendable {
    public var fill: RGB?
    public var label: RGB
    public var edge: RGB?

    public init(fill: RGB?, label: RGB, edge: RGB?) {
        self.fill = fill
        self.label = label
        self.edge = edge
    }
}

/// Pointer-driven (Mac) or touch (iPad, iPhone): sizes differ, tokens do not.
public enum TenunPlatform: Sendable {
    case mac, touch

    public static var current: TenunPlatform {
        #if os(macOS)
        .mac
        #else
        .touch
        #endif
    }
}

/// shadcn's button variants (`default` is `primary` here: `default` is a Swift keyword), plus
/// `destructiveOutline`, TenunUI's own: the outline button in the destructive colour, for a
/// theme whose primary is too close to a filled red to tell apart.
public enum TenunButtonVariant: String, CaseIterable, Sendable {
    case primary, destructive, destructiveOutline, outline, secondary, ghost, link

    public func paint(_ p: TenunTheme.Palette, _ appearance: TenunTheme.Appearance = .light) -> TenunPaint {
        switch self {
        case .primary: TenunPaint(fill: p.primary, label: p.primaryForeground, edge: nil)
        case .destructive: TenunPaint(fill: p.destructiveFill, label: p.destructiveForeground, edge: nil)
        case .secondary: TenunPaint(fill: p.secondary, label: p.secondaryForeground, edge: nil)
        case .ghost: TenunPaint(fill: nil, label: p.foreground, edge: nil)
        case .link: TenunPaint(fill: nil, label: p.primaryText, edge: nil)
        case .destructiveOutline:
            TenunPaint(fill: TenunButtonVariant.outline.paint(p, appearance).fill, label: p.destructive, edge: p.destructive)
        case .outline:
            // shadcn: `border bg-background`, and in the dark `dark:border-input dark:bg-input/30`.
            // `card` here, not `background`: the same white on shadcn's neutral, and still the
            // card's colour on a theme with a grey page behind white cards.
            appearance == .dark
                ? TenunPaint(fill: p.input.withAlpha(p.input.alpha * 0.3), label: p.foreground, edge: p.input)
                : TenunPaint(fill: p.card, label: p.foreground, edge: p.border)
        }
    }
}

/// shadcn's sizes: h-6/h-8/h-9/h-10 and px-2/px-3/px-4/px-6 on the Mac. On touch screens the
/// visible button grows where shadcn's would be too small to hit, and the hit area is 44 pt.
public enum TenunButtonSize: String, CaseIterable, Sendable {
    case xs, sm, regular, lg, icon

    public func height(_ platform: TenunPlatform) -> Double {
        switch (self, platform) {
        case (.xs, .mac): 24
        case (.sm, .mac): 32
        case (.regular, .mac), (.icon, .mac): 36
        case (.lg, .mac): 40
        case (.xs, .touch): 32
        case (.sm, .touch): 36
        case (.regular, .touch), (.icon, .touch): 44
        case (.lg, .touch): 48
        }
    }

    /// The tappable height: at least 44 pt on touch, the visible height on the Mac.
    public func hitHeight(_ platform: TenunPlatform) -> Double {
        platform == .touch ? max(44, height(platform)) : height(platform)
    }

    public var horizontalPadding: Double {
        switch self {
        case .xs: 8
        case .sm: 12
        case .regular: 16
        case .lg: 24
        case .icon: 0
        }
    }
}

/// The chosen tab's fill. shadcn: `data-[state=active]:bg-background`, and in the dark
/// `bg-input/30`. `card` stands in for `background` for the same reason as the outline button.
public enum TenunTabsPaint {
    public static func chosenFill(_ p: TenunTheme.Palette, _ appearance: TenunTheme.Appearance) -> RGB {
        appearance == .dark ? p.input.withAlpha(p.input.alpha * 0.3) : p.card
    }
}

/// shadcn's badge variants; each paints like the button of the same name, except the outline
/// badge, which has no fill (`border-border text-foreground`).
public enum TenunBadgeVariant: String, CaseIterable, Sendable {
    case primary, secondary, destructive, outline

    public func paint(_ p: TenunTheme.Palette, _ appearance: TenunTheme.Appearance = .light) -> TenunPaint {
        switch self {
        case .outline: TenunPaint(fill: nil, label: p.foreground, edge: p.border)
        default: TenunButtonVariant(rawValue: rawValue)!.paint(p, appearance)
        }
    }
}

extension TenunTheme {
    public struct ContrastPair: Sendable {
        public let name: String
        public let text: RGB
        public let back: RGB
        /// 4.5 for text, 3 for an edge that shows where a control is.
        public let minimum: Double
    }

    public struct ContrastIssue: Equatable, Sendable, CustomStringConvertible {
        public let appearance: Appearance
        public let pair: String
        public let ratio: Double
        public let minimum: Double
        public var description: String { "\(appearance) \(pair): \(String(format: "%.2f", ratio)):1, needs \(minimum):1" }
    }

    /// Every text and control-edge pair the components draw in one appearance. A paint with
    /// no fill is measured on the background (and, for text, on a card too).
    public func contrastPairs(_ appearance: Appearance) -> [ContrastPair] {
        let p = resolved(appearance)
        func text(_ name: String, _ text: RGB, _ back: RGB) -> ContrastPair { ContrastPair(name: name, text: text, back: back, minimum: 4.5) }
        var pairs = [
            text("foreground on background", p.foreground, p.background),
            text("card text", p.cardForeground, p.card),
            text("muted text on background", p.mutedForeground, p.background),
            text("muted text on card", p.mutedForeground, p.card),
            text("muted text on muted", p.mutedForeground, p.muted),
            text("accent", p.accentForeground, p.accent),
            text("destructive text on card", p.destructive, p.card),
            // shadcn: the inactive trigger is `text-foreground/60` on `bg-muted`.
            text("inactive tab", p.foreground.withAlpha(0.6), p.muted),
            ContrastPair(name: "field edge", text: p.input, back: p.background, minimum: 3),
            ContrastPair(name: "focus ring", text: p.ring, back: p.background, minimum: 3),
        ]
        for variant in TenunButtonVariant.allCases {
            let paint = variant.paint(p, appearance)
            pairs.append(text("\(variant.rawValue) button", paint.label, (paint.fill ?? p.background).over(p.background)))
        }
        for variant in TenunBadgeVariant.allCases {
            let paint = variant.paint(p, appearance)
            pairs.append(text("\(variant.rawValue) badge", paint.label, (paint.fill ?? p.card).over(p.card)))
        }
        return pairs
    }

    /// Pairs below their minimum, in both appearances. Empty means the theme is readable.
    public func contrastAudit() -> [ContrastIssue] {
        Appearance.allCases.flatMap { appearance in
            contrastPairs(appearance).compactMap { pair in
                let ratio = pair.text.contrast(with: pair.back)
                return ratio >= pair.minimum ? nil : ContrastIssue(appearance: appearance, pair: pair.name, ratio: ratio, minimum: pair.minimum)
            }
        }
    }
}
