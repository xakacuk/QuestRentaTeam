//
//  HTTPManager.swift
//  QuestRentaTeam
//
//  Created by Евгений Бейнар on 11/06/2019.
//  Copyright © 2019 zuk. All rights reserved.
//

import Foundation
import Alamofire

final class HTTPManager {
    
    static let shared = HTTPManager()
    
    public typealias Parameters = [String: Any]
    
    struct Const {
        static let url = "https://wall.alphacoders.com/api2.0/get.php"
    }
    
    struct Config {
        static let timeout: TimeInterval = 15.0
        static let key = "c49a821fa3b780caac2fe00d74be5dd2"
    }
    
    lazy var networkSessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = Config.timeout
        configuration.timeoutIntervalForRequest = Config.timeout
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        return sessionManager
    }()
    
    func getPopularWallpapers(page: Int, completionHandler: @escaping (Swift.Result<Wallpapers?, Error>) -> Void) {
        
        let params: Parameters = [
            "auth": Config.key,
            "method": "popular",
            "page": page,
            "check_last": 1
        ]
        
        networkSessionManager.request(Const.url, method: .get, parameters: params).response { response in
            
            if let error = response.error {
                //timeout error, code 400...
                completionHandler(.failure(error))
                return
            }
            
            guard let data = response.data else {
                assertionFailure()
                return
            }
            
            if let rawString = String(bytes: data, encoding: .utf8) {
                print(rawString)
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let wallpapers = try decoder.decode(Wallpapers.self, from: data)
                completionHandler(.success(wallpapers))
            } catch {
                // data parsing error
                if let apiError = try? decoder.decode(ApiStructError.self, from: data) {
                    completionHandler(.failure(apiError.error))
                } else {
                    completionHandler(.failure(error))
                }
            }
        }
    }
}
