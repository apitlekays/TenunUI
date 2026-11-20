import SwiftUI

/// shadcn's Badge: `rounded-full px-2 py-0.5 text-xs font-medium`. For a real state or a
/// count, not decoration. Text works as in `Text`: a literal is localised, a `String` is not.
public struct TenunBadge: View {
    private let title: Text
    private let variant: TenunBadgeVariant
    @Environment(\.tenunTheme) private var theme
    @Environment(\.colorScheme) private var scheme

    public init(_ title: LocalizedStringKey, variant: TenunBadgeVariant = .primary) {
        self.init(title: Text(title), variant: variant)
    }

    @_disfavoredOverload
    public init(_ title: some StringProtocol, variant: TenunBadgeVariant = .primary) {
        self.init(title: Text(title), variant: variant)
    }

    public init(title: Text, variant: TenunBadgeVariant = .primary) {
        self.title = title
        self.variant = variant
    }

    public var body: some View {
        let appearance = scheme.tenunAppearance
        let paint = variant.paint(theme.appearance(appearance), appearance)
        title
            .font(TenunText.small(theme.density).weight(.medium))
            .lineLimit(1)
            .foregroundStyle(Color(paint.label))
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background {
                if let fill = paint.fill { Capsule().fill(Color(fill)) }
            }
            .overlay {
                if let edge = paint.edge { Capsule().strokeBorder(Color(edge), lineWidth: 1) }
            }
    }
}
