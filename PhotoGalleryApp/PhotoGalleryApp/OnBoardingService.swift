//
//  OnBoardingService.swift
//  eReturns
//
//  Created by Kapil on 17/10/18.
//  Copyright © 2018 SAP. All rights reserved.
//

import Foundation
import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

typealias HTTPHeader = [String: String]
typealias JSON = [String: Any]



struct OnBoardingService<ResponseType: Codable> {
    
    
    @discardableResult
    static func sendAPIRequest(requestType: RequestType, header: HTTPHeader? = nil, extendedUrl : String? = nil, completionHandler: CompletionHandler<ResponseType>? = nil) -> URLSessionTask {
        
        
        var urlRequest = URLRouter.getURL(for: requestType)
        
        if let value = header {
            for (key, value) in value {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        } 
        
        switch requestType {
        case .imageListUrl:
            if let extendedUrl = extendedUrl{
                let eUrl = urlRequest.url!.absoluteString + extendedUrl
                urlRequest.url = URL(string: eUrl)
            }
            else{
                let eUrl = urlRequest.url!.absoluteString
                urlRequest.url = URL(string: eUrl)
            }
            
//        default:
//            print("defult")
//        }
        
        let dataTask = URLRouter.urlSession.dataTask(with: urlRequest) { (data, response, error) in
            let errorMessage = "Technical Error. Please try again"
            guard error == nil, let responseData = data else {
                completionHandler?(APIResponse.failed(error?.localizedDescription ?? errorMessage, response?.httpStatusCode))
                return
            }
            
            guard response?.isSuccess == true else {
                completionHandler?(APIResponse.failed(error?.localizedDescription ?? errorMessage, response?.httpStatusCode))
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do {
                let responseResult = try jsonDecoder.decode(ResponseType.self, from: responseData)
                completionHandler?(APIResponse<ResponseType>.success(responseResult))
            } catch {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
        return dataTask
    }
    
    
}
}

//extension CodingUserInfoKey {
//
//    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
//}
