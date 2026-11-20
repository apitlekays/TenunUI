#if os(macOS)
import AppKit
import SwiftUI
import Testing
@testable import TenunUI

/// Renders the catalogue to PNG in light and dark for a look by eye. Runs only when
/// TENUN_SNAPSHOT_DIR is set: `TENUN_SNAPSHOT_DIR=/tmp/shots swift test --filter Catalogue`.
@MainActor
@Suite(.enabled(if: ProcessInfo.processInfo.environment["TENUN_SNAPSHOT_DIR"] != nil))
struct CatalogueSnapshot {
    @Test(arguments: [("light", NSAppearance.Name.aqua), ("dark", NSAppearance.Name.darkAqua)])
    func render(name: String, appearance: NSAppearance.Name) throws {
        let dir = try #require(ProcessInfo.processInfo.environment["TENUN_SNAPSHOT_DIR"])
        let host = NSHostingView(rootView: TenunCatalogue().frame(width: 900))
        host.appearance = NSAppearance(named: appearance)
        host.frame = NSRect(origin: .zero, size: host.fittingSize)
        host.layoutSubtreeIfNeeded()
        let rep = try #require(host.bitmapImageRepForCachingDisplay(in: host.bounds))
        host.cacheDisplay(in: host.bounds, to: rep)
        let png = try #require(rep.representation(using: .png, properties: [:]))
        try png.write(to: URL(fileURLWithPath: dir).appendingPathComponent("catalogue-\(name).png"))
    }
}
#endif
