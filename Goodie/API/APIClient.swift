//
//  APIService.swift
//  Goodie
//
//  Created by 이창현 on 05/10/2019.
//  Copyright © 2019 이창현. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire


class APIClient {
    let baseURL = "http://222.111.129.177"
    
    func get<T:Codable>(path:String, object:T, completion: ((Result<T>)->Void)?) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        Alamofire.request( "\(self.baseURL)\(path)", method:.get, parameters: nil, encoding:URLEncoding.httpBody, headers:headers )
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success(let data):
                    do {
                        let model : T = try JSONDecoder().decode(T.self, from: data)
                        completion?(.success(model))
                    } catch let error {
                        completion?(.failure(error))
                    }
                case .failure(let error):
                    completion?(.failure(error))
                }
            })
    }
    
}
