import SwiftUI

struct SmallBookCardView: View {
    let coverUrl: String
    let title: String
    let playCount: String
    let genres: [String]
    var badge: TagVariant?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Cover
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .bottomTrailing) {
                    AsyncImage(url: URL(string: coverUrl)) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: { Color.gray.opacity(0.3) }
                    .frame(width: 117, height: 156)
                    .clipped()

                    // Play count
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.white)
                        Text(playCount)
                            .font(DSFont.medium(10))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 4)
                    .frame(height: 20)
                    .background(.ultraThinMaterial.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
                    .padding(4)
                }
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))

                if let badge {
                    TagView(variant: badge).padding(.top, 4)
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DSFont.light(12))
                    .foregroundColor(DSColor.textLight)
                    .frame(height: 32, alignment: .topLeading)
                    .lineLimit(2)
                HStack(spacing: 4) {
                    ForEach(genres, id: \.self) { genre in
                        GenreTagView(label: genre, dark: true)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 117)
    }
}
