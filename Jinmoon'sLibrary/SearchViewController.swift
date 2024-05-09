//
//  SearchViewController.swift
//  Jinmoon'sLibrary
//
//  Created by 최진문 on 2024/05/02.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    var books: [Book] = [] {
        didSet {
            resultCollectionView.reloadData()
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setConstraints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bookSearchBar.becomeFirstResponder()
    }
    
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
    let resultLabel = UILabel()
    let bookSearchBar = UISearchBar()
    let backgroundView = UIView()
    
    func configureUI() {
        view.addSubview(backgroundView)
        view.addSubview(resultCollectionView)
        view.addSubview(resultLabel)
        view.addSubview(bookSearchBar)
        
        resultCollectionView.dataSource = self
        resultCollectionView.delegate = self
        resultCollectionView.backgroundColor = .white
        resultCollectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
        
        resultLabel.text = "검색결과"
        resultLabel.font = UIFont.boldSystemFont(ofSize: 30)
        backgroundView.backgroundColor = .white
        bookSearchBar.delegate = self
        bookSearchBar.placeholder = "여기서 책을 검색하세요!"
        bookSearchBar.sizeToFit()
    }

    func setConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bookSearchBar.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(bookSearchBar.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
        }
        resultCollectionView.snp.makeConstraints{ make in
            make.top.equalTo(resultLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    func fetchBooks(query: String, completion: @escaping (SearchResults?, Error?) -> Void) {
        let urlString = "https://dapi.kakao.com/v3/search/book"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("KakaoAK a9aa5c137dd8f1a1a8d8205837a88594", forHTTPHeaderField: "Authorization")
        let queryItem = URLQueryItem(name: "query", value: query)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [queryItem]
        request.url = components?.url
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error: \(error)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                completion(nil, NSError(domain: "", code: httpResponse.statusCode, userInfo: nil))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil, NSError(domain: "", code: -1001, userInfo: nil))
                return
            }
            
            do {
                let results = try JSONDecoder().decode(SearchResults.self, from: data)
                completion(results, nil)
            } catch {
                print("Decoding error: \(error)")
                completion(nil, error)
            }
        }
        task.resume()
    }

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder()  // 키보드 숨기기

           if let searchText = searchBar.text, !searchText.isEmpty {
               fetchBooks(query: searchText) { [weak self] results, error in
                   DispatchQueue.main.async {
                       if let results = results {
                           // 검색 결과를 화면에 표시하는 로직
                           self?.updateBooks(results.documents)
                       } else if let error = error {
                           print("Error: \(error.localizedDescription)")
                       }
                   }
               }
           }
       }
    
    func updateBooks(_ books: [Book]) {
        SharedDataModel.shared.books = books
        self.resultCollectionView.reloadData()
       }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SharedDataModel.shared.books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier, for: indexPath) as? SearchCollectionViewCell else {return UICollectionViewCell()}
        let book = SharedDataModel.shared.books[indexPath.row]
        cell.configureUI(with: book)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = SharedDataModel.shared.books[indexPath.row]
        let selectedBooks = SharedDataModel.shared.books[indexPath.row]
        SharedDataModel.shared.recentSelectedBooks.append(selectedBooks)
        let detailVC = DetailViewController()
        detailVC.book = book
        self.present(detailVC, animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name("UpdateRecentBooks"), object: nil)
    }
    
}


