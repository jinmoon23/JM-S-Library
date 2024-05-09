//
//  ViewController.swift
//  Jinmoon'sLibrary
//
//  Created by 최진문 on 2024/05/02.
//

import UIKit
import SnapKit

class ViewController: UIViewController, UISearchBarDelegate {
    

    let bookSearchBar = UISearchBar()
    let recentViewLabel = UILabel()
    let resultLabel = UILabel()
    let backgroundView = UIView()
    
    let recentFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = .init(top: 0, left: 10, bottom: 0, right: 0)
        layout.itemSize = .init(width: 50, height: 50)
        return layout
    }()
    
    let resultFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        let cellWidth: CGFloat = {
            let deviceWidth = UIScreen.main.bounds.width
            let inset: CGFloat = 20
            let numberOfLine: CGFloat = 1
            let width: CGFloat = (deviceWidth - inset * 2 - 1) / numberOfLine
            return width
        }()
        layout.itemSize = .init(width: cellWidth, height: cellWidth/5)
        return layout
    }()
    
    lazy var resultCollectionView = UICollectionView(frame: .zero, collectionViewLayout: resultFlowLayout)
    lazy var recentCollectionView = UICollectionView(frame: .zero, collectionViewLayout: recentFlowLayout)
    
    func configureUI() {
        view.addSubview(backgroundView)
        view.addSubview(bookSearchBar)
        view.addSubview(recentViewLabel)
        view.addSubview(recentCollectionView)
        view.addSubview(resultLabel)
        view.addSubview(resultCollectionView)
        
        backgroundView.backgroundColor = .white
        
        recentViewLabel.text = "최근 본 책"
        recentViewLabel.font = UIFont.boldSystemFont(ofSize: 30)
        
        
        recentCollectionView.backgroundColor = .systemGray5
        recentCollectionView.dataSource = self
        recentCollectionView.delegate = self
        recentCollectionView.register(RecentCollectionViewCell.self, forCellWithReuseIdentifier: RecentCollectionViewCell.identifier)
        
        resultCollectionView.dataSource = self
        resultCollectionView.delegate = self
        resultCollectionView.backgroundColor = .white
        resultCollectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
        
        resultLabel.text = "검색 결과"
        resultLabel.font = UIFont.boldSystemFont(ofSize: 30)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setUpSearchBar()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultCollectionView.reloadData()
        recentCollectionView.reloadData()
    }
    func setConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bookSearchBar.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        recentViewLabel.snp.makeConstraints { make in
            make.top.equalTo(bookSearchBar.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
        }
        recentCollectionView.snp.makeConstraints { make in
            make.top.equalTo(recentViewLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(80)
        }
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(recentCollectionView.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
        }
        resultCollectionView.snp.makeConstraints{ make in
            make.top.equalTo(resultLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }
    }

    func setUpSearchBar() {
        
        bookSearchBar.delegate = self
        bookSearchBar.placeholder = "여기서 책을 검색하세요!"
        bookSearchBar.sizeToFit()
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        switchToSearchViewController()
        return false
    }
    
    private func switchToSearchViewController() {
        guard let tabBarController = self.tabBarController else { return }
        tabBarController.selectedIndex = 0  // 1번째 탭(인덱스 0)으로 전환
    }
    
    
}
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == resultCollectionView {
            return SharedDataModel.shared.books.count
        } else {
            return SharedDataModel.shared.recentSelectedBooks.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == resultCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier, for: indexPath) as? SearchCollectionViewCell else {return UICollectionViewCell()}
            let book = SharedDataModel.shared.books[indexPath.row]
            cell.configureUI(with: book)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentCollectionViewCell.identifier, for: indexPath) as? RecentCollectionViewCell else {return UICollectionViewCell()}
            let book = SharedDataModel.shared.recentSelectedBooks[indexPath.row]
            cell.configureUI(with: book)
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == resultCollectionView {
            let book = SharedDataModel.shared.books[indexPath.row]       
            let selectedBooks = SharedDataModel.shared.books[indexPath.row]
            SharedDataModel.shared.recentSelectedBooks.append(selectedBooks)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.recentCollectionView.reloadData()
                }
            let detailVC = DetailViewController()
            detailVC.book = book
            self.present(detailVC, animated: true, completion: nil)
        } else {
            let selectedBooks = SharedDataModel.shared.recentSelectedBooks[indexPath.row]
            let detailVC = DetailViewController()
            detailVC.book = selectedBooks
            self.present(detailVC, animated: true, completion: nil)
        }
        
    }
}


