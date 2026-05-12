import SwiftUI

struct DateDividerView: View {
    let date: String

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(LinearGradient(colors: [.clear, DramaColor.textBlue1.opacity(0.12)], startPoint: .leading, endPoint: .trailing))
                .frame(width: 28.5, height: 1)
            Text(date)
                .font(DramaFont.light(12))
                .foregroundColor(DramaColor.textBlue1)
                .padding(.horizontal, DramaSpacing.sm)
                .frame(height: 20)
                .background(DramaColor.bgBlue2)
                .clipShape(Capsule())
            Rectangle()
                .fill(LinearGradient(colors: [DramaColor.textBlue1.opacity(0.12), .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
        }
    }
}
