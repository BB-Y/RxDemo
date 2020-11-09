//
//  ViewController.swift
//  RxDemo
//
//  Created by hzx on 2020/11/8.
//  Copyright © 2020 hzx. All rights reserved.
//

@_exported import UIKit
@_exported import RxSwift
@_exported import RxMoya
@_exported import Moya
@_exported import RxCocoa
@_exported import SnapKit
@_exported import SDWebImage
@_exported import ESPullToRefresh

class HomeViewController: UIViewController {

    let tableView = UITableView(frame: UIScreen.main.bounds)
    let dataSource: Array<[String: String]> =
        [["观察者": "ObserverVC"],
         ["Rx扩展": "CustomRxExtensionsVC"],
         ["下拉刷新": "PullToRefreshVC"],
         ["RxMoya使用": "RxMoyaVC"]]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "HomeTableViewCell")
        
        let driverData = Driver.just(dataSource)
        _ = driverData.drive(tableView.rx.items(cellIdentifier: "HomeTableViewCell", cellType: HomeTableViewCell.self)) {row,model,cell in
            
            cell.title.text = model.keys.first!
        }
        
        _ = tableView.rx.modelSelected(Dictionary<String, String>.self)
            .subscribe(onNext: { model in
                
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateViewController(identifier: model.values.first!)
                self.navigationController?.pushViewController(vc, animated: true)
        })
        
        
    }


}

class HomeTableViewCell: UITableViewCell {
    
    let title = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

