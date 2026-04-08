import UIKit

/// 3列等宽网格布局（匹配 Figma 设计稿：3 列 x N 行，间距 8pt，行距 12pt）
final class ShortMaxGridLayout: UICollectionViewFlowLayout {

    private let columns: Int = 3

    override func prepare() {
        super.prepare()
        guard let cv = collectionView else { return }

        let totalWidth = cv.bounds.width - ShortMaxDesign.sectionPadding * 2
        let itemWidth = (totalWidth - ShortMaxDesign.gridSpacing * CGFloat(columns - 1)) / CGFloat(columns)
        // 封面 145 + 间距 8 + 标题 34 + 间距 4 + 标签 16 = 207
        let itemHeight: CGFloat = ShortMaxDesign.coverHeight + 8 + 34 + 4 + 16

        itemSize = CGSize(width: floor(itemWidth), height: itemHeight)
        minimumInteritemSpacing = ShortMaxDesign.gridSpacing
        minimumLineSpacing = ShortMaxDesign.rowSpacing
        sectionInset = UIEdgeInsets(
            top: ShortMaxDesign.rowSpacing,
            left: ShortMaxDesign.sectionPadding,
            bottom: ShortMaxDesign.rowSpacing,
            right: ShortMaxDesign.sectionPadding
        )
    }
}
