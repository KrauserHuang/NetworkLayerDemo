//
//  ViewController.swift
//  NetworkLayerDemo
//
//  Created by Tai Chin Huang on 2024/4/7.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SectionItem> { cell, indexPath, itemIdentifier in
        var content = UIListContentConfiguration.cell()
        content.text = "CollectionView"
        content.image = UIImage(systemName: "square.grid.2x2.fill")
        cell.contentConfiguration = content
    }
    
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, SectionItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SectionItem>
    private lazy var dataSource = makeDataSource()
    private var viewModel: ViewModel?
    
//    init(viewModel: ViewModel = ViewModel()) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("Could not create ViewController")
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ViewModel()
        bindToViewModel()
        setupUI()
        setupConstraint()
        updateSnapshot(animated: true)
    }
    
    private func bindToViewModel() {
        guard let viewModel = viewModel else { return }
        viewModel.fetchInitData()
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

extension ViewController {
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self else { return nil }
            return collectionView.dequeueConfiguredReusableCell(using: self.cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        return dataSource
    }
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(44))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func updateSnapshot(animated: Bool = false) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([.collectionView])
        snapshot.appendItems([.collectionView], toSection: .collectionView)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionItem = dataSource.itemIdentifier(for: indexPath) else { return }
        var vc: UIViewController?
        
        switch sectionItem {
        case .collectionView:
            vc = CollectionViewDemoViewController()
        }
        
        guard let viewController = vc else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ViewController {
    enum Section {
        case collectionView
    }
    
    enum SectionItem {
        case collectionView
    }
}
