//
//  WishListViewController.swift
//  Jinmoon'sLibrary
//
//  Created by 최진문 on 2024/05/02.
//

import UIKit
import SnapKit
import CoreData

class WishListViewController: UIViewController {
    
    var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setConstraints()
        loadBooks()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBooks() // 데이터를 뷰가 나타날 때마다 새로고침
    }
    
    var books: [Book] = []
   
    
    let flowLayout: UICollectionViewFlowLayout = {
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
    
    var listLabel = UILabel()
    var removeAllButton = UIButton(type: .system)
    var addButton = UIButton(type: .system)
    var stackView = UIStackView()
    
    lazy var listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    
    func configureUI() {
        view.addSubview(listLabel)
        view.addSubview(removeAllButton)
        view.addSubview(addButton)
        view.addSubview(stackView)
        view.addSubview(listCollectionView)
        
        listLabel.text = "담은 책"
        listLabel.font = UIFont.boldSystemFont(ofSize: 15)
        listLabel.textAlignment = .center
        
        removeAllButton.setTitle("전체삭제", for: .normal)
        removeAllButton.addTarget(self, action: #selector(removeAllList), for: .touchUpInside)
        addButton.setTitle("추가하기", for: .normal)
        addButton.addTarget(self, action: #selector(moveToSearch), for: .touchUpInside)
        
        listCollectionView.backgroundColor = .white
        
        stackView.addArrangedSubview(removeAllButton)
        stackView.addArrangedSubview(listLabel)
        stackView.addArrangedSubview(addButton)
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 5
        
        listCollectionView.dataSource = self
        listCollectionView.delegate = self
        listCollectionView.register(WishListCollectionViewCell.self, forCellWithReuseIdentifier: WishListCollectionViewCell.identifier)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
           listCollectionView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func moveToSearch() {
        guard let tabBarController = self.tabBarController else { return }
                tabBarController.selectedIndex = 0  // 1번째 탭(인덱스 0)으로 전환
    }
    
    @objc func removeAllList() {
        let alertController = UIAlertController(title: "담은 책을 모두 삭제합니다", message: "정말 담은 모든 책을 삭제하시겠어요?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
                self?.deleteAllItems()
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)

            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)

            present(alertController, animated: true, completion: nil)
    }
    
    func deleteAllItems() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BookData")

        do {
            let results = try context.fetch(fetchRequest)
            for bookToDelete in results {
                context.delete(bookToDelete)
            }
            try context.save()
            books.removeAll()  // 데이터 소스 배열을 비웁니다.
            listCollectionView.reloadData()  // 컬렉션 뷰를 업데이트합니다.
        } catch let error as NSError {
            print("Failed to delete all books: \(error), \(error.userInfo)")
        }
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: listCollectionView)
        guard let indexPath = listCollectionView.indexPathForItem(at: point) else {
            return
        }

        if gesture.state == .began {
            presentDeletionAlert(for: indexPath)
        }
    }
    
    func presentDeletionAlert(for indexPath: IndexPath) {
        let alertController = UIAlertController(title: "담은 책을 삭제합니다", message: "정말 삭제 하시겠어요?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.deleteItem(at: indexPath)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    func deleteItem(at indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let bookToDelete = books[indexPath.row]

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BookData")
        fetchRequest.predicate = NSPredicate(format: "title == %@", bookToDelete.title)

        do {
            let results = try context.fetch(fetchRequest)
            if let bookToDelete = results.first {
                context.delete(bookToDelete)
                try context.save()
                books.remove(at: indexPath.row)
                listCollectionView.deleteItems(at: [indexPath])
            }
        } catch let error as NSError {
            print("Failed to delete book: \(error), \(error.userInfo)")
        }
    }
    
    func setConstraints() {
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(10)
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        listCollectionView.snp.makeConstraints {make in
            make.horizontalEdges.equalToSuperview().inset(10)
            make.top.equalTo(stackView.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-50)
        }
    }
    func loadBooks() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BookData")
        
        do {
            let bookDataObjects = try context.fetch(fetchRequest) as! [BookData]
            books = bookDataObjects.map { bookData in
                // authors 속성을 올바르게 변환하기 (예시는 문자열을 배열로 가정)
                let authorsArray = bookData.authors?.components(separatedBy: ";") ?? []
                // 더미 값 또는 기본값 사용
                return Book(
                    title: bookData.title ?? "",
                    contents: "",  // 필요하지 않은 데이터는 빈 문자열 또는 기본값으로 처리
                    url: "",
                    authors: authorsArray,
                    price: Int(bookData.price),
                    thumbnail: ""
                )
            }
            listCollectionView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

extension WishListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WishListCollectionViewCell.identifier, for: indexPath) as? WishListCollectionViewCell else {return UICollectionViewCell()}
        let book = books[indexPath.row]
        cell.configureUI(with: book)
        return cell
    }
}
