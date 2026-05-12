import SwiftUI

enum TagVariant: String, CaseIterable {
    case new, hot, free, exclusive, membersOnly

    var label: String {
        switch self {
        case .new: return "New"
        case .hot: return "Hot"
        case .free: return "Free"
        case .exclusive: return "Exclusive"
        case .membersOnly: return "Members Only"
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .new, .free, .exclusive:
            return LinearGradient(colors: [Color(hex: "#6A74FF"), Color(hex: "#CECECE")], startPoint: .leading, endPoint: .trailing)
        case .hot:
            return LinearGradient(colors: [Color(hex: "#FA5E7B"), Color(hex: "#CECECE")], startPoint: .leading, endPoint: .trailing)
        case .membersOnly:
            return LinearGradient(colors: [Color(hex: "#121732"), Color(hex: "#2634C7")], startPoint: .leading, endPoint: .trailing)
        }
    }

    var textColor: Color {
        self == .membersOnly ? DSColor.vipGold : DSColor.bgD2
    }
}

struct TagView: View {
    let variant: TagVariant
    var label: String?

    var body: some View {
        Text(label ?? variant.label)
            .font(DSFont.medium(9))
            .foregroundColor(variant.textColor)
            .padding(.leading, 8)
            .padding(.trailing, 2)
            .frame(height: 16)
            .background(variant.gradient)
            .clipShape(TagShape(cornerRadius: DSRadius.sm))
    }
}

/// Custom shape for left-rounded tag (iOS 15+ compatible)
struct TagShape: Shape {
    let cornerRadius: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.maxY))
        path.addArc(center: CGPoint(x: cornerRadius, y: rect.maxY - cornerRadius), radius: cornerRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        return path
    }
}
