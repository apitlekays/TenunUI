import SwiftUI

/// Every component in every variant, for previews and for checking a theme by eye.
public struct TenunCatalogue: View {
    @State private var tab = 0
    @State private var on = true
    @State private var text = ""
    @Environment(\.tenunTheme) private var theme

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TenunCard {
                TenunCardHeader("Buttons", description: "Variants at the regular size, then the sizes.")
                HStack(spacing: 8) {
                    ForEach(TenunButtonVariant.allCases, id: \.self) { variant in
                        Button(variant.rawValue.capitalized) {}.buttonStyle(.tenun(variant))
                    }
                }
                HStack(spacing: 8) {
                    ForEach(TenunButtonSize.allCases.filter { $0 != .icon }, id: \.self) { size in
                        Button(size.rawValue) {}.buttonStyle(.tenun(.outline, size: size))
                    }
                    Button {} label: { Image(systemName: "plus") }
                        .buttonStyle(.tenun(.outline, size: .icon))
                        .accessibilityLabel("Add")
                    Button("Disabled") {}.buttonStyle(.tenun()).disabled(true)
                }
            }
            HStack(alignment: .top, spacing: 20) {
                TenunCard {
                    TenunCardHeader("Badges and tabs")
                    HStack(spacing: 6) {
                        ForEach(TenunBadgeVariant.allCases, id: \.self) { variant in
                            TenunBadge(variant.rawValue.capitalized, variant: variant)
                        }
                    }
                    TenunTabs(selection: $tab, options: [(0, "Account"), (1, "Password"), (2, "Team")])
                    TenunSeparator()
                    ProgressView("Progress", value: 0.6).progressViewStyle(.tenun)
                    TenunSkeleton().frame(height: 12)
                }
                TenunCard {
                    TenunCardHeader("Fields", description: "A labelled field and a switch.") {
                        Button("Save") {}.buttonStyle(.tenun(.secondary, size: .sm))
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        TenunFieldLabel("Email")
                        TextField(text: $text, prompt: Text(verbatim: "email@example.com")) { Text("Email") }.tenunField()
                    }
                    Toggle("Notifications", isOn: $on).tenunSwitch()
                }
            }
            TenunAlert("Heads up", message: "An inline notice, not a dialog.", systemImage: "info.circle")
            TenunAlert("Could not save", message: "Check the connection and try again.", systemImage: "exclamationmark.triangle", variant: .destructive)
        }
        .padding(24)
        .background(theme.color(\.background))
    }
}

#Preview("Neutral") {
    TenunCatalogue()
}
