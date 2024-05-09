//
//  DetailViewController.swift
//  Jinmoon'sLibrary
//
//  Created by 최진문 on 2024/05/02.
//

import UIKit
import SnapKit
import CoreData


class DetailViewController: UIViewController {

    var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setConstraints()
        loadData()
    }
    
    var book: Book?
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let backView = UIView()
    let titleLabel = UILabel()
    let authorLabel = UILabel()
    let thumbnailImage = UIImageView()
    let priceLabel = UILabel()
    let contentLabel = UILabel()
    
    let cancelButton = UIButton()
    let cartButton = UIButton()
    let buttonStackView = UIStackView()
    
    
    func configureUI() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        view.addSubview(buttonStackView)
        scrollView.addSubview(contentView)
    
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(thumbnailImage)
        contentView.addSubview(priceLabel)
        contentView.addSubview(contentLabel)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        priceLabel.font = UIFont.boldSystemFont(ofSize: 20)
        thumbnailImage.contentMode = .scaleAspectFit
        contentLabel.numberOfLines = 100
        
        cancelButton.setTitle("X", for: .normal)
        cancelButton.backgroundColor = .systemGray4
        cancelButton.layer.cornerRadius = 10
        cancelButton.clipsToBounds = true
        cancelButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        
        cartButton.setTitle("담기", for: .normal)
        cartButton.backgroundColor = .systemMint
        cartButton.layer.cornerRadius = 10
        cartButton.clipsToBounds = true
        cartButton.addTarget(self, action: #selector(addWishList), for: .touchUpInside)
        
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fill
        buttonStackView.alignment = .fill
        buttonStackView.spacing = 10
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(cartButton)
    }
    @objc func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func addWishList() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let bookEntity = NSEntityDescription.entity(forEntityName: "BookData", in: context)!
        let book = NSManagedObject(entity: bookEntity, insertInto: context)
        
        book.setValue(titleLabel.text, forKey: "title")
        if let authorText = authorLabel.text {
            let authors = authorText.components(separatedBy: ", ").joined(separator: ";") // 배열을 문자열로 변환
            book.setValue(authors, forKey: "authors")
        }
        if let priceText = priceLabel.text?.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression, range: nil),
               let price = Double(priceText) {
                book.setValue(Int64(price), forKey: "price") // Double을 Int64로 변환
            } else {
                book.setValue(Int64(0), forKey: "price") // 변환 실패 시 0으로 설정
            }
        
        do {
            try context.save()
            // 저장 성공 후 알림 표시
            let alertController = UIAlertController(title: "담기 완료", message: "\(titleLabel.text ?? "책") 담기가 완료되었습니다!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                // 확인 버튼을 누르면 화면을 닫음
                self?.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            // 저장 실패 시 알림 표시
            let alertController = UIAlertController(title: "실패", message: "저장에 실패했습니다. 다시 시도해주세요.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func setConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(buttonStackView.snp.top).offset(4)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
            make.height.equalTo(800)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        authorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        thumbnailImage.snp.makeConstraints { make in
            make.top.equalTo(authorLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        priceLabel.snp.makeConstraints {make in
            make.top.equalTo(thumbnailImage.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalTo(contentView.snp.bottom).offset(-20)
        }
        buttonStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
        cancelButton.snp.makeConstraints { make in
            make.width.equalTo(cartButton.snp.width).multipliedBy(0.5)
            make.height.equalTo(50)
        }
        cartButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    func loadData() {
        if let book = book {
            titleLabel.text = book.title
            authorLabel.text = book.authors.joined(separator: ", ")
            priceLabel.text = "<\(formatPrice(value: book.price))원>"
            contentLabel.text = book.contents
        }
        let urlString = book?.thumbnail
        downloadImage(from: urlString!)
    }
    
    func formatPrice(value: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal  // 숫자 스타일을 'decimal'로 설정합니다.
        numberFormatter.groupingSeparator = "," // 구분자로 콤마 사용
        numberFormatter.groupingSize = 3        // 세 자리수마다 구분자 적용

        return numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            // 에러 처리
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }
            
            // HTTP 상태 코드 확인
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error: Invalid response")
                return
            }
            
            // 데이터 유효성 확인 및 이미지 생성
            guard let data = data, let image = UIImage(data: data) else {
                print("Error: No image data")
                return
            }
            
            // 메인 스레드에서 이미지 뷰 업데이트
            DispatchQueue.main.async {
                self.thumbnailImage.image = image
                //                self.updateImageViewSize(to: image.size)
            }
        }.resume()
    }
    
}
