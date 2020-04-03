//
//  CALayer+XibConfiguration.h
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/11.
//  Copyright © 2020 biaobei. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 设置xibboedorColor的颜色处理
@interface CALayer (XibConfiguration)
@property(nonatomic, assign) UIColor* borderUIColor;

@end

NS_ASSUME_NONNULL_END
