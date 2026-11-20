import SwiftUI

/// shadcn's Alert: an inline notice on the page (not a dialog), `rounded-lg border px-4 py-3`,
/// a medium title, the description in muted text. The destructive variant colours the title,
/// the icon and the description.
public struct TenunAlert: View {
    public enum Variant: Sendable { case standard, destructive }

    private let title: Text
    private let message: Text?
    private let systemImage: String?
    private let variant: Variant
    @Environment(\.tenunTheme) private var theme

    public init(_ title: LocalizedStringKey, message: LocalizedStringKey? = nil, systemImage: String? = nil, variant: Variant = .standard) {
        self.init(title: Text(title), message: message.map { Text($0) }, systemImage: systemImage, variant: variant)
    }

    @_disfavoredOverload
    public init(_ title: some StringProtocol, message: (some StringProtocol)? = String?.none, systemImage: String? = nil, variant: Variant = .standard) {
        self.init(title: Text(title), message: message.map { Text($0) }, systemImage: systemImage, variant: variant)
    }

    public init(title: Text, message: Text? = nil, systemImage: String? = nil, variant: Variant = .standard) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.variant = variant
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
        let tone = variant == .destructive ? theme.color(\.destructive) : theme.color(\.cardForeground)
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            if let systemImage {
                Image(systemName: systemImage).foregroundStyle(tone).accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 2) {
                title.font(TenunText.control(theme.density).weight(.medium)).foregroundStyle(tone)
                if let message {
                    message
                        .font(TenunText.control(theme.density))
                        .foregroundStyle(variant == .destructive ? theme.color(\.destructive).opacity(0.9) : theme.color(\.mutedForeground))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(theme.color(\.card), in: shape)
        .overlay(shape.strokeBorder(theme.color(\.border), lineWidth: 1))
        .accessibilityElement(children: .combine)
    }
}

/// shadcn's Skeleton (`rounded-md bg-accent`), without its endless pulse: a loop that never
/// stops draws the eye from the content and keeps UI tests from ever seeing the screen idle.
/// Pair it with text that says what is loading.
public struct TenunSkeleton: View {
    @Environment(\.tenunTheme) private var theme
    public init() {}

    public var body: some View {
        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
            .fill(theme.color(\.accent))
            .accessibilityHidden(true)
    }
}

/// shadcn's Progress on SwiftUI's own `ProgressView`: `h-2 rounded-full bg-primary/20` with the
/// filled part in `primary`. An indeterminate view keeps the platform spinner.
public struct TenunProgressStyle: ProgressViewStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        TenunProgressBody(configuration: configuration)
    }
}

extension ProgressViewStyle where Self == TenunProgressStyle {
    public static var tenun: TenunProgressStyle { TenunProgressStyle() }
}

private struct TenunProgressBody: View {
    let configuration: ProgressViewStyleConfiguration
    @Environment(\.tenunTheme) private var theme

    var body: some View {
        if let fraction = configuration.fractionCompleted {
            VStack(alignment: .leading, spacing: 6) {
                configuration.label
                Capsule()
                    .fill(theme.color(\.primary).opacity(0.2))
                    .frame(height: 8)
                    .overlay(alignment: .leading) {
                        GeometryReader { proxy in
                            Capsule()
                                .fill(theme.color(\.primary))
                                .frame(width: proxy.size.width * min(max(fraction, 0), 1))
                        }
                    }
                    .accessibilityHidden(true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityValue(Text(fraction, format: .percent.precision(.fractionLength(0))))
        } else {
            ProgressView(configuration)
        }
    }
}

/// shadcn's Tabs list: a `muted` track, `rounded-lg p-[3px]`, the chosen tab raised on
/// `background` and the rest in `foreground` at 60%. Each tab is a real button marked as
/// selected, so VoiceOver and UI tests read it as a choice.
public struct TenunTabs<Value: Hashable>: View {
    @Binding private var selection: Value
    private let options: [(value: Value, title: Text)]
    @Environment(\.tenunTheme) private var theme
    @Environment(\.colorScheme) private var scheme

    /// Titles are localised, as string literals in `Text` are.
    public init(selection: Binding<Value>, options: [(value: Value, title: LocalizedStringKey)]) {
        self.init(selection: selection, texts: options.map { ($0.value, Text($0.title)) })
    }

    public init(selection: Binding<Value>, texts options: [(value: Value, title: Text)]) {
        self._selection = selection
        self.options = options
    }

    public var body: some View {
        let palette = theme.appearance(scheme.tenunAppearance)
        let track = RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
        let tab = RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
        HStack(spacing: 0) {
            ForEach(options, id: \.value) { option in
                let chosen = option.value == selection
                Button { selection = option.value } label: {
                    option.title
                        .font(TenunText.control(theme.density).weight(.medium))
                        .lineLimit(1)
                        .foregroundStyle(Color(chosen ? palette.foreground : palette.foreground.withAlpha(0.6)))
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, minHeight: TenunButtonSize.regular.height(.current) - 6)
                        .background {
                            if chosen {
                                tab.fill(Color(scheme == .dark ? palette.input.withAlpha(palette.input.alpha * 0.3) : palette.background))
                                    .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
                            }
                        }
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(chosen ? .isSelected : [])
            }
        }
        .padding(3)
        .background(Color(palette.muted), in: track)
    }
}
