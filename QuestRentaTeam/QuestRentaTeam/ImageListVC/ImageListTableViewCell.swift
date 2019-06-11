//
//  ImageListTableViewCell.swift
//  QuestRentaTeam
//
//  Created by Евгений Бейнар on 11/06/2019.
//  Copyright © 2019 zuk. All rights reserved.
//

import UIKit
import AlamofireImage

final class ImageListTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var imgView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView.af_cancelImageRequest()
    }
    
    public func configureCell(img: Wallpaper) {
        let phImage = UIImage(named: "placeholder")!
        descriptionLabel.text = "width: \(img.width)\nheight: \(img.height)\nsize: \(img.fileSize)"
        imgView.af_setImage(withURL: URL(string: img.urlThumb)!, placeholderImage: phImage)
    }
}
