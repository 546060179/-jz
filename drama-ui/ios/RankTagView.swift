import SwiftUI

struct RankTagView: View {
    let rank: Int
    var category: String = "Most Popular"

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "flame.fill")
                .font(.system(size: 10))
                .foregroundColor(DramaColor.fillRed)
            Text("\(rank)th in \(category)")
                .font(DramaFont.medium(10))
                .foregroundColor(DramaColor.fillRed)
        }
        .padding(.horizontal, 6)
        .frame(height: 16)
        .overlay(
            Capsule().stroke(DramaColor.fillRed.opacity(0.4), lineWidth: 1)
        )
    }
}
