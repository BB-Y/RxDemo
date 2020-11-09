//
//  RxMoyaVC.swift
//  RxDemo
//
//  Created by hzx on 2020/11/9.
//  Copyright © 2020 hzx. All rights reserved.
//

import Foundation
//
//  PullToRefresh.swift
//  RxDemo
//
//  Created by hzx on 2020/11/8.
//  Copyright © 2020 hzx. All rights reserved.
//

import Foundation
import UIKit

class RxMoyaVC: UIViewController {


    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "rxCell")
 
        let tableData = tableView.rx.refreshing.asDriver().startWith(()).flatMapLatest {
            () -> Driver<([String])> in
            return SMNetProvider<NumbersAPI>().rxRequest(.randomArray).asDriver()
        }
        let endHeaderRefreshing: Driver<Bool>? = tableData.map { _ in
            return true
        }
        _ = tableData.drive(tableView.rx.items){ (tableView, row, element: String) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "rxCell")!
            cell.textLabel?.text = "\(row+1)、\(element)"
            return cell
        }
       
        endHeaderRefreshing!
            .drive(self.tableView.rx.endRefreshing)
            .disposed(by: disposeBag)
        
     

    }
        
    
}





