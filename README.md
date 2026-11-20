# TenunUI

SwiftUI components in the style of [shadcn/ui](https://ui.shadcn.com), for macOS 14+ and iOS 17+.
*Tenun* is Malay for weaving.

TenunUI styles SwiftUI's own controls wherever it can (`Button`, `Toggle`, `ProgressView`,
`TextField`), so keyboard focus, VoiceOver and UI tests behave as they do for any SwiftUI view.
Views it draws itself carry a `Tenun` prefix and never shadow SwiftUI names.

```swift
import TenunUI

TenunCard {
    TenunCardHeader("Account", description: "Signed in on this device.") {
        Button("Edit") {}.buttonStyle(.tenun(.secondary, size: .sm))
    }
    TenunFieldLabel("Email")
    TextField(text: $email, prompt: Text(verbatim: "email@example.com")) { Text("Email") }
        .tenunField()
    Toggle("Notifications", isOn: $on).tenunSwitch()
}
.tenunTheme(.neutral)
```

## Components

| shadcn | TenunUI |
|---|---|
| Button (default, destructive, outline, secondary, ghost, link; xs, sm, default, lg, icon) | `.buttonStyle(.tenun(_:size:))` (`default` is `.primary`) |
| Card, CardHeader | `TenunCard`, `TenunCardHeader`, `.tenunCardSurface()` |
| Badge | `TenunBadge` |
| Input, Label | `.tenunField()`, `TenunFieldLabel` |
| Separator | `TenunSeparator` |
| Switch | `.tenunSwitch()` (the platform switch in `primary`) |
| Tabs (list) | `TenunTabs` |
| Alert | `TenunAlert` (inline, not a dialog) |
| Skeleton | `TenunSkeleton` |
| Progress | `.progressViewStyle(.tenun)` |

`TenunCatalogue()` shows them all; render it with
`TENUN_SNAPSHOT_DIR=/some/folder swift test --filter Catalogue` (macOS).

## Themes

A `TenunTheme` holds shadcn's semantic roles (background, foreground, card, primary, secondary,
muted, accent, destructive, border, input, ring) for light and dark, the radius scale
(sm 0.6, md 0.8, lg 1, xl 1.4 times the base, as shadcn derives it), a density, and whether
cards cast shadcn's `shadow-sm`. `TenunTheme.neutral` is shadcn's default neutral theme.

Build your own by changing the palettes, then check it:

```swift
#expect(myTheme.contrastAudit() == [])
```

`contrastAudit()` measures every text pair the components draw against 4.5:1 and every control
edge against 3:1 (WCAG 2 1.4.3 and 1.4.11), in both appearances.

## Where TenunUI differs from shadcn/ui, and why

- **Four neutral values**, moved just far enough to pass the audit. shadcn's own values measure:
  muted text on a muted surface 4.34:1 (`muted-foreground` 0.556 to 0.545), a field's edge
  1.26:1 light and 1.49:1 dark (`input` 0.922 to 0.66, and white at 15% to 35%), the focus
  ring 2.60:1 (`ring` 0.708 to 0.66).
- **Touch sizes.** On the Mac buttons are shadcn's heights (24, 32, 36, 40). On iPad and iPhone
  the regular button is 44 pt and every hit area at least 44 pt.
- **Dynamic Type.** Text uses the nearest system text style instead of a fixed pixel size, so it
  grows with the reader's setting.
- **No endless pulse on Skeleton.** A loop that never stops pulls the eye from the content and
  keeps UI tests from ever seeing the screen settle.
- **Switch** is the platform switch, tinted, so it stays a switch to assistive technology.

## Credit and licence

Design tokens, variants and sizes follow shadcn/ui
([github.com/shadcn-ui/ui](https://github.com/shadcn-ui/ui), MIT, Copyright (c) 2023 shadcn),
read from its theming docs and component source on 2026-11-20. TenunUI is not affiliated with
shadcn/ui. TenunUI itself is MIT licensed; see `LICENSE`.
