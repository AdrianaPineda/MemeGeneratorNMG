//
//  Router.swift
//  MemeGenerator
//
//  Created by Natasha on 10/28/17.
//  Copyright © 2017 NatashaMartinez. All rights reserved.
//

import Foundation
import Alamofire

enum Router: URLRequestConvertible {
    
    case getMemes()
    case captionImage(_: Parameters)
    
    static let baseURLString = "https://api.imgflip.com"
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        
        switch self {
        case .getMemes:
            return "/get_memes"
        case .captionImage:
            return "/caption_image"
        }
    }
    
    // MARK: URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest {
        
        let url = try Router.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
            
        case .getMemes():
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
            
        case .captionImage(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters);
        }
        return urlRequest
    }
}
