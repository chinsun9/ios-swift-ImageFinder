//
//  APIRequest.swift
//  ImageFinder
//
//  Created by sung hello on 2020/09/10.
//  Copyright © 2020 sung hello. All rights reserved.
//

import Foundation

enum APIError: Error {
    case responseProblem
    case decodingProblem
    case otherProblem
}

struct APIResquest {
    let resourceString: String
    
    init(){
        self.resourceString = "https://dapi.kakao.com/v2/search/image"
        
    }
    
    func sendRequest(_ searchOption: SearchOption, completion: @escaping (NSDictionary?, Error?) -> Void) {
        
        let query = searchOption.query
        let size = String(searchOption.size)
        let page = String(searchOption.page)
        let sort = searchOption.sort
        
        var url = URLComponents(string: self.resourceString)!
        
        url.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "size", value: size),
            URLQueryItem(name: "page", value: page),
            URLQueryItem(name: "sort", value: sort)
        ]

        url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        print(url)
        
        var request = URLRequest(url: url.url!)
        request.httpMethod = "GET"
        
        request.addValue(Secret.api_key, forHTTPHeaderField: "Authorization")
        

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                            // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                error == nil else {                           // was there no error, otherwise ...
                    completion(nil, error)
                    return
            }

            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? NSDictionary
            completion(responseObject, nil)
        }
        task.resume()
    }
}
