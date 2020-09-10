//
//  Message.swift
//  ImageFinder
//
//  Created by sung hello on 2020/09/10.
//  Copyright © 2020 sung hello. All rights reserved.
//

import Foundation

class Message: Codable {
    var message: String
    
    init(message: String){
        self.message = message
    }
    
}
