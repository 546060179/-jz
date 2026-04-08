import UIKit
import FadeAnimation

// MARK: - 数据模型（匹配 Figma 设计稿）

struct ShortDrama {
    let title: String
    let viewCount: String       // e.g. "667.3M"
    let coverURL: String?       // 网络封面图 URL
    let tag: Tag?               // 右上角标签
    let genreTag: String?       // 底部题材标签 e.g. "Revenge", "CEO"
    let rankTag: RankTag?       // 排行榜标签

    struct Tag {
        let text: String
        let color: UIColor

        static let hot = Tag(text: "Hot", color: UIColor(red: 246/255, green: 15/255, blue: 50/255, alpha: 1))
        static let new = Tag(text: "New", color: UIColor(red: 52/255, green: 193/255, blue: 28/255, alpha: 1))
        static let dubbed = Tag(text: "Dubbed", color: UIColor(red: 15/255, green: 165/255, blue: 246/255, alpha: 1))
        static let vip = Tag(text: "VIP", color: .clear) // VIP 使用渐变
    }

    struct RankTag {
        let listName: String    // e.g. "Monthly List"
        let rank: String        // e.g. "Top5."
    }
}

// MARK: - 设计 Token（从 Figma 提取）

enum ShortMaxDesign {
    // 颜色
    static let bgPrimary = UIColor(red: 17/255, green: 18/255, blue: 24/255, alpha: 1)       // #111218
    static let bgCard = UIColor(red: 35/255, green: 37/255, blue: 42/255, alpha: 1)           // #23252A
    static let textPrimary = UIColor.white
    static let textSecondary = UIColor(red: 159/255, green: 159/255, blue: 162/255, alpha: 1) // #9F9FA2
    static let textTertiary = UIColor(red: 130/255, green: 131/255, blue: 134/255, alpha: 1)  // #828386
    static let accentOrange = UIColor(red: 246/255, green: 97/255, blue: 15/255, alpha: 1)    // #F6610F
    static let accentRed = UIColor(red: 246/255, green: 15/255, blue: 50/255, alpha: 1)       // #F60F32
    static let tagRedBg = UIColor(red: 246/255, green: 15/255, blue: 50/255, alpha: 0.2)

    // 尺寸
    static let cardWidth: CGFloat = 109
    static let coverHeight: CGFloat = 145
    static let coverRadius: CGFloat = 4
    static let gridSpacing: CGFloat = 8
    static let sectionPadding: CGFloat = 16
    static let rowSpacing: CGFloat = 12

    // 字体 (Montserrat)
    static func montserrat(_ weight: UIFont.Weight, size: CGFloat) -> UIFont {
        // 优先使用 Montserrat，回退到系统字体
        let name: String
        switch weight {
        case .black: name = "Montserrat-Black"
        case .bold: name = "Montserrat-Bold"
        case .semibold: name = "Montserrat-SemiBold"
        case .medium: name = "Montserrat-Medium"
        default: name = "Montserrat-Regular"
        }
        return UIFont(name: name, size: size) ?? .systemFont(ofSize: size, weight: weight)
    }
}
