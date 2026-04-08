import UIKit
import FadeAnimation

/// ShortMax 风格商品卡片页面 — 匹配 Figma 设计稿
/// 集成 FadeAnimation 库实现卡片入场淡入 + 滑入动效，以及消失淡出动效
final class ShortMaxViewController: UIViewController {

    private var collectionView: UICollectionView!
    private let gridLayout = ShortMaxGridLayout()

    /// 记录已执行入场动画的 cell，避免重复
    private var animatedIndexPaths = Set<IndexPath>()

    /// 模拟数据（匹配 Figma 设计稿中的短剧列表）
    private let dramas: [ShortDrama] = [
        ShortDrama(title: "Lycan Princess Won't Be Your Luna",
                   viewCount: "667.3M", coverURL: nil,
                   tag: .hot,
                   genreTag: nil,
                   rankTag: ShortDrama.RankTag(listName: "Monthly List", rank: "Top5.")),
        ShortDrama(title: "Sinful Love With Alphas",
                   viewCount: "93.3M", coverURL: nil,
                   tag: .new,
                   genreTag: "Secret Baby", rankTag: nil),
        ShortDrama(title: "Sweet Rebirth Fated Revenge",
                   viewCount: "667.3M", coverURL: nil,
                   tag: nil,
                   genreTag: "Revenge", rankTag: nil),
        ShortDrama(title: "Mommy, We Need Daddy! CEO's Escaped Wife Returns",
                   viewCount: "667.3M", coverURL: nil,
                   tag: .vip,
                   genreTag: "CEO", rankTag: nil),
        ShortDrama(title: "Sweet Rebirth Fated Revenge",
                   viewCount: "667.3M", coverURL: nil,
                   tag: .vip,
                   genreTag: "Revenge", rankTag: nil),
        ShortDrama(title: "The Forbidden Alpha",
                   viewCount: "667.3M", coverURL: nil,
                   tag: .hot,
                   genreTag: nil, rankTag: nil),
        ShortDrama(title: "Mommy, We Need Daddy! CEO's Escaped Wife Returns",
                   viewCount: "667.3M", coverURL: nil,
                   tag: .dubbed,
                   genreTag: "CEO", rankTag: nil),
        ShortDrama(title: "Sinful Love With Alphas",
                   viewCount: "667.3M", coverURL: nil,
                   tag: .dubbed,
                   genreTag: "Secret Baby", rankTag: nil),
        ShortDrama(title: "Sweet Rebirth Fated Revenge",
                   viewCount: "667.3M", coverURL: nil,
                   tag: nil,
                   genreTag: "Revenge", rankTag: nil),
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ShortMaxDesign.bgPrimary
        setupNavigationBar()
        setupCollectionView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Setup

    private func setupNavigationBar() {
        // 搜索栏（匹配 Figma 设计稿的毛玻璃搜索框）
        let searchBar = UIView()
        searchBar.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        searchBar.layer.cornerRadius = 4
        searchBar.layer.borderWidth = 0.5
        searchBar.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        let searchLabel = UILabel()
        searchLabel.text = "Lycan Princess Won't Be Your Luna"
        searchLabel.font = ShortMaxDesign.montserrat(.medium, size: 10)
        searchLabel.textColor = ShortMaxDesign.textTertiary
        searchLabel.translatesAutoresizingMaskIntoConstraints = false
        searchBar.addSubview(searchLabel)

        let searchIcon = UILabel()
        searchIcon.text = "🔍"
        searchIcon.font = .systemFont(ofSize: 12)
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        searchBar.addSubview(searchIcon)

        // Tab 栏
        let tabStack = UIStackView()
        tabStack.axis = .horizontal
        tabStack.spacing = 20
        tabStack.alignment = .center
        tabStack.translatesAutoresizingMaskIntoConstraints = false

        let tabs = ["Popular", "VIP", "Rankings", "Categories", "Marriage", "Werewolf", "Fantasy"]
        let activeTab = "Categories"
        for tab in tabs {
            let label = UILabel()
            label.text = tab
            if tab == activeTab {
                label.font = ShortMaxDesign.montserrat(.bold, size: 18)
                label.textColor = .white
            } else {
                label.font = ShortMaxDesign.montserrat(.medium, size: 14)
                label.textColor = ShortMaxDesign.textSecondary
            }
            tabStack.addArrangedSubview(label)
        }

        // 子分类标签
        let subCategoryView = UIView()
        subCategoryView.translatesAutoresizingMaskIntoConstraints = false

        let subLabel = UILabel()
        subLabel.text = "Male · Werewolf Love"
        subLabel.font = ShortMaxDesign.montserrat(.medium, size: 12)
        subLabel.textColor = ShortMaxDesign.accentOrange
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        subCategoryView.addSubview(subLabel)

        let arrowBtn = UIView()
        arrowBtn.backgroundColor = ShortMaxDesign.accentOrange.withAlphaComponent(0.1)
        arrowBtn.layer.cornerRadius = 10
        arrowBtn.translatesAutoresizingMaskIntoConstraints = false
        let arrowLabel = UILabel()
        arrowLabel.text = "›"
        arrowLabel.font = .systemFont(ofSize: 14, weight: .bold)
        arrowLabel.textColor = ShortMaxDesign.accentOrange
        arrowLabel.textAlignment = .center
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowBtn.addSubview(arrowLabel)
        subCategoryView.addSubview(arrowBtn)

        // Header 容器
        let headerStack = UIStackView(arrangedSubviews: [searchBar, tabStack, subCategoryView])
        headerStack.axis = .vertical
        headerStack.spacing = 0
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerStack)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            searchBar.heightAnchor.constraint(equalToConstant: 32),
            searchLabel.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            searchLabel.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 12),
            searchIcon.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            searchIcon.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -12),

            tabStack.heightAnchor.constraint(equalToConstant: 32),

            subCategoryView.heightAnchor.constraint(equalToConstant: 28),
            subLabel.centerYAnchor.constraint(equalTo: subCategoryView.centerYAnchor),
            subLabel.leadingAnchor.constraint(equalTo: subCategoryView.leadingAnchor),
            arrowBtn.centerYAnchor.constraint(equalTo: subCategoryView.centerYAnchor),
            arrowBtn.trailingAnchor.constraint(equalTo: subCategoryView.trailingAnchor),
            arrowBtn.widthAnchor.constraint(equalToConstant: 20),
            arrowBtn.heightAnchor.constraint(equalToConstant: 20),
            arrowLabel.centerXAnchor.constraint(equalTo: arrowBtn.centerXAnchor),
            arrowLabel.centerYAnchor.constraint(equalTo: arrowBtn.centerYAnchor),
        ])

        // 保存 header 高度用于 collectionView 偏移
        headerStack.tag = 100
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: gridLayout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ShortMaxCardCell.self, forCellWithReuseIdentifier: ShortMaxCardCell.reuseID)

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            // 留出 header 空间: searchBar(32) + tab(32) + subCategory(28) + safeArea
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 92),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - 卡片消失动效（公开方法，供外部调用）

    /// 让指定卡片以淡出 + 缩小动效消失
    func dismissCard(at indexPath: IndexPath, completion: (() -> Void)? = nil) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            completion?()
            return
        }

        // 使用 FadeAnimation 库的 fadeOut
        let fadeOptions = FadeOptions(duration: 250)
        cell.contentView.fadeOut(options: fadeOptions, onEnd: completion)

        // 同步执行缩小动画
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                cell.contentView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            },
            completion: nil
        )
    }

    /// 让所有可见卡片依次淡出消失
    func dismissAllCards(completion: (() -> Void)? = nil) {
        let visibleCells = collectionView.visibleCells
        let total = visibleCells.count
        guard total > 0 else {
            completion?()
            return
        }

        for (index, cell) in visibleCells.enumerated() {
            let delay = Int(Double(index) * 30) // 每张卡片延迟 30ms
            let fadeOptions = FadeOptions(duration: 200, delay: delay)

            let isLast = index == total - 1
            cell.contentView.fadeOut(options: fadeOptions, onEnd: isLast ? completion : nil)

            UIView.animate(
                withDuration: 0.2,
                delay: Double(delay) / 1000.0,
                options: .curveEaseIn,
                animations: {
                    cell.contentView.transform = CGAffineTransform(translationX: 0, y: -10)
                },
                completion: nil
            )
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ShortMaxViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dramas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShortMaxCardCell.reuseID, for: indexPath) as! ShortMaxCardCell
        cell.configure(with: dramas[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ShortMaxViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // 仅首次出现时执行入场动画
        guard !animatedIndexPaths.contains(indexPath) else { return }
        animatedIndexPaths.insert(indexPath)

        // 初始状态：透明 + 向下偏移 20pt
        cell.contentView.alpha = 0
        cell.contentView.transform = CGAffineTransform(translationX: 0, y: 20)

        // 使用 FadeAnimation 库的 fadeIn — 交错延迟
        let staggerDelay = Int(Double(indexPath.item) * 50) // 每张卡片延迟 50ms
        let fadeOptions = FadeOptions(duration: 300, delay: staggerDelay)
        cell.contentView.fadeIn(options: fadeOptions, onEnd: nil)

        // 同步执行 slideIn（弹性动画）
        UIView.animate(
            withDuration: 0.3,
            delay: Double(staggerDelay) / 1000.0,
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
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        // 点击反馈：缩放 0.96 → 恢复（匹配 Figma 交互规范）
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            cell.contentView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                cell.contentView.transform = .identity
            })
        }
    }
}
