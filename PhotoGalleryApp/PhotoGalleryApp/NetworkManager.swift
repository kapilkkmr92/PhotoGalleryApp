//
//  NetworkManager.swift
//  eReturns
//
//  Created by Kapil on 17/10/18.
//  Copyright © 2018 SAP. All rights reserved.
//

import Foundation

typealias CompletionHandler<T> = (_ response: APIResponse<T>) -> Void

enum APIResponse<Result> {
    case success(Result?)
    case failed(String, Int?)
}

class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    
    private(set) var defaultSession: URLSession!
    
    private override init() {
        super.init()
        self.defaultSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
    
}

extension NetworkManager : URLSessionDelegate{
    
}


extension URLResponse {
    
    var httpStatusCode: Int? {
        get {
            guard let httpResponse = self as? HTTPURLResponse else {
                return nil
            }
            return httpResponse.statusCode
        }
    }
    
    var isSuccess: Bool {
        get {
            guard let value = self.httpStatusCode else {
                return false
            }
            return value >= 200 && value < 300
        }
    }
    
}
