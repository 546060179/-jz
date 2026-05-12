import SwiftUI

// MARK: - Design Tokens
enum DSColor {
    static let primary = Color(hex: "#5A68FF")
    static let primaryLight = Color(hex: "#BDC3FF")
    static let bgD1 = Color(hex: "#050713")
    static let bgD2 = Color(hex: "#141621")
    static let bgCard = Color(hex: "#C2CAF0").opacity(0.12)
    static let textWhite = Color.white
    static let textLight = Color(hex: "#C4C7D6")
    static let textMuted = Color(hex: "#6C7398")
    static let tagPurple = Color(hex: "#5D67F4")
    static let vipGold = Color(hex: "#FFE0B5")
}

enum DSFont {
    static func light(_ size: CGFloat) -> Font { .custom("LexendDeca-Light", size: size) }
    static func regular(_ size: CGFloat) -> Font { .custom("LexendDeca-Regular", size: size) }
    static func medium(_ size: CGFloat) -> Font { .custom("LexendDeca-Medium", size: size) }
}

enum DSRadius {
    static let sm: CGFloat = 6
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let full: CGFloat = 100
}

// MARK: - Color Hex Extension
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
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
