import UIKit

/// 两列瀑布流布局代理
protocol WaterfallLayoutDelegate: AnyObject {
    func waterfallLayout(_ layout: WaterfallLayout, heightForItemAt indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
}

/// 两列瀑布流 UICollectionViewLayout
final class WaterfallLayout: UICollectionViewLayout {

    weak var delegate: WaterfallLayoutDelegate?

    var numberOfColumns: Int = 2
    var cellPadding: CGFloat = 8
    var sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let cv = collectionView else { return 0 }
        return cv.bounds.width - sectionInset.left - sectionInset.right
    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: collectionView?.bounds.width ?? 0, height: contentHeight)
    }

    override func prepare() {
        guard let cv = collectionView, cache.isEmpty else { return }

        let columnWidth = (contentWidth - cellPadding * CGFloat(numberOfColumns - 1)) / CGFloat(numberOfColumns)
        var xOffsets: [CGFloat] = []
        for col in 0..<numberOfColumns {
            xOffsets.append(sectionInset.left + CGFloat(col) * (columnWidth + cellPadding))
        }
        var yOffsets = [CGFloat](repeating: sectionInset.top, count: numberOfColumns)

        for item in 0..<cv.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)

            // 找最短列
            let shortestCol = yOffsets.enumerated().min(by: { $0.element < $1.element })!.offset

            let itemHeight = delegate?.waterfallLayout(self, heightForItemAt: indexPath, withWidth: columnWidth) ?? 200
            let frame = CGRect(x: xOffsets[shortestCol], y: yOffsets[shortestCol], width: columnWidth, height: itemHeight)

            let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attrs.frame = frame
            cache.append(attrs)

            yOffsets[shortestCol] = frame.maxY + cellPadding
        }

        contentHeight = (yOffsets.max() ?? 0) + sectionInset.bottom
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        cache.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cache[indexPath.item]
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        cache.removeAll()
        contentHeight = 0
    }
}
