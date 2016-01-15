//
//  ViewController.m
//  SunShadowColock
//
//  Created by lihongfeng on 16/1/12.
//  Copyright © 2016年 wanglei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIView *clockView;
@property (nonatomic, strong) UIView *pinView;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@end

@implementation ViewController

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSLog(@"---short int---%lu", sizeof(short int));
//    NSLog(@"---int---%lu", sizeof(int));
//    NSLog(@"---long int---%lu", sizeof(long int));
//    NSLog(@"---float---%lu", sizeof(float));
//    NSLog(@"---char---%lu", sizeof(char));
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat size = 150;
    //日晷
    [self addColockWithSize:size];
    
    //日晷指针
    UIView *pinView = [self creatPinWithFrame:CGRectMake(0, 0, 160, 20)];
    pinView.backgroundColor = [UIColor clearColor];
    pinView.alpha = 0.5;
    pinView.center = CGPointMake(self.clockView.center.x + pinView.bounds.size.width/2-pinView.bounds.size.height/2,
                                 self.clockView.center.y);
    [self.view addSubview:pinView];
    //改变 anchorPoint, 用于旋转
    pinView.layer.position = CGPointMake(pinView.frame.origin.x + pinView.bounds.size.height/2.0f,
                                         pinView.frame.origin.y + pinView.bounds.size.height/2.0f);
    pinView.layer.anchorPoint = CGPointMake(pinView.bounds.size.height/2.0f/pinView.bounds.size.width, 0.5);
    self.pinView = pinView;
    
    //time label
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2-186/2.0, 50, self.view.bounds.size.width, 50)];
    timeLabel.backgroundColor = [UIColor blackColor];
    timeLabel.font = [UIFont systemFontOfSize:50];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    NSString *timeStr = [formatter stringFromDate:date];
    timeLabel.text = timeStr;
    timeLabel.textColor = [UIColor grayColor];
    
    self.timeLabel = timeLabel;
    [self.view addSubview:self.timeLabel];
    
    
    CADisplayLink *link =  [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshTime)];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    //设置指针初始偏移角度
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    f.dateFormat = @"HH:mm:ss";
    NSString *str = [f stringFromDate:currentDate];
    self.timeInterval = [self countTimeIntervalWithCurrentTime:str];
    
    CGFloat temAngle = (360.0/86400)*self.timeInterval;
    self.pinView.transform = CGAffineTransformMakeRotation(M_PI/180*temAngle - M_PI/180*90);
    
}

-(void)refreshTime{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm:ss";
        NSString *timeStr = [formatter stringFromDate:date];
        self.timeLabel.text = timeStr;
        
        //计算时间差
        self.timeInterval = [self countTimeIntervalWithCurrentTime:timeStr];
        CGFloat temAngle = (360.0/86400)*self.timeInterval;
        self.pinView.transform = CGAffineTransformMakeRotation(M_PI/180*temAngle - M_PI/180*90);
        
    });
    
}

//计算时间差
-(NSTimeInterval)countTimeIntervalWithCurrentTime:(NSString *)timeStr{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    
    NSString *zeroTime = @"00:00:00";
    NSDate *zeroDate = [formatter dateFromString:zeroTime];
    NSDate *currentDate = [formatter dateFromString:timeStr];
    
    NSTimeInterval interval = [currentDate timeIntervalSinceDate:zeroDate];
    return interval;
    
}

-(void)addColockWithSize:(CGFloat)size{
    UIView *clockView = [[UIView alloc] init];
    clockView.bounds = CGRectMake(0, 0, size, size);
    clockView.center = self.view.center;
    self.clockView = clockView;
    [self.view addSubview:self.clockView];
    
    CGPoint circleCenter = CGPointMake(clockView.bounds.size.width/2, clockView.bounds.size.height/2);
    
    //circle1
    CGFloat circle1_radius = clockView.bounds.size.width;
    CGFloat circle1_lineWidth = 1;
    CAShapeLayer *circle1 = [self drawCircleWithSize:circle1_radius*2
                                              center:circleCenter
                                           lineWidth:circle1_lineWidth
                                           lineColor:[UIColor whiteColor]
                                           fillColor:[UIColor clearColor]];
    [self.clockView.layer addSublayer:circle1];
    
    //pin circle1
    CGRect pinCircle1_bounds = CGRectMake(0, 0, circle1_radius/15, 1);
    CGFloat pinCircle1_radius = circle1_radius-circle1_lineWidth;
    CGFloat pinCircle1_count = 48.0*2;
    [self drawPinCircleWithCenter:circleCenter pinBounds:pinCircle1_bounds radius:pinCircle1_radius pinCount:pinCircle1_count];
    
    //circle2
    CGFloat circle2_radius = pinCircle1_radius-pinCircle1_bounds.size.width;
    CGFloat circle2_lineWidth = 1;
    CAShapeLayer *circle2 = [self drawCircleWithSize:circle2_radius*2
                                              center:circleCenter
                                           lineWidth:circle2_lineWidth
                                           lineColor:[UIColor whiteColor]
                                           fillColor:[UIColor clearColor]];
    [self.clockView.layer addSublayer:circle2];
    
    //pin circle2
    CGRect pinCircle2_bounds = CGRectMake(0, 0, circle1_radius/15*2, 1);
    CGFloat pinCircle2_radius = circle2_radius-circle2_lineWidth;
    CGFloat pinCircle2_count = 24.0;
    [self drawPinCircleWithCenter:circleCenter pinBounds:pinCircle2_bounds radius:pinCircle2_radius pinCount:pinCircle2_count];
    
    //circle3
    CGFloat circle3_radius = pinCircle2_radius-pinCircle2_bounds.size.width;
    CGFloat circle3_lineWidth = 1;
    CAShapeLayer *circle3 = [self drawCircleWithSize:circle3_radius*2
                                              center:circleCenter
                                           lineWidth:circle3_lineWidth
                                           lineColor:[UIColor whiteColor]
                                           fillColor:[UIColor clearColor]];
    [self.clockView.layer addSublayer:circle3];
    
    //pin circle3
    CGRect pinCircle3_bounds = CGRectMake(0, 0, circle1_radius/15*4, 1);
    CGFloat pinCircle3_radius = circle3_radius-circle3_lineWidth;
    CGFloat pinCircle3_count = 12.0;
    [self drawPinCircleWithCenter:circleCenter pinBounds:pinCircle3_bounds radius:pinCircle3_radius pinCount:pinCircle3_count];
    
    //circle4
    CGFloat circle4_radius = pinCircle3_radius-pinCircle3_bounds.size.width;
    CGFloat circle4_lineWidth = 1;
    CAShapeLayer *circle4 = [self drawCircleWithSize:circle4_radius*2
                                              center:circleCenter
                                           lineWidth:circle4_lineWidth
                                           lineColor:[UIColor whiteColor]
                                           fillColor:[UIColor clearColor]];
    [self.clockView.layer addSublayer:circle4];
    
    //十二地支
    NSArray *array = @[@"子", @"丑", @"寅", @"卯", @"辰", @"巳", @"午", @"未", @"申", @"酉", @"戌", @"亥"];
    CGFloat angle = M_PI/180*(360/24.0);
    for (int i = 0; i < 24; i++) {
        if (i%2 != 0) {
            NSString *text = array[(i-1)/2];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            label.text = text;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:25];
            label.center = CGPointMake(circleCenter.x + (pinCircle3_radius-pinCircle3_bounds.size.width/2)*cosf(angle*i),
                                       circleCenter.y + (pinCircle3_radius-pinCircle3_bounds.size.width/2)*sinf(angle*i));
            label.textAlignment = NSTextAlignmentCenter;
            label.transform = CGAffineTransformMakeRotation(-M_PI/180*90 + angle*i);
            label.backgroundColor = [UIColor clearColor];
            [self.clockView addSubview:label];
        }
    }
    
    // "初", "正"
    CGFloat angle2 = M_PI/180*(360/48.0);
    int j = 0;
    for (int i = 0; i < 48; i++) {
        if (i%2 != 0) {
            NSString *text;
            if (j == 0) {
                text = @"初";
                j = 1;
            }else{
                text = @"正";
                j = 0;
            }
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            label.text = text;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:14];
            label.center = CGPointMake(circleCenter.x + (pinCircle2_radius-pinCircle2_bounds.size.width/2)*cosf(angle2*i),
                                       circleCenter.y + (pinCircle2_radius-pinCircle2_bounds.size.width/2)*sinf(angle2*i));
            label.textAlignment = NSTextAlignmentCenter;
            label.transform = CGAffineTransformMakeRotation(-M_PI/180*90 + angle2*i);
            label.backgroundColor = [UIColor clearColor];
            label.alpha = 0.8;
            [self.clockView addSubview:label];
        }
    }
    
    self.clockView.transform = CGAffineTransformMakeRotation(-M_PI/180*(90+15));
}

-(UIView *)creatPinWithFrame:(CGRect)frame{
    
    UIView *pinView = [[UIView alloc] initWithFrame:frame];
    pinView.backgroundColor = [UIColor clearColor];
    
    CGFloat radius = frame.size.height/2.0f;
    
    //画三角形
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.bounds = pinView.bounds;
    layer.position = CGPointMake(pinView.bounds.size.width/2.0f, pinView.bounds.size.height/2.0f);
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(radius, 0)];
    [path addLineToPoint:CGPointMake(radius, radius*2)];
    [path addLineToPoint:CGPointMake(layer.bounds.size.width, radius)];
    [path closePath];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor greenColor].CGColor;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    
    //画圆
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    UIBezierPath *circlepath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, radius*2, radius*2)];
    circleLayer.path = circlepath.CGPath;
    circleLayer.fillColor = [UIColor brownColor].CGColor;
    circleLayer.backgroundColor = [UIColor clearColor].CGColor;
    circleLayer.frame = CGRectMake(layer.frame.origin.x, layer.frame.origin.y, radius*2, radius*2);
    
    //画点
    CAShapeLayer *pointCircle = [[CAShapeLayer layer] init];
    pointCircle.bounds = CGRectMake(0, 0, 2, 2);
    pointCircle.position = CGPointMake(radius, radius);
    UIBezierPath *pointCirclePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 2, 2)];
    pointCircle.path = pointCirclePath.CGPath;
    pointCircle.fillColor = [UIColor greenColor].CGColor;
    pointCircle.backgroundColor = [UIColor clearColor].CGColor;
    
    [pinView.layer addSublayer:layer];
    [pinView.layer addSublayer:circleLayer];
    [pinView.layer addSublayer:pointCircle];
    
    return pinView;
}

-(CAShapeLayer *)drawCircleWithSize:(CGFloat)size
                             center:(CGPoint)center
                          lineWidth:(CGFloat)lineWidth
                          lineColor:(UIColor *)lineColor
                          fillColor:(UIColor *)fillColor{
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.bounds = CGRectMake(0, 0, size, size);
    layer.position = center;
    CGRect rect = CGRectMake(lineWidth/2, lineWidth/2, size-lineWidth, size-lineWidth);
    layer.path = [UIBezierPath bezierPathWithOvalInRect:rect].CGPath;
    layer.lineWidth = lineWidth;
    layer.strokeColor = lineColor.CGColor;
    layer.fillColor = fillColor.CGColor;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    return layer;
}

-(void)drawPinCircleWithCenter:(CGPoint)center
                     pinBounds:(CGRect)bounds
                        radius:(CGFloat)radius
                      pinCount:(CGFloat)count{
    
    CGFloat angle = M_PI/180*(360/count);
    for (int i = 0; i < count; i++) {
        UIView *pin = [[UIView alloc] init];
        pin.bounds = bounds;
        CGFloat pinLength = bounds.size.width;
        pin.center = CGPointMake(center.x + (radius-pinLength/2)*cosf(angle*i), center.y + (radius-pinLength/2)*sinf(angle*i));
        pin.transform = CGAffineTransformMakeRotation(angle*i);
        pin.backgroundColor = [UIColor whiteColor];
        [self.clockView addSubview:pin];
    }
    
}


@end













