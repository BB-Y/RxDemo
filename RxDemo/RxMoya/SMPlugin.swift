//
//  SMPlugin.swift
//  RxDemo
//
//  Created by hzx on 2020/11/9.
//  Copyright © 2020 hzx. All rights reserved.
//

import Foundation
final class SMErrorPlugin: PluginType {
    
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        let error = NSError(domain: "", code: -1, userInfo: ["msg" : "this is a error"])
        let result = Moya.Response(statusCode: 200, data: target.sampleData)
        let moyaError = MoyaError.underlying(error, nil)
        
        
        if arc4random() % 2 > 0 {
            return Result.success(result)
        } else {
            return Result.failure(moyaError)
        }
        
        

    }
}
