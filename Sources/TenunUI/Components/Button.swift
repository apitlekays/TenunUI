import SwiftUI

/// shadcn's Button as a style on SwiftUI's own `Button`, so focus, keyboard and VoiceOver
/// behave as for any button: `Button("Simpan") {}.buttonStyle(.tenun(.outline, size: .sm))`.
public struct TenunButtonStyle: ButtonStyle {
    public var variant: TenunButtonVariant
    public var size: TenunButtonSize

    public init(_ variant: TenunButtonVariant = .primary, size: TenunButtonSize = .regular) {
        self.variant = variant
        self.size = size
    }

    public func makeBody(configuration: Configuration) -> some View {
        TenunButtonBody(configuration: configuration, variant: variant, size: size)
    }
}

extension ButtonStyle where Self == TenunButtonStyle {
    public static func tenun(_ variant: TenunButtonVariant = .primary, size: TenunButtonSize = .regular) -> TenunButtonStyle {
        TenunButtonStyle(variant, size: size)
    }
}

private struct TenunButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let variant: TenunButtonVariant
    let size: TenunButtonSize
    @Environment(\.tenunTheme) private var theme
    @Environment(\.colorScheme) private var scheme
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let appearance = scheme.tenunAppearance
        let palette = theme.resolved(appearance)
        let paint = variant.paint(theme.appearance(appearance), appearance)
        let platform = TenunPlatform.current
        let height = size.height(platform)
        let shape = RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)

        configuration.label
            .font(size == .xs ? TenunText.small(theme.density).weight(.medium) : TenunText.control(theme.density).weight(.medium))
            .lineLimit(1)
            .foregroundStyle(Color(paint.label))
            .underline(variant == .link && configuration.isPressed)
            .padding(.horizontal, size.horizontalPadding)
            .frame(minWidth: size == .icon ? height : nil, minHeight: height)
            .background {
                if let fill = paint.fill {
                    // shadcn: hover:bg-primary/90 and the like; a press is the touch equivalent.
                    shape.fill(Color(fill).opacity(configuration.isPressed ? 0.9 : 1))
                } else if variant == .ghost, configuration.isPressed {
                    shape.fill(Color(palette.accent))
                }
            }
            .overlay {
                if let edge = paint.edge { shape.strokeBorder(Color(edge), lineWidth: 1) }
            }
            .frame(minHeight: size.hitHeight(platform))
            .contentShape(.rect)
            .opacity(isEnabled ? 1 : 0.5) // shadcn: disabled:opacity-50
    }
}

extension TenunTheme {
    /// The raw palette for drawing: translucent fills stay translucent over whatever is behind.
    func appearance(_ appearance: Appearance) -> Palette { appearance == .light ? light : dark }
}
