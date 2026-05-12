import SwiftUI

struct RemindButtonView: View {
    let reserved: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 2) {
                Image(systemName: reserved ? "checkmark" : "bell.fill")
                    .font(.system(size: 12))
                Text(reserved ? "Reserved" : "Remind Me")
                    .font(DSFont.medium(12))
            }
            .foregroundColor(reserved ? DSColor.primary : DSColor.bgD1)
            .padding(.horizontal, 8)
            .frame(height: 24)
            .background(
                Group {
                    if reserved {
                        DSColor.bgD2
                    } else {
                        LinearGradient(colors: [Color(hex: "#6A74FF"), Color(hex: "#CECECE")], startPoint: .leading, endPoint: .trailing)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
        }
    }
}
