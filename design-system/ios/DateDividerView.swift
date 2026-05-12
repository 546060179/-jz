import SwiftUI

struct DateDividerView: View {
    let date: String

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(LinearGradient(colors: [.clear, DSColor.textMuted.opacity(0.12)], startPoint: .leading, endPoint: .trailing))
                .frame(width: 28.5, height: 1)
            Text(date)
                .font(DSFont.light(12))
                .foregroundColor(DSColor.textMuted)
                .padding(.horizontal, 8)
                .frame(height: 20)
                .background(DSColor.bgCard)
                .clipShape(Capsule())
            Rectangle()
                .fill(LinearGradient(colors: [DSColor.textMuted.opacity(0.12), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
        }
    }
}
