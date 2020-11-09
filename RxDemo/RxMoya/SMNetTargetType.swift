//
//  SMNetTargetType.swift
//  SevenMinApp
//
//  Created by hzx on 2020/11/2.
//  Copyright © 2020 柴进. All rights reserved.
//

import Foundation
import Moya



enum NumbersAPI {
    case randomArrayWithPage(page: Int)
    case randomArray

}


//TargetType原有属性设置默认值
extension NumbersAPI: TargetType {
    var path: String {
        return "123"
    }
    
    var baseURL: URL {
        return URL(string: "abc")!
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var sampleData: Data {
        switch self {
        case let .randomArrayWithPage(page):
            let hasMore: Bool = page > 0 ? false : true
            let data : Data! = try? JSONSerialization.data(withJSONObject: Array.randomArray(), options: []) as Data?
            return data
        case .randomArray:
            let data : Data! = try? JSONSerialization.data(withJSONObject: Array.randomArray(), options: []) as Data?
            return data
        }
        //return "{}".data(using: String.Encoding.utf8)!
    }
    
    var headers: [String : String]? {
        return nil
    }
}

extension Array where Element == String {
    static func randomArray() -> Array<String> {
        let items = (0 ..< 20).map {_ in
            "随机数据\(Int(arc4random()))"
        }
        return items
    }
}







