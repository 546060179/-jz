import SwiftUI

struct GenreTagView: View {
    let label: String
    var dark: Bool = false

    var body: some View {
        Text(label)
            .font(DSFont.regular(9))
            .fontWeight(dark ? .medium : .regular)
            .foregroundColor(dark ? DSColor.tagPurple : DSColor.primary)
            .padding(.horizontal, 6)
            .frame(height: 20)
            .background(dark ? DSColor.bgD2 : DSColor.bgD1)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
    }
}
