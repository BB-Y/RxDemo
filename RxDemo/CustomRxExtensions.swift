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

        BehaviorRelay<Any>(value: [])
        
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
}

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

extension Reactive where Base: ESRefreshComponent {
    //正在刷新事件
    var refreshing: ControlEvent<Void> {
        let source: Observable<Void> = Observable.create {
            [weak control = self.base] observer  in
            if let control = control {
                //ES的下拉刷新 block 回调触发 rx 的 onNext
                control.handler = {
                    observer.on(.next(()))
                }
            }
            return Disposables.create()
        }
        return ControlEvent(events: source)
    }
    
    //停止刷新
    var endRefreshing: Binder<Bool> {
        return Binder(base) { refresh, isEnd in
            if isEnd {
                refresh.stopRefreshing()
            }
        }
    }
}

extension Reactive where Base: UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self.base) { label, fontSize in
            label.font = .systemFont(ofSize: fontSize)
        }
    }
    
    public func randomFontSize() -> Binder<(Int, Int)> {
        return Binder(self.base) { (label,arg1)  in
            
            let (min, max) = arg1
            label.font = .systemFont(ofSize: CGFloat(Int(arc4random()) % max + min))
        }
    }
}

extension Reactive where Base: UIImageView {
    public var imageName: Binder<String> {
        return Binder(self.base) { imageView, imageName in
            imageView.image = UIImage(named: imageName)
        }
    }
    
    public var webImage: Binder<String> {
        return Binder(self.base) { imageView, webImage in
            imageView.sd_setImage(with: URL(string: webImage), completed: nil)
        }
    }
}

