//
//  RecentCollectionViewCell.swift
//  Jinmoon'sLibrary
//
//  Created by 최진문 on 2024/05/08.
//

import UIKit

class RecentCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "RecentCollectionViewCell"
    
    var titleLabel = UILabel()
    var thumbnailImage = UIImageView()
    var stackView = UIStackView()
    var book: Book?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(thumbnailImage)
        contentView.addSubview(stackView)
        
        titleLabel.textAlignment = .center
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(thumbnailImage)
    }
    
    func configureUI(with book: Book) {
            titleLabel.text = book.title
        let urlString = book.thumbnail
        downloadImage(from: urlString)
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
    func setConstraints() {
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
