import Foundation

/// A colour in OKLCH, the space shadcn/ui writes its theme in: lightness 0-1, chroma, hue in
/// degrees, and alpha.
public struct OKLCH: Hashable, Sendable {
    public var lightness: Double
    public var chroma: Double
    public var hue: Double
    public var alpha: Double

    public init(_ lightness: Double, _ chroma: Double, _ hue: Double, alpha: Double = 1) {
        self.lightness = lightness
        self.chroma = chroma
        self.hue = hue
        self.alpha = alpha
    }

    /// Through OKLab to linear sRGB (Björn Ottosson's matrices), then the sRGB transfer curve,
    /// clipped to the sRGB gamut.
    public var rgb: RGB {
        let h = hue * .pi / 180
        let a = chroma * cos(h), b = chroma * sin(h)
        let l = pow(lightness + 0.3963377774 * a + 0.2158037573 * b, 3)
        let m = pow(lightness - 0.1055613458 * a - 0.0638541728 * b, 3)
        let s = pow(lightness - 0.0894841775 * a - 1.2914855480 * b, 3)
        let red = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
        let green = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
        let blue = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
        return RGB(red: RGB.encode(red), green: RGB.encode(green), blue: RGB.encode(blue), alpha: alpha)
    }
}

/// An sRGB colour, channels 0-1, with alpha.
public struct RGB: Hashable, Sendable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    public static let white = RGB(red: 1, green: 1, blue: 1)
    public static let black = RGB(red: 0, green: 0, blue: 0)

    public func withAlpha(_ alpha: Double) -> RGB { RGB(red: red, green: green, blue: blue, alpha: alpha) }

    /// This colour laid over an opaque one, as the screen shows it.
    public func over(_ back: RGB) -> RGB {
        func mix(_ front: Double, _ behind: Double) -> Double { front * alpha + behind * (1 - alpha) }
        return RGB(red: mix(red, back.red), green: mix(green, back.green), blue: mix(blue, back.blue))
    }

    /// `#rrggbb`, lowercase, alpha ignored.
    public var hex: String {
        func byte(_ channel: Double) -> Int { Int((min(max(channel, 0), 1) * 255).rounded()) }
        return String(format: "#%02x%02x%02x", byte(red), byte(green), byte(blue))
    }

    /// WCAG 2 relative luminance.
    public var luminance: Double {
        0.2126 * Self.decode(red) + 0.7152 * Self.decode(green) + 0.0722 * Self.decode(blue)
    }

    /// WCAG 2 contrast ratio against an opaque colour; a translucent colour is first laid over it.
    public func contrast(with back: RGB) -> Double {
        let front = alpha < 1 ? over(back) : self
        let (a, b) = (front.luminance, back.luminance)
        return (max(a, b) + 0.05) / (min(a, b) + 0.05)
    }

    static func encode(_ linear: Double) -> Double {
        let x = min(max(linear, 0), 1)
        return x <= 0.0031308 ? 12.92 * x : 1.055 * pow(x, 1 / 2.4) - 0.055
    }

    static func decode(_ channel: Double) -> Double {
        channel <= 0.04045 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4)
    }
}
