import SwiftUI

struct SmallBookCardView: View {
    let coverUrl: String
    let title: String
    let playCount: String
    let genres: [String]
    var badge: TagVariant?

    var body: some View {
        VStack(alignment: .leading, spacing: DramaSpacing.xs) {
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .bottomTrailing) {
                    AsyncImage(url: URL(string: coverUrl)) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: { Color.gray.opacity(0.3) }
                    .frame(width: 117, height: 156)
                    .clipped()

                    HStack(spacing: DramaSpacing.xs) {
                        Image(systemName: "play.fill").font(.system(size: 8)).foregroundColor(.white)
                        Text(playCount).font(DramaFont.medium(10)).foregroundColor(.white)
                    }
                    .padding(.horizontal, DramaSpacing.xs)
                    .frame(height: 20)
                    .background(.ultraThinMaterial.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: DramaRadius.md))
                    .padding(DramaSpacing.xs)
                }
                .clipShape(RoundedRectangle(cornerRadius: DramaRadius.base))

                if let badge { TagView(variant: badge).padding(.top, DramaSpacing.xs) }
            }

            VStack(alignment: .leading, spacing: DramaSpacing.xs) {
                Text(title)
                    .font(DramaFont.light(12))
                    .foregroundColor(DramaColor.textBlue)
                    .frame(height: 32, alignment: .topLeading)
                    .lineLimit(2)
                HStack(spacing: DramaSpacing.xs) {
                    ForEach(genres, id: \.self) { g in GenreTagView(label: g, dark: true) }
                }
            }
            .padding(.horizontal, DramaSpacing.xs)
        }
        .frame(width: 117)
    }
}
