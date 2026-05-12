import SwiftUI

struct RemindButtonView: View {
    let reserved: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 2) {
                // Use asset catalog icons: "icon-remind" and "icon-checkin"
                Image(reserved ? "icon-checkin" : "icon-remind")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundColor(reserved ? DramaColor.fillBlue : DramaColor.bgBlue)
                Text(reserved ? "Reserved" : "Remind Me")
                    .font(DramaFont.medium(12))
            }
            .foregroundColor(reserved ? DramaColor.fillBlue : DramaColor.bgBlue3)
            .padding(.horizontal, DramaSpacing.sm)
            .frame(height: 24)
            .background(
                Group {
                    if reserved {
                        DramaColor.bgBlue
                    } else {
                        LinearGradient(colors: [Color(hex: "#6A74FF"), Color(hex: "#CECECE")], startPoint: .leading, endPoint: .trailing)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: DramaRadius.md))
        }
    }
}

// Usage: Import icon-remind.svg and icon-checkin.svg from assets/ into Xcode Asset Catalog
