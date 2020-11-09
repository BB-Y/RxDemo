//
//  PullToRefreshViewModel.swift
//  RxDemo
//
//  Created by hzx on 2020/11/9.
//  Copyright © 2020 hzx. All rights reserved.
//

import Foundation

class PullToRefreshViewModel {
     
    
    //ViewModel Output
    //表格数据序列
    let tableData: BehaviorRelay<[String]>? = BehaviorRelay<[String]>(value: [])
     
    //停止头部刷新状态
    let endHeaderRefreshing: Driver<Bool>?
     
    //停止尾部刷新状态
    var endFooterRefreshing: Driver<Bool>?
    
    let hasMore: BehaviorRelay<Bool>? = BehaviorRelay<Bool>(value: true)

    //let page = BehaviorRelay<Int>(value: 0)
    static var page = 0
    
     
    //ViewModel初始化（根据输入实现对应的输出）
    init(input: (
            headerRefresh: Driver<Void>,
            footerRefresh: Driver<Void> ),
         dependency: (
            disposeBag:DisposeBag,
            networkService: NetworkService )) {
        
        //上拉结果 返回数据和是否还有更多
               let footerRefreshData = input.footerRefresh.flatMapLatest{() -> Driver<([String], Bool)> in
                   PullToRefreshViewModel.page += 1
                   return dependency.networkService.getRandomResults(page: PullToRefreshViewModel.page)
               }
               //生成停止尾部刷新状态序列
               endFooterRefreshing = footerRefreshData.map{  (items, hasMore) in return hasMore }
         
        //下拉结果序列
        let headerRefreshData = input.headerRefresh.startWith(()).flatMapLatest { () -> Driver<([String], Bool)> in
            PullToRefreshViewModel.page = 0
            return dependency.networkService.getRandomResults(page: PullToRefreshViewModel.page)
                
        }
         //生成停止头部刷新状态序列
         endHeaderRefreshing = headerRefreshData.map{ (items, hasMore) in
            return hasMore
            
        }

        //下拉刷新时，直接将查 询到的结果替换原数据
        headerRefreshData.drive(onNext: { (items, hasMore) in
            self.tableData!.accept(items)
            self.hasMore!.accept(hasMore)
        }).disposed(by: dependency.disposeBag)
         
        //上拉加载时，将查询到的结果拼接到原数据底部
        footerRefreshData.drive(onNext: { (items, hasMore) in
            self.tableData!.accept(self.tableData!.value + items )
            self.hasMore!.accept(hasMore)
        }).disposed(by: dependency.disposeBag)
        
    }
}
