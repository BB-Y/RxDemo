//
//  NetworkService.swift
//  RxDemo
//
//  Created by hzx on 2020/11/9.
//  Copyright © 2020 hzx. All rights reserved.
//

import Foundation

//模拟网络请求
class NetworkService {
    func getRandomResult() -> Driver<CGFloat> {
        print("正在请求数据......")
        let items = CGFloat(Int(arc4random()) % 50 + 10)
        return Driver.just(items).delay(.seconds(2))
    }
    
    func getRandomResults() -> Driver<[String]> {
          print("正在请求数据......")
                 let items = (0 ..< 20).map {_ in
                     "随机数据\(Int(arc4random()))"
                 }
                 let observable = Observable.just(items)
                 return observable
                    .delay(.seconds(2), scheduler: MainScheduler.instance)
                     .asDriver(onErrorDriveWith: Driver.empty())
      }
    func getRandomResults(page: Int) -> Driver<([String], Bool)> {
        print("正在请求数据......")
               let items = (0 ..< 20).map {_ in
                   "随机数据\(Int(arc4random()))"
               }
        let hasMore: Bool
        if page > 0 {
            hasMore = false
        } else {
            hasMore = true
        }
       let observable = Observable.just((items, hasMore))
       return observable
          .delay(.seconds(2), scheduler: MainScheduler.instance)
           .asDriver(onErrorDriveWith: Driver.empty())
    }
}
