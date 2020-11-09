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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "pullCell")
        
        
        let viewModel = PullToRefreshViewModel(input: (headerRefresh: tableView.rx.refreshing.asDriver(),
                                                       footerRefresh: tableView.rx.loadMore.asDriver()),
                                               dependency: (disposeBag: disposeBag,
                                                            networkService: NetworkService()))
        viewModel.tableData!.asDriver()
            .drive(tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "pullCell")!
                cell.textLabel?.text = "\(row+1)、\(element)"
                return cell
        }
        .disposed(by: disposeBag)
                
               
        //上拉刷新状态结束的绑定
        viewModel.endHeaderRefreshing!
            .drive(self.tableView.rx.endRefreshing)
            .disposed(by: disposeBag)
        
        viewModel.endFooterRefreshing!
        .drive(self.tableView.rx.stopLoadMore)
        .disposed(by: disposeBag)
        
        viewModel.hasMore!.asDriver()
            .drive(tableView.rx.noticeNoMoreData)
            .disposed(by: disposeBag)
      
        
    }
        
    
}





