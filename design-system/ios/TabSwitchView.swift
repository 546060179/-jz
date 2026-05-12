import SwiftUI

struct TabItem: Identifiable {
    let id: String
    let label: String
}

struct TabSwitchView: View {
    let tabs: [TabItem]
    @Binding var activeId: String

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                let active = tab.id == activeId
                Button { activeId = tab.id } label: {
                    Text(tab.label)
                        .font(active ? DSFont.medium(16) : DSFont.regular(14))
                        .foregroundColor(active ? DSColor.primaryLight : .white.opacity(0.68))
                        .textCase(.none)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .frame(height: 40)
                .background(.ultraThinMaterial.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
                .overlay(
                    active ? RoundedRectangle(cornerRadius: DSRadius.lg)
                        .stroke(LinearGradient(colors: [Color(hex: "#CECECE"), Color(hex: "#4051FF")], startPoint: .leading, endPoint: .trailing), lineWidth: 2) : nil
                )
                .shadow(color: active ? Color(hex: "#7F73FF").opacity(0.59) : .clear, radius: 4, y: 4)
            }
        }
    }
}
