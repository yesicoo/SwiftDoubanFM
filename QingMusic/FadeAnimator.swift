//
//  FadeAnimator.swift
//  QingMusic
//
//  Created by XuQing on 16/1/17.
//  Copyright © 2016年 xuqing. All rights reserved.
//

import UIKit

class FadeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 1.0
    
    // 指定转场动画持续的时间
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    // 实现转场动画的具体内容
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // 得到容器视图
        let containerView = transitionContext.containerView()
        // 目标视图
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        containerView!.addSubview(toView)
        
        // 为目标视图的展现添加动画
        toView.alpha = 0.0
        UIView.animateWithDuration(duration,
            animations: {
                toView.alpha = 1.0
            }, completion: { _ in
                transitionContext.completeTransition(true)
        })
    }
}
