//
//  CALayer+XibConfiguration.m
//  DBVoiceEngraverDemo
//
//  Created by linxi on 2020/3/11.
//  Copyright © 2020 biaobei. All rights reserved.
//

#import "CALayer+XibConfiguration.h"

@implementation CALayer (XibConfiguration)

-(void)setBorderUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
    
}

- (UIColor *)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}


@end
