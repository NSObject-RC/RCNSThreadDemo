//
//  ViewController.m
//  RCNSThreadDemo
//
//  Created by RongCheng on 2019/3/7.
//  Copyright © 2019年 RongCheng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
//使用nonatomic定义属性
@property (nonatomic,assign) NSInteger totalCount;
@property (nonatomic, strong) NSThread *threadA;
@property (nonatomic, strong) NSThread *threadB;
@property (nonatomic, strong) NSThread *threadC;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];

    [self downloadImage];
}

- (void)downloadImage{
    
    [NSThread detachNewThreadSelector:@selector(download) toTarget:self withObject:nil];
}
- (void)download{
    NSURL *url = [NSURL URLWithString:@"http://00.minipic.eastday.com/20170227/20170227134901_e45455144ba23b7cee75f292229151b1_21.jpeg"];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imageData];
    
    //主线程显示图片  waitUntilDone :是否等待，指的是后面代码的执行是否需要等待本次操作结束
    // 第一种
   // [self performSelector:@selector(showImage:) onThread:[NSThread mainThread] withObject:image waitUntilDone:YES];
    // 第二种
    [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
}
//更新UI操作
-(void)showImage:(UIImage *)image{
    self.imageView.image = image;
    NSLog(@"UI----%@",[NSThread currentThread]);
}



- (void)createSafeThread{
    self.threadA = [[NSThread alloc]initWithTarget:self selector:@selector(getTotal) object:nil];
    self.threadB = [[NSThread alloc]initWithTarget:self selector:@selector(getTotal) object:nil];
    self.threadC = [[NSThread alloc]initWithTarget:self selector:@selector(getTotal) object:nil];
    [self.threadA start];
    [self.threadB start];
    [self.threadC start];
}
- (void)getTotal{
    while (1) {
        @synchronized (self) {
            NSInteger count = self.totalCount;
            if(count < 10) {
                // 添加一个耗时操作，效果更明显
                for (NSInteger i = 0; i<88888; i++) {
                    NSInteger a = 1;
                    NSInteger b = 1;
                    a = a + b;
                }
                self.totalCount = count + 1;
                NSLog(@"------%ld",self.totalCount);
            }else{
                break;
            }
        }
    }
}



//1.alloc init 创建线程,需要手动启动线程
- (void)createNewThread1{
    //1.创建线程
    // 第三个参数object: 前面调用方法需要传递的参数 可以为nil
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(run:) object:@"rc"];
    //设置线程的名字
    thread.name = @"线程RC";
    //设置优先级  取值范围 0.0 ~ 1.0 之间 最高是1.0 默认优先级是0.5
    thread.threadPriority = 1.0;
    
    /*
     iOS8.0之后新增  线程优先级
     @property NSQualityOfService qualityOfService;
     NSQualityOfServiceUserInteractive --> Main thread
     NSQualityOfServiceUserInitiated   --> HIGH
     NSQualityOfServiceUtility         --> LOW
     NSQualityOfServiceBackground      --> Background
     NSQualityOfServiceDefault         --> Default
     */
   // thread.qualityOfService = NSQualityOfServiceDefault;
    //2.启动线程
    [thread start];
    
}

//2.分离子线程,自动启动线程
-(void)createNewThread2{
    [NSThread detachNewThreadSelector:@selector(run:) toTarget:self withObject:@"分离子线程"];
}

//3.开启一条后台线程
-(void)createNewThread3{
    [self performSelectorInBackground:@selector(run:) withObject:@"开启后台线程"];
}
-(void)run:(NSString *)param{
    NSLog(@"---run----%@---%@",[NSThread currentThread],param);
}



@end
