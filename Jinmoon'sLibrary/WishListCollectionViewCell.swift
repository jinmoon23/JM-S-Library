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
        authorLabel.textAlignment = .center
        priceLabel.textAlignment = .center
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 5
        
        titleLabel.textColor = .black
        priceLabel.textColor = .black
        authorLabel.textColor = .black
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(authorLabel)
        stackView.addArrangedSubview(priceLabel)
        
        contentView.addSubview(stackView)
    }
    
    func configureUI(with book: Book) {
        
        titleLabel.text = book.title
        authorLabel.text = book.authors.joined(separator: ", ")
        priceLabel.text = "\(book.price) 원"
        
    }
    
    func setConstraints() {
        stackView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
        }
    }
}
