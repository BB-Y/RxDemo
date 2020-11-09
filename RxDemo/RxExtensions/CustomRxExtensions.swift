//
//  CustomRxExtensions.swift
//  RxDemo
//
//  Created by hzx on 2020/11/8.
//  Copyright © 2020 hzx. All rights reserved.
//

import Foundation
import UIKit
let imgUrl = "https://iknow-pic.cdn.bcebos.com/7c1ed21b0ef41bd5438302c959da81cb39db3d3f"

class CustomRxExtensionsVC: UITableViewController {

    @IBOutlet weak var fontMsg: UILabel!
    @IBOutlet weak var localImage: UIImageView!
    @IBOutlet weak var webImage: UIImageView!
    @IBOutlet weak var fontLabel: UILabel!
    
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.automaticallyAdjustsScrollIndicatorInsets = true
        /**
        fontLabel.font = .systemFont(ofSize: 50)
        webImage.sd_setImage(with: URL(string: imgUrl), completed: nil)
        localImage.image = UIImage(named: "dog")
        */
        let fontSize = Driver<CGFloat>.just(10)
        _ = fontSize.drive(fontLabel.rx.fontSize)
        
        _ = Driver.just((1,100)).drive(fontLabel.rx.randomFontSize())
        
        _ = Driver.just("dog").drive(localImage.rx.imageName)
        _ = Driver.just(imgUrl).drive(webImage.rx.webImage)

        _ = BehaviorRelay<Any>(value: [])
        
//        tableView.es.addPullToRefresh {[unowned self] in
//            _ = Driver.just((1,100)).delay(RxTimeInterval.seconds(1)).drive(self.fontLabel.rx.randomFontSize())
//
//            Driver.just((1,100)).delay(RxTimeInterval.seconds(1)).drive( onCompleted: {
//                self.tableView.es.stopPullToRefresh()
//            })
//        }
        
        //这些逻辑都可以用 viewModel 来 处理
        //下拉刷新绑定网络请求
        let rxFont = tableView.rx.refreshing.asDriver()
            .startWith(())
            .flatMapLatest({ _ in
                //此处可以使用rxMoya返回可观察序列
                NetworkService().getRandomResult()
            })
        
        //拿到网络请求结果后map转换新序列
        let rxFontMsg: Driver<String> = rxFont.map { fontSize in
            return "当前 font = \(fontSize)"
        }
        //拿到网络请求结果后map转换新序列
        let endRefreshing: Driver<Bool> = rxFont.map({ _ in
            return true
        })
        /**----------------------------------------------------------------------------------------------------------*/
        
        /// 在 vc 中绑定事件，若使用 viewModel
        /// viewModel.rxFont.drive(fontLabel.rx.fontSize).disposed(by: disposeBag)

        //rxFont序列绑定到fontLabel的fontSize
        rxFont.drive(fontLabel.rx.fontSize).disposed(by: disposeBag)
        
        //rxFontMsg序列绑定到fontMsg Label的text
        rxFontMsg.drive(fontMsg.rx.text).disposed(by: disposeBag)
        
        //endRefreshing序列绑定到结束下拉刷新
        endRefreshing.drive(tableView.rx.endRefreshing).disposed(by: disposeBag)
    }
}







