//
//  ObserverVC.swift
//  RxDemo
//
//  Created by hzx on 2020/11/8.
//  Copyright © 2020 hzx. All rights reserved.
//

import Foundation


class ObserverVC: UIViewController {
    
    @IBOutlet weak var subscribeLabel: UILabel!
    @IBOutlet weak var bindLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var signalLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let obData = Observable.just("1")
        let bindData = Observable.just("2")
        let driveData = Driver.just("3")
        let signalData = Signal.just("4")
        
        //subscribe或bind回调 block 中处理数据,block相当于观察者，data 为被观察者
        _ = obData.subscribe(onNext: { data in
            self.subscribeLabel.text = data
        }).disposed(by: disposeBag)

        //subscribe on block中得到的 event：next(1)
        _ = obData.subscribe { (event) in
            print(event) //1.next(1) 2.completed
            if event.isCompleted {
                
            }
        }
        
        //binder 默认是主线程
        _ = bindData.bind { data in
            self.bindLabel.text = data
        }
        //bindTo 可以直接绑定
        _ = bindData.bind(to: bindLabel.rx.text)
        
        //driver一定在主线程
        _ = driveData.drive(onNext: {data in
            self.driverLabel.text = data
            }).disposed(by: disposeBag)
        
        
        
        //drive<Observer>(_ observer: Observer)直接绑定观察者
        _ = driveData.drive(driverLabel.rx.text)
        
        _ = signalData.emit(to: signalLabel.rx.text)
        
        //Observable序列可以选线程
        _ = Observable<Int>.timer(RxTimeInterval.seconds(0), period: RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
        
        //Driver 和Signal默认在主线程，不需要设置scheduler
        let time = Signal<Int>.timer(RxTimeInterval.seconds(1), period: RxTimeInterval.seconds(2)).map { (time) in
            return "time = \(time)"
        }
        
        _ = time.emit(to: signalLabel.rx.text)
      
        
    }
}
