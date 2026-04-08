import UIKit
import FadeAnimation

// MARK: - 商品数据模型

struct Product {
    let title: String
    let price: String
    let imageHeight: CGFloat   // 模拟不同封面高度（瀑布流效果）
    let imageName: String?     // 可选的本地图片名
}

// MARK: - ProductCardViewController

final class ProductCardViewController: UIViewController {

    private var collectionView: UICollectionView!
    private let waterfallLayout = WaterfallLayout()

    /// 模拟商品数据
    private let products: [Product] = [
        Product(title: "热门短剧·霸道总裁爱上我", price: "¥6.00", imageHeight: 200, imageName: nil),
        Product(title: "独家连载·重生之都市修仙", price: "¥12.00", imageHeight: 240, imageName: nil),
        Product(title: "甜宠日常", price: "¥3.00", imageHeight: 180, imageName: nil),
        Product(title: "悬疑推理·消失的第七天", price: "¥9.90", imageHeight: 220, imageName: nil),
        Product(title: "古装仙侠·九天玄女传", price: "¥15.00", imageHeight: 260, imageName: nil),
        Product(title: "都市言情·余生请多指教", price: "¥6.00", imageHeight: 190, imageName: nil),
        Product(title: "搞笑日常·我的奇葩室友", price: "¥1.00", imageHeight: 170, imageName: nil),
        Product(title: "虐恋情深·半生缘", price: "¥8.00", imageHeight: 230, imageName: nil),
        Product(title: "校园青春·那些年", price: "¥5.00", imageHeight: 210, imageName: nil),
        Product(title: "职场逆袭·打工人翻身记", price: "¥10.00", imageHeight: 250, imageName: nil),
    ]

    /// 记录已动画过的 cell 索引，避免重复动画
    private var animatedIndexPaths = Set<IndexPath>()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.96, alpha: 1)
        title = "精选好剧"
        setupCollectionView()
    }

    // MARK: - Setup

    private func setupCollectionView() {
        waterfallLayout.delegate = self
        waterfallLayout.numberOfColumns = 2
        waterfallLayout.cellPadding = 10
        waterfallLayout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: waterfallLayout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProductCardCell.self, forCellWithReuseIdentifier: ProductCardCell.reuseID)

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - UICollectionViewDataSource

extension ProductCardViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCardCell.reuseID, for: indexPath) as! ProductCardCell
        let product = products[indexPath.item]
        cell.configure(title: product.title, price: product.price, imageHeight: product.imageHeight)

        // 设置封面占位色（实际项目中替换为网络图片加载）
        let colors: [UIColor] = [
            UIColor(red: 0.55, green: 0.47, blue: 0.85, alpha: 1),
            UIColor(red: 0.95, green: 0.55, blue: 0.55, alpha: 1),
            UIColor(red: 0.40, green: 0.73, blue: 0.85, alpha: 1),
            UIColor(red: 0.95, green: 0.77, blue: 0.40, alpha: 1),
            UIColor(red: 0.55, green: 0.82, blue: 0.55, alpha: 1),
        ]
        cell.coverImageView.backgroundColor = colors[indexPath.item % colors.count]

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ProductCardViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 仅首次出现时执行入场动画
        guard !animatedIndexPaths.contains(indexPath) else { return }
        animatedIndexPaths.insert(indexPath)

        // 初始状态：透明 + 向下偏移 20pt
        cell.contentView.alpha = 0
        cell.contentView.transform = CGAffineTransform(translationX: 0, y: 20)

        // 使用 FadeAnimation 库的 fadeIn + 自定义 slideIn
        let delay = Double(indexPath.item) * 0.05
        let options = FadeOptions(duration: 300, delay: Int(delay * 1000))
        cell.contentView.fadeIn(options: options, onEnd: nil)

        // slideIn（从底部）— 与 fadeIn 同步执行
        UIView.animate(
            withDuration: 0.3,
            delay: delay,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                cell.contentView.transform = .identity
            },
            completion: nil
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ProductCardCell else { return }
        // 点击卡片 — scaleIn(duration: 0.2) 再恢复
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            cell.contentView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                cell.contentView.transform = .identity
            })
        }
    }
}

// MARK: - WaterfallLayoutDelegate

extension ProductCardViewController: WaterfallLayoutDelegate {

    func waterfallLayout(_ layout: WaterfallLayout, heightForItemAt indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let product = products[indexPath.item]
        // 封面高度 + 标题区域(~44pt) + 价格/按钮区域(~36pt) + padding
        return product.imageHeight + 80
    }
}
