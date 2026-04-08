import UIKit

struct Product {
    let id: Int
    let title: String
    let price: String
    let imageName: String
}

class ProductListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let collectionView: UICollectionView
    private var products: [Product] = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadProducts()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "商品列表"
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProductCardCell.self, forCellWithReuseIdentifier: "ProductCardCell")
        collectionView.backgroundColor = .clear
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func loadProducts() {
        products = [
            Product(id: 1, title: "时尚休闲鞋", price: "¥299", imageName: "card_1"),
            Product(id: 2, title: "潮流T恤", price: "¥129", imageName: "card_2"),
            Product(id: 3, title: "运动背包", price: "¥399", imageName: "card_3"),
            Product(id: 4, title: "智能手表", price: "¥899", imageName: "card_4"),
            Product(id: 5, title: "无线耳机", price: "¥599", imageName: "card_5"),
            Product(id: 6, title: "护肤套装", price: "¥499", imageName: "card_6"),
            Product(id: 7, title: "家居摆件", price: "¥199", imageName: "card_7"),
            Product(id: 8, title: "厨房电器", price: "¥699", imageName: "card_8")
        ]
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCardCell", for: indexPath) as! ProductCardCell
        let product = products[indexPath.item]
        cell.configure(with: product)
        
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 50)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(indexPath.item) * 0.05) {
            UIView.animate(withDuration: 0.3) {
                cell.alpha = 1
                cell.transform = .identity
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ProductCardCell else { return }
        UIView.animate(withDuration: 0.1, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                cell.transform = .identity
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 48) / 2
        return CGSize(width: width, height: width * 1.4)
    }
}
