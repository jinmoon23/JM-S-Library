//
//  WishListCollectionViewCell.swift
//  Jinmoon'sLibrary
//
//  Created by 최진문 on 2024/05/07.
//

import UIKit
import SnapKit

class WishListCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "WishListCollectionViewCell"
    
    var titleLabel = UILabel()
    var authorLabel = UILabel()
    var priceLabel = UILabel()
    var stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstraints()
        setupBorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupBorder() {
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.black.cgColor
    }
    func setupViews() {
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 3
        authorLabel.textAlignment = .center
        authorLabel.numberOfLines = 3
        priceLabel.textAlignment = .right
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 5
        
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(authorLabel)
        stackView.addArrangedSubview(priceLabel)
        
        contentView.addSubview(stackView)
    }
    
    func configureUI(with book: Book) {
        
        titleLabel.text = book.title
        authorLabel.text = book.authors.joined(separator: ", ")
        priceLabel.text = "\(formatPrice(value: book.price))원"
        
    }
    func formatPrice(value: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal  // 숫자 스타일을 'decimal'로 설정합니다.
        numberFormatter.groupingSeparator = "," // 구분자로 콤마 사용
        numberFormatter.groupingSize = 3        // 세 자리수마다 구분자 적용

        return numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    func setConstraints() {
        stackView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView.snp.leading).inset(10)
        }
        priceLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentView.snp.trailing).inset(10)
        }
    }
}
