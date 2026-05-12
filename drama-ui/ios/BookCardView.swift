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
            .background(DramaColor.bgBlue)
            .clipShape(RoundedRectangle(cornerRadius: DramaRadius.base))
            .overlay(alignment: .bottom) {
                VStack(spacing: 0) {
                    LinearGradient(colors: [.clear, DramaColor.bgBlue], startPoint: .top, endPoint: .bottom)
                        .frame(height: 40)
                    VStack(alignment: .leading, spacing: DramaSpacing.sm) {
                        HStack(spacing: DramaSpacing.xs) {
                            ForEach(genres, id: \.self) { g in GenreTagView(label: g) }
                        }
                        VStack(alignment: .leading, spacing: DramaSpacing.xs) {
                            Text(title)
                                .font(DramaFont.regular(20))
                                .foregroundColor(DramaColor.fillWhite)
                                .lineLimit(1)
                            Text(description)
                                .font(DramaFont.light(12))
                                .foregroundColor(DramaColor.textBlue1)
                                .frame(height: 32, alignment: .topLeading)
                                .lineLimit(2)
                        }
                        .padding(.horizontal, DramaSpacing.xs)
                        .padding(.bottom, DramaSpacing.xs)
                    }
                    .padding(.horizontal, DramaSpacing.xs)
                    .padding(.bottom, DramaSpacing.xs)
                    .background(DramaColor.bgBlue)
                }
            }
            if let badge { TagView(variant: badge).padding(.top, DramaSpacing.sm) }
        }
        .frame(width: 225)
    }
}
