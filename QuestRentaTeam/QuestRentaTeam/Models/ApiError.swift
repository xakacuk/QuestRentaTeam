//
//  ApiError.swift
//  QuestRentaTeam
//
//  Created by Евгений Бейнар on 11/06/2019.
//  Copyright © 2019 zuk. All rights reserved.
//

import Foundation

struct ApiStructError: Decodable {
    let success: Bool
    let error: ApiError
}


enum ApiError: String, LocalizedError, Decodable {
    case invalidAuth = "invalid_auth"
    case authMissing = "auth_missing"
    case methodMissing = "method_missing"
    case dbConnect = "db_connect"
    
    var errorDescription: String? {
        switch self {
        case .invalidAuth: return "Invalid auth parameters"
        case .authMissing: return "No authentication key provided"
        case .methodMissing: return "No method name provided"
        case .dbConnect: return "Failed to connect to database"
        }
    }
}
