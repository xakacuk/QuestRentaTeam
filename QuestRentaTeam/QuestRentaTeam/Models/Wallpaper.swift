//
//  Wallpaper.swift
//  QuestRentaTeam
//
//  Created by Евгений Бейнар on 11/06/2019.
//  Copyright © 2019 zuk. All rights reserved.
//

struct Wallpapers: Codable {
    let wallpapers: [Wallpaper]
}

struct Wallpaper: Codable {
    var width: String
    var height: String
    var urlImage: String
    var urlThumb: String
    var fileSize: String
}
