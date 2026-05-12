import SwiftUI

// MARK: - Design Tokens
enum DramaColor {
    // White / Transparent
    static let fillWhite = Color.white
    static let fillWhite1 = Color.white.opacity(0.2)
    static let textWhite = Color.white.opacity(0.68)
    // Blue
    static let bgBlue = Color(hex: "#141621")
    static let fillBlue = Color(hex: "#5A68FF")
    static let textBlue = Color(hex: "#C4C7D6")
    static let bgBlue1 = Color(hex: "#141621").opacity(0.12)
    static let fillBlue1 = Color(hex: "#545472")
    static let bgBlue2 = Color(hex: "#C2CAF0").opacity(0.12)
    static let bgBlue3 = Color(hex: "#050713")
    static let textBlue1 = Color(hex: "#6C7398")
    // Red
    static let fillRed = Color(hex: "#FA5E7B")
    // Orange
    static let textOrange = Color(hex: "#FFE0B5")
}

enum DramaSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let base: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl2: CGFloat = 40
    static let xl3: CGFloat = 52
}

enum DramaRadius {
    static let sm: CGFloat = 6
    static let md: CGFloat = 8
    static let base: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let full: CGFloat = 100
}

enum DramaFont {
    static func light(_ size: CGFloat) -> Font { .custom("LexendDeca-Light", size: size) }
    static func regular(_ size: CGFloat) -> Font { .custom("LexendDeca-Regular", size: size) }
    static func medium(_ size: CGFloat) -> Font { .custom("LexendDeca-Medium", size: size) }
    static func semibold(_ size: CGFloat) -> Font { .custom("LexendDeca-SemiBold", size: size) }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
