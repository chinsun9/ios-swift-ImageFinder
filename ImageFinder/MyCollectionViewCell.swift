//
//  MyCollectionViewCell.swift
//  ImageFinder
//
//  Created by sung hello on 2020/09/10.
//  Copyright © 2020 sung hello. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    
    static let identifier = "MyCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    public func configure(with image: UIImage) {
        imageView.image = image
    }


    static func nib() -> UINib{
        return UINib(nibName: MyCollectionViewCell.identifier, bundle: nil)
    }
}
