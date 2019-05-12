//
//  URLRouter.swift
//  eReturns
//
//  Created by Kapil on 17/10/18.
//  Copyright © 2018 SAP. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case post = "POST"
    case put = "PUT"
    case get = "GET"
    case patch = "PATCH"
    
}

enum RequestType: String {
    case imageListUrl = "/services/feeds/photos_public.gne?tags="
    var httpMethod: HTTPMethod {
        switch self {

        case .imageListUrl:
            return .get
        }
    }
}

 struct URLRouter{
    
    static var urlSession: URLSession{
        get {
          return  getUrlSession()
        }
    }
    
   private static func getUrlSession() -> URLSession {
    return  URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
    }
    
    private static let basrUrl = "https://api.flickr.com"
    
    static func getURL(for request : RequestType) -> URLRequest
    {
        var urlString = ""
        switch request {
        case .imageListUrl:
            urlString =  basrUrl + request.rawValue
       
//        default:
//            urlString =  basrUrl + request.rawValue
//        }
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.httpMethod = request.httpMethod.rawValue
        
        return urlRequest
    }
    
    
    
    
}
}
