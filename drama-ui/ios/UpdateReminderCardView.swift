import SwiftUI

struct UpdateReminderCardView: View {
    let date: String
    let coverUrl: String
    let title: String
    @Binding var reserved: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DramaSpacing.sm) {
            DateDividerView(date: date)
            VStack(alignment: .leading, spacing: DramaSpacing.xs) {
                AsyncImage(url: URL(string: coverUrl)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: { Color.gray.opacity(0.3) }
                .frame(width: 117, height: 156)
                .clipShape(RoundedRectangle(cornerRadius: DramaRadius.base))

                VStack(alignment: .leading, spacing: DramaSpacing.sm) {
                    Text(title)
                        .font(DramaFont.light(12))
                        .foregroundColor(DramaColor.textBlue)
                        .frame(height: 32, alignment: .topLeading)
                        .lineLimit(2)
                    RemindButtonView(reserved: reserved) { reserved.toggle() }
                }
                .padding(.horizontal, DramaSpacing.xs)
            }
        }
        .frame(width: 117)
    }
}
