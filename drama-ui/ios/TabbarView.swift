import SwiftUI

struct TabbarItem: Identifiable {
    let id: String
    let label: String
    let iconName: String  // Asset catalog image name, e.g. "icon-tab-home"
}

struct TabbarView: View {
    let items: [TabbarItem]
    @Binding var activeId: String

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                let active = item.id == activeId
                Button { activeId = item.id } label: {
                    VStack(spacing: 2) {
                        Image(item.iconName)
                            .renderingMode(active ? .original : .template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(active ? nil : DramaColor.textBlue)
                        Text(item.label)
                            .font(active ? DramaFont.semibold(9) : DramaFont.regular(9))
                            .foregroundColor(active ? DramaColor.fillWhite : DramaColor.textBlue)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, DramaSpacing.sm)
            }
        }
        .frame(width: 343, height: 56)
        .background(Color(hex: "#141621").opacity(0.76))
        .clipShape(RoundedRectangle(cornerRadius: DramaRadius.xl))
    }
}

// MARK: - Usage Example
/*
 将 assets/ 目录下的 SVG 图标导入 Xcode Asset Catalog，然后：

 @State private var activeTab = "home"

 TabbarView(
     items: [
         TabbarItem(id: "home", label: "Home", iconName: "icon-tab-home"),
         TabbarItem(id: "short", label: "Short", iconName: "icon-tab-short"),
         TabbarItem(id: "reward", label: "Reward", iconName: "icon-tab-reward"),
         TabbarItem(id: "collect", label: "My List", iconName: "icon-tab-collect"),
         TabbarItem(id: "profile", label: "Profile", iconName: "icon-tab-profile"),
     ],
     activeId: $activeTab
 )
*/
