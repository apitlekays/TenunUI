import Testing
@testable import TenunUI

/// What each variant paints with, taken from shadcn/ui's component source
/// (apps/v4/registry/new-york-v4/ui, read 2026-11-20).
struct ButtonVariantTests {
    let light = TenunTheme.neutral.resolved(.light)
    let dark = TenunTheme.neutral.resolved(.dark)

    @Test func eachVariantPaintsWithShadcnsRoles() {
        let p = light
        #expect(TenunButtonVariant.primary.paint(p) == TenunPaint(fill: p.primary, label: p.primaryForeground, edge: nil))
        #expect(TenunButtonVariant.destructive.paint(p) == TenunPaint(fill: p.destructiveFill, label: p.destructiveForeground, edge: nil))
        #expect(TenunButtonVariant.secondary.paint(p) == TenunPaint(fill: p.secondary, label: p.secondaryForeground, edge: nil))
        #expect(TenunButtonVariant.outline.paint(p) == TenunPaint(fill: p.card, label: p.foreground, edge: p.border))
        #expect(TenunButtonVariant.ghost.paint(p) == TenunPaint(fill: nil, label: p.foreground, edge: nil))
        #expect(TenunButtonVariant.link.paint(p) == TenunPaint(fill: nil, label: p.primaryText, edge: nil))
    }

    /// shadcn: `dark:border-input dark:bg-input/30` on the outline button.
    @Test func theOutlineButtonUsesTheFieldEdgeInTheDark() {
        let paint = TenunButtonVariant.outline.paint(dark, .dark)
        #expect(paint.edge == dark.input)
        // An opaque dark field edge (an app's own theme) still takes the dark treatment.
        var opaque = dark
        opaque.input = RGB(red: 0.4, green: 0.4, blue: 0.4)
        #expect(TenunButtonVariant.outline.paint(opaque, .dark).edge == opaque.input)
        #expect(paint.fill == dark.input.withAlpha(dark.input.alpha * 0.3))
    }

    /// shadcn fills an outline button with `background`, which is the card's white too. A theme
    /// with a grey page behind white cards would get grey outline buttons on its cards, so the
    /// fill is `card`: the same on shadcn's neutral, right on such a theme.
    @Test func anOutlineButtonOnACardLooksLikeTheCard() {
        var p = light
        p.background = RGB(red: 0.96, green: 0.96, blue: 0.96)
        #expect(TenunButtonVariant.outline.paint(p).fill == p.card)
        #expect(TenunButtonVariant.outline.paint(light) == TenunPaint(fill: light.background, label: light.foreground, edge: light.border))
    }

    /// shadcn raises the chosen tab on `background`; on a grey page that is the track's grey.
    @Test func theChosenTabStandsOffItsTrack() {
        var p = light
        p.background = p.muted
        #expect(TenunTabsPaint.chosenFill(p, .light) == p.card)
        #expect(TenunTabsPaint.chosenFill(p, .light) != p.muted)
        #expect(TenunTabsPaint.chosenFill(dark, .dark) == dark.input.withAlpha(dark.input.alpha * 0.3))
    }

    /// A brand colour can be a good fill and still too dim as text on the page, so a link uses
    /// `primaryText`, which is `primary` unless a theme sets it.
    @Test func aLinkUsesPrimaryText() {
        #expect(light.primaryText == light.primary)
        var p = dark
        p.primaryText = RGB(red: 0.9, green: 0.54, blue: 0.58)
        #expect(TenunButtonVariant.link.paint(p, .dark).label == p.primaryText)
    }

    @Test func aBadgePaintsLikeTheButtonOfTheSameName() {
        for variant in TenunBadgeVariant.allCases {
            let button = TenunButtonVariant(rawValue: variant.rawValue)!
            if variant == .outline {
                #expect(variant.paint(light) == TenunPaint(fill: nil, label: light.foreground, edge: light.border))
            } else {
                #expect(variant.paint(light) == button.paint(light))
            }
        }
    }
}

struct ButtonSizeTests {
    /// shadcn's heights on the Mac (h-6, h-8, h-9, h-10); on iPad a finger needs 44 pt.
    @Test func macHeightsAreShadcns() {
        #expect(TenunButtonSize.xs.height(.mac) == 24)
        #expect(TenunButtonSize.sm.height(.mac) == 32)
        #expect(TenunButtonSize.regular.height(.mac) == 36)
        #expect(TenunButtonSize.lg.height(.mac) == 40)
        #expect(TenunButtonSize.icon.height(.mac) == 36)
    }

    @Test(arguments: TenunButtonSize.allCases)
    func everyTouchTargetIsAtLeast44(size: TenunButtonSize) {
        #expect(size.hitHeight(.touch) >= 44)
        #expect(size.hitHeight(.touch) >= size.height(.touch))
    }

    @Test func paddingIsShadcns() {
        #expect(TenunButtonSize.xs.horizontalPadding == 8)
        #expect(TenunButtonSize.sm.horizontalPadding == 12)
        #expect(TenunButtonSize.regular.horizontalPadding == 16)
        #expect(TenunButtonSize.lg.horizontalPadding == 24)
        #expect(TenunButtonSize.icon.horizontalPadding == 0)
    }
}

/// The audit an app runs on its own theme: every pair the components draw.
struct ContrastAuditTests {
    @Test func theNeutralThemePassesItsOwnAudit() {
        #expect(TenunTheme.neutral.contrastAudit() == [])
    }

    @Test func aThemeWithAnUnreadableButtonIsReported() {
        var theme = TenunTheme.neutral
        theme.light.primaryForeground = theme.light.primary
        let issues = theme.contrastAudit()
        #expect(issues.contains { $0.appearance == .light && $0.pair == "primary button" })
    }

    @Test func everyButtonAndBadgeVariantIsAudited() {
        let pairs = Set(TenunTheme.neutral.contrastPairs(.light).map(\.name))
        for variant in TenunButtonVariant.allCases { #expect(pairs.contains("\(variant.rawValue) button"), "\(variant)") }
        for variant in TenunBadgeVariant.allCases { #expect(pairs.contains("\(variant.rawValue) badge"), "\(variant)") }
        #expect(pairs.contains("inactive tab"))
    }
}
