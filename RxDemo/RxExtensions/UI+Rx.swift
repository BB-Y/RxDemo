//
//  UI+Rx.swift
//  RxDemo
//
//  Created by hzx on 2020/11/9.
//  Copyright © 2020 hzx. All rights reserved.
//

import Foundation

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
