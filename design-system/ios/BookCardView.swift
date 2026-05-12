import SwiftUI

struct BookCardView: View {
    let coverUrl: String
    let title: String
    let description: String
    let genres: [String]
    var badge: TagVariant?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                AsyncImage(url: URL(string: coverUrl)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: { Color.gray.opacity(0.3) }
                .frame(width: 225, height: 300)
                .clipped()
            }
            .frame(width: 225)
            .background(DSColor.bgD2)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
            .overlay(alignment: .bottom) {
                VStack(spacing: 0) {
                    LinearGradient(colors: [.clear, DSColor.bgD2], startPoint: .top, endPoint: .bottom)
                        .frame(height: 40)
                    VStack(alignment: .leading, spacing: 8) {
                        // Genre tags
                        HStack(spacing: 4) {
                            ForEach(genres, id: \.self) { genre in
                                GenreTagView(label: genre)
                            }
                        }
                        // Title & description
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(DSFont.regular(20))
                                .foregroundColor(DSColor.textWhite)
                                .lineLimit(1)
                            Text(description)
                                .font(DSFont.light(12))
                                .foregroundColor(DSColor.textMuted)
                                .frame(height: 32, alignment: .topLeading)
                                .lineLimit(2)
                        }
                        .padding(.horizontal, 4)
                        .padding(.bottom, 4)
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 4)
                    .background(DSColor.bgD2)
                }
            }

            if let badge {
                TagView(variant: badge).padding(.top, 8)
            }
        }
        .frame(width: 225)
    }
}
