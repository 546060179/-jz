import SwiftUI

struct UpdateReminderCardView: View {
    let date: String
    let coverUrl: String
    let title: String
    @Binding var reserved: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DateDividerView(date: date)

            VStack(alignment: .leading, spacing: 4) {
                AsyncImage(url: URL(string: coverUrl)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: { Color.gray.opacity(0.3) }
                .frame(width: 117, height: 156)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(DSFont.light(12))
                        .foregroundColor(DSColor.textLight)
                        .frame(height: 32, alignment: .topLeading)
                        .lineLimit(2)
                    RemindButtonView(reserved: reserved) { reserved.toggle() }
                }
                .padding(.horizontal, 4)
            }
        }
        .frame(width: 117)
    }
}
