import SwiftUI

struct TabPillItem: Identifiable {
    let id: String
    let label: String
}

struct TabPillView: View {
    let tabs: [TabPillItem]
    @Binding var activeId: String

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                let active = tab.id == activeId
                Button { activeId = tab.id } label: {
                    Text(tab.label)
                        .font(active ? DramaFont.medium(16) : DramaFont.regular(14))
                        .foregroundColor(active ? Color(hex: "#BDC3FF") : DramaColor.textWhite)
                }
                .padding(.horizontal, DramaSpacing.md)
                .padding(.vertical, DramaSpacing.xs)
                .frame(height: 40)
                .background(.ultraThinMaterial.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: DramaRadius.base))
                .overlay(active ?
                    RoundedRectangle(cornerRadius: DramaRadius.base)
                        .stroke(LinearGradient(colors: [Color(hex: "#CECECE"), Color(hex: "#4051FF")], startPoint: .leading, endPoint: .trailing), lineWidth: 2) : nil
                )
                .shadow(color: active ? Color(hex: "#7F73FF").opacity(0.59) : .clear, radius: 4, y: 4)
            }
        }
    }
}
