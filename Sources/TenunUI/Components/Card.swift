import SwiftUI

/// shadcn's Card: `rounded-xl border bg-card text-card-foreground`, padded by the theme's
/// density, with `shadow-sm` unless the theme keeps surfaces flat.
public struct TenunCard<Content: View>: View {
    private let content: Content
    @Environment(\.tenunTheme) private var theme

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.density.cardSpacing) { content }
            .tenunCardSurface()
    }
}

/// shadcn's CardHeader: a title, an optional description under it, and an optional action on
/// the trailing edge. Like `Text`, a string literal is looked up in the app's string catalogue
/// and a `String` value is shown as it is.
public struct TenunCardHeader<Action: View>: View {
    private let title: Text
    private let description: Text?
    private let action: Action
    @Environment(\.tenunTheme) private var theme

    public init(_ title: LocalizedStringKey, description: LocalizedStringKey? = nil, @ViewBuilder action: () -> Action) {
        self.init(title: Text(title), description: description.map { Text($0) }, action: action)
    }

    @_disfavoredOverload
    public init(_ title: some StringProtocol, description: (some StringProtocol)? = String?.none, @ViewBuilder action: () -> Action) {
        self.init(title: Text(title), description: description.map { Text($0) }, action: action)
    }

    public init(title: Text, description: Text? = nil, @ViewBuilder action: () -> Action) {
        self.title = title
        self.description = description
        self.action = action()
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                title
                    .font(TenunText.title(theme.density))
                    .accessibilityAddTraits(.isHeader)
                if let description {
                    description
                        .font(TenunText.control(theme.density))
                        .foregroundStyle(theme.color(\.mutedForeground))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            action
        }
    }
}

extension TenunCardHeader where Action == EmptyView {
    public init(_ title: LocalizedStringKey, description: LocalizedStringKey? = nil) {
        self.init(title, description: description) { EmptyView() }
    }

    @_disfavoredOverload
    public init(_ title: some StringProtocol, description: (some StringProtocol)? = String?.none) {
        self.init(title, description: description) { EmptyView() }
    }
}

private struct CardSurface: ViewModifier {
    @Environment(\.tenunTheme) private var theme

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
        content
            .foregroundStyle(theme.color(\.cardForeground))
            .padding(theme.density.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.color(\.card), in: shape)
            .overlay(shape.strokeBorder(theme.color(\.border), lineWidth: 1))
            // shadcn's shadow-sm: a one-pixel lift, the only elevation cue on the card.
            .shadow(color: .black.opacity(theme.cardShadow ? 0.05 : 0), radius: 1, y: 1)
    }
}

extension View {
    /// Puts any view on a card surface, for layouts that are not header plus content.
    public func tenunCardSurface() -> some View { modifier(CardSurface()) }
}
