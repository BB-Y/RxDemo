//
//  PullToRefresh.swift
//  RxDemo
//
//  Created by hzx on 2020/11/8.
//  Copyright © 2020 hzx. All rights reserved.
//

import Foundation
import UIKit

class PullToRefreshVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        let viewModel = PullToRefreshViewModel(input: (headerRefresh: tableView.rx.refreshing.asDriver(),
                                                       footerRefresh: tableView.rx.loadMore.asDriver()),
                                               dependency: (disposeBag: disposeBag,
                                                            networkService: NetworkService()))
        viewModel.tableData.asDriver()
            .drive(tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
                cell.textLabel?.text = "\(row+1)、\(element)"
                return cell
        }
        .disposed(by: disposeBag)
                
               
        //上拉刷新状态结束的绑定
        viewModel.endHeaderRefreshing
            .drive(self.tableView.rx.endRefreshing)
            .disposed(by: disposeBag)
        
        viewModel.endFooterRefreshing
        .drive(self.tableView.rx.stopLoadMore)
        .disposed(by: disposeBag)
        
        viewModel.noMoreData
            .drive(tableView.rx.noticeNoMoreData)
            .disposed(by: disposeBag)
        
    }
        
    
}


class PullToRefreshViewModel {
     
    
    //ViewModel Output
    //表格数据序列
    let tableData = BehaviorRelay<[String]>(value: [])
     
    //停止头部刷新状态
    let endHeaderRefreshing: Driver<Bool>
     
    //停止尾部刷新状态
    var endFooterRefreshing: Driver<Bool>
    
    let noMoreData: Driver<Bool>

     
    //ViewModel初始化（根据输入实现对应的输出）
    init(input: (
            headerRefresh: Driver<Void>,
            footerRefresh: Driver<Void> ),
         dependency: (
            disposeBag:DisposeBag,
            networkService: NetworkService )) {
         
        //下拉结果序列
        let headerRefreshData = input.headerRefresh
            .startWith(()) //初始化时会先自动加载一次数据
            .flatMapLatest{ return dependency.networkService.getRandomResults() }
         
        //上拉结果序列
        let footerRefreshData = input.footerRefresh
            .flatMapLatest{ return dependency.networkService.getRandomResults() }
         
        //生成停止头部刷新状态序列
        endHeaderRefreshing = headerRefreshData.map{ _ in true }
         
        //生成停止尾部刷新状态序列
        endFooterRefreshing = footerRefreshData.map{ _ in true }
        
        //设置大于100没有更多
       noMoreData = tableData.map {
            $0.count > 20 ? true : false
                  
       }.asDriver(onErrorJustReturn: true)
        
        //下拉刷新时，直接将查 询到的结果替换原数据
        headerRefreshData.drive(onNext: { items in
            self.tableData.accept(items)
        }).disposed(by: dependency.disposeBag)
         
        //上拉加载时，将查询到的结果拼接到原数据底部
    
        
        footerRefreshData.drive(onNext: { items in
            self.tableData.accept(self.tableData.value + items )
        }).disposed(by: dependency.disposeBag)
        
        
    }
}

extension Reactive where Base: UIScrollView {
  
    var loadMore: ControlEvent<Void> {
        let source: Observable<Void> = Observable.create {
            [weak scrollView = self.base] observer  in
            if let scrollView = scrollView {
                //ES的上拉加载 block 回调触发 rx 的 onNext
                scrollView.es.addInfiniteScrolling {
                    observer.on(.next(()))
                }
            }
            return Disposables.create()
        }
        return ControlEvent(events: source)
    }
    
    var stopLoadMore: Binder<Bool> {
        return Binder(base) { scrollView, isEnd in
            if isEnd {
                scrollView.es.stopLoadingMore()
            }
        }
    }
    var noticeNoMoreData: Binder<Bool> {
           return Binder(base) { scrollView, isEnd in
               if isEnd {
                scrollView.es.stopLoadingMore()
                scrollView.es.noticeNoMoreData()
               }
           }
       }
    
    
   
}
