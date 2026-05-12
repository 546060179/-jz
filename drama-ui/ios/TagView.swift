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

    var textColor: Color { self == .membersOnly ? DramaColor.textOrange : DramaColor.bgBlue }
    var hasTail: Bool { self != .membersOnly }
}

struct TagView: View {
    let variant: TagVariant
    var label: String?

    var body: some View {
        HStack(spacing: 0) {
            Text(label ?? variant.label)
                .font(DramaFont.medium(9))
                .foregroundColor(variant.textColor)
                .padding(.leading, 8)
                .padding(.trailing, 2)
                .frame(height: 16)
                .background(variant.gradient)
                .clipShape(LeftRoundedShape(radius: DramaRadius.sm))

            if variant.hasTail {
                TagTailShape()
                    .frame(width: 4, height: 20)
            }
        }
        .frame(height: variant.hasTail ? 26 : 16, alignment: .bottom)
    }
}

/// Right-side tail decoration: 4×18 #CECECE top + 4×4 #545472 bottom rounded
struct TagTailShape: View {
    var body: some View {
        VStack(spacing: 0) {
            Color(hex: "#CECECE").frame(width: 4, height: 18)
            Color(hex: "#545472")
                .frame(width: 4, height: 4)
                .clipShape(RoundedRectangle(cornerRadius: 2))
        }
    }
}

struct LeftRoundedShape: Shape {
    let radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: radius, y: 0))
        p.addLine(to: CGPoint(x: rect.maxX, y: 0))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: radius, y: rect.maxY))
        p.addArc(center: CGPoint(x: radius, y: rect.maxY - radius), radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        p.addLine(to: CGPoint(x: 0, y: radius))
        p.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        return p
    }
}
