import SwiftUI

struct GenreTagView: View {
    let label: String
    var dark: Bool = false

    var body: some View {
        Text(label)
            .font(DramaFont.regular(9))
            .fontWeight(dark ? .medium : .regular)
            .foregroundColor(dark ? Color(hex: "#5D67F4") : DramaColor.fillBlue)
            .padding(.horizontal, 6)
            .frame(height: 20)
            .background(dark ? DramaColor.bgBlue : DramaColor.bgBlue3)
            .clipShape(RoundedRectangle(cornerRadius: DramaRadius.md))
    }
}
