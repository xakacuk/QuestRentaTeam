//
//  ImageListModel.swift
//  QuestRentaTeam
//
//  Created by Евгений Бейнар on 11/06/2019.
//  Copyright © 2019 zuk. All rights reserved.
//

import Foundation

final class ImageListModel {
    
    private let httpManager = HTTPManager.shared
    private var wallpapers = [Wallpaper]()
    
    func getPopularWallpapers(page: Int, completion: @escaping (Swift.Result<[Wallpaper], Error>) -> Void) {
        self.wallpapers.removeAll()
        httpManager.getPopularWallpapers(page: page) { (result) in
            switch result {
            case .success(let response):
                self.wallpapers = response!.wallpapers
                completion(.success(self.wallpapers))
                break
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }
    }
    
}
