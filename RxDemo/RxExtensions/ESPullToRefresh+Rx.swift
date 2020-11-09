//
//  ESPullToRefresh+Rx.swift
//  RxDemo
//
//  Created by hzx on 2020/11/9.
//  Copyright © 2020 hzx. All rights reserved.
//

import Foundation

/// 下拉扩展
extension Reactive where Base: UIScrollView {
  
    var refreshing: ControlEvent<Void> {
        let source: Observable<Void> = Observable.create {
            [weak scrollView = self.base] observer  in
            if let scrollView = scrollView {
                //ES的下拉刷新 block 回调触发 rx 的 onNext
                scrollView.es.addPullToRefresh {
                    observer.on(.next(()))
                }
            }
            return Disposables.create()
        }
        return ControlEvent(events: source)
    }
    var endRefreshing: Binder<Bool> {
        return Binder(base) { scrollView, isEnd in
            if isEnd {
                scrollView.es.stopPullToRefresh(ignoreDate: false, ignoreFooter: false)
            }
        }
    }
}

/// 上拉扩展
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
        return Binder(base) { scrollView, hasMore in
            if hasMore {
                scrollView.es.stopLoadingMore()
            }
        }
    }
    var noticeNoMoreData: Binder<Bool> {
           return Binder(base) { scrollView, hasMore in
               if !hasMore {
                scrollView.es.stopPullToRefresh()
                scrollView.es.noticeNoMoreData()
               }
           }
       }
    
    
   
}
