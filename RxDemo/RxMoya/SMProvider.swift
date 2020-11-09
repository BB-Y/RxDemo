//
//  SMProvider.swift
//  RxDemo
//
//  Created by hzx on 2020/11/9.
//  Copyright © 2020 hzx. All rights reserved.
//

import Foundation
import Moya
import RxSwift


typealias SMSuccessDicData<M> = ((_ result: M) -> Void)
typealias SMFailure = ((_ result: Error) -> Void)
typealias SMSuccessNullData = ((_ result: Bool) -> Void)
typealias SMSuccessArrayData<M> = ((_ result: [M]) -> Void)

class SMNetProvider<T: TargetType>: MoyaProvider<T> {
    
    let disposeBag = DisposeBag()
    
    final class func customEndpointClosure(for target: T) -> Endpoint {
        //URL拼接处理
        let url = target.baseURL.appendingPathComponent( target.path).absoluteString
        
        let errorData = EndpointSampleResponse.networkError(NSError(domain: "", code: -1, userInfo: ["msg" : "this is a error"]))
        let response = EndpointSampleResponse.networkResponse(200, target.sampleData)
        let endpoint: Endpoint = Endpoint(url: url, sampleResponseClosure: {errorData}, method: target.method, task: target.task, httpHeaderFields: target.headers)
        

        
        return endpoint
    }
    
    //session配置
    final class func defaultSMSession() -> Session {
        let configuration = URLSessionConfiguration.default
        //此处header应该是一些通用配置
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 10
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return Session(configuration: configuration, startRequestsImmediately: false)
    }
    
    //初始化时，设置自定义Provider
    override init(endpointClosure: @escaping MoyaProvider<T>.EndpointClosure = customEndpointClosure,
                  requestClosure: @escaping MoyaProvider<T>.RequestClosure = MoyaProvider<T>.defaultRequestMapping,
                  stubClosure: @escaping MoyaProvider<T>.StubClosure = MoyaProvider.delayedStub(3),
                  callbackQueue: DispatchQueue? = nil,
                  session: Session = defaultSMSession(),
                  plugins: [PluginType] = [SMErrorPlugin()],
                  trackInflights: Bool = false) {
        
        
        
        
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: callbackQueue, session: session, plugins: plugins, trackInflights: trackInflights)
        
    }
    
    
    
    //返回RX序列，
    func rxRequest<M>(_ target: T,
                                   callbackQueue: DispatchQueue? = .none,
                                   progress: Moya.ProgressBlock? = .none) -> Driver<[M]>{
        
        
        let result = self.rx.request(target, callbackQueue: callbackQueue)
            //.asDriver(onErrorJustReturn: Response(statusCode: 404, data: "".data(using: .utf8)!))
        
        //var res = BehaviorRelay<Moya.Response>(value: Moya.Response(statusCode: 0, data: "[]".data(using: .utf8)!))
        let res = BehaviorRelay<Moya.Response>(value: Moya.Response(statusCode: 0, data: "[]".data(using: .utf8)!))
        result.subscribe { (response) in
            res.accept(response)
        } onError: { (error) in
            //res.accept(res.value)
            //res.replay(1)
        }
//        let driveRes = res.asDriver { _ in
//            return Moya.Response(statusCode: 0, data: "[]".data(using: .utf8)!)
//        }
        let driveRes = res.asDriver()
        let m = driveRes.map { (response) -> [M] in
            return try! response.mapJSON() as! [M]
        }

        return m
    }
}







