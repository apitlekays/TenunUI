import SwiftUI

/// shadcn's Input on SwiftUI's own `TextField` or `SecureField`: `rounded-md border border-input
/// px-3`, and on focus the edge turns to `ring` with a 3 pt halo at half strength.
private struct FieldSurface: ViewModifier {
    @Environment(\.tenunTheme) private var theme
    @Environment(\.colorScheme) private var scheme
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var focused: Bool

    func body(content: Content) -> some View {
        let appearance = scheme.tenunAppearance
        let palette = theme.appearance(appearance)
        let shape = RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
        content
            .textFieldStyle(.plain)
            .font(TenunText.control(theme.density))
            .focused($focused)
            .padding(.horizontal, 12)
            .frame(minHeight: TenunButtonSize.regular.height(.current))
            // shadcn: bg-transparent, and dark:bg-input/30.
            .background(appearance == .dark ? Color(palette.input.withAlpha(palette.input.alpha * 0.3)) : .clear, in: shape)
            .overlay(shape.strokeBorder(Color(focused ? palette.ring : palette.input), lineWidth: 1))
            .overlay {
                if focused { shape.inset(by: -3).strokeBorder(Color(palette.ring).opacity(0.5), lineWidth: 3) }
            }
            .opacity(isEnabled ? 1 : 0.5)
    }
}

extension View {
    /// Styles a `TextField` or `SecureField` as a shadcn Input. Leave fields inside a `Form`
    /// to the platform: a Form draws its own rows.
    public func tenunField() -> some View { modifier(FieldSurface()) }
}

/// shadcn's Label: `text-sm font-medium leading-none`, above the field it names.
public struct TenunFieldLabel: View {
    private let text: Text
    @Environment(\.tenunTheme) private var theme

    public init(_ text: LocalizedStringKey) { self.text = Text(text) }
    @_disfavoredOverload public init(_ text: some StringProtocol) { self.text = Text(text) }

    public var body: some View {
        text.font(TenunText.control(theme.density).weight(.medium))
    }
}

/// shadcn's Separator: one point of `border`, across or down.
public struct TenunSeparator: View {
    public enum Axis: Sendable { case horizontal, vertical }
    private let axis: Axis
    @Environment(\.tenunTheme) private var theme

    public init(_ axis: Axis = .horizontal) { self.axis = axis }

    public var body: some View {
        Rectangle()
            .fill(theme.color(\.border))
            .frame(width: axis == .vertical ? 1 : nil, height: axis == .horizontal ? 1 : nil)
            .accessibilityHidden(true)
    }
}

extension View {
    /// shadcn's Switch keeps the platform switch (so it stays a switch to VoiceOver and to UI
    /// tests), in the theme's `primary`: `Toggle("FYP", isOn: $on).tenunSwitch()`.
    public func tenunSwitch() -> some View {
        modifier(SwitchTint())
    }
}

private struct SwitchTint: ViewModifier {
    @Environment(\.tenunTheme) private var theme
    func body(content: Content) -> some View {
        content.toggleStyle(.switch).tint(theme.color(\.primary))
    }
}
