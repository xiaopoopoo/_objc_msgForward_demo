//
//  Monkey.m
//  _objc_msgForward_demo
//
//  Created by luguobin on 15/9/21.
//  Copyright © 2015年 XS. All rights reserved.
//

#import "Monkey.h"
#import "ForwardingTarget.h"
#import <objc/runtime.h>

@interface Monkey()
@property (nonatomic, strong) ForwardingTarget *target;
@end

@implementation Monkey

- (instancetype)init
{
    self = [super init];
    if (self) {
        _target = [ForwardingTarget new];
        [self performSelector:@selector(sel:) withObject:@"yeyu"];
    }
    
    return self;
}


id dynamicMethodIMP(id self, SEL _cmd, NSString *str)
{
    NSLog(@"%s:动态添加的方法",__FUNCTION__);
    NSLog(@"%@", str);
    return @"1";
}


//对象查找selector时，先查找cachelist，如果没有则查找methodlist，如果还没有就查找父类的methodlist
//进入该方法，该方法为本类对象添加一个未找到的方法sel，然后重新调用新添加的这个sel方法
+ (BOOL)resolveInstanceMethod:(SEL)sel __OSX_AVAILABLE_STARTING(__MAC_10_5, __IPHONE_2_0) {
    
    class_addMethod(self.class, sel, (IMP)dynamicMethodIMP, "@@:");
    BOOL result = [super resolveInstanceMethod:sel];
    result = YES;
    return result; // 1
}

//如果resolveInstanceMethod没作任何处理，会进入这个方法，把消息重启后转发给其它对象ForwardingTarget，
//ForwardingTarget对象调用它自身的sel方法
- (id)forwardingTargetForSelector:(SEL)aSelector __OSX_AVAILABLE_STARTING(__MAC_10_5, __IPHONE_2_0) {
    id result = [super forwardingTargetForSelector:aSelector];
    result = self.target;
    return result; // 2
}
//如果forwardingTargetForSelector方法未处理，则进入这个方法，这个方法返回一个对象，其中包括
//sel方法的参数及返回值，如果返回的这个对象是nil，那发送消息Runtime则会向doesNotRecognizeSelector发消息，然后程序挂掉，如果不是nil，返回了这个sel函数的签名，那会调用forwardInvocation:方法，该方法再转发给自身对象的invocationTest进行处理
//
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    id result = [super methodSignatureForSelector:aSelector];
    NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:"v@:"];
    result = sig;
    return result; // 3
}


- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    //    [super forwardInvocation:anInvocation];
    anInvocation.selector = @selector(invocationTest);
    [self.target forwardInvocation:anInvocation];
}

- (void)doesNotRecognizeSelector:(SEL)aSelector {
    [super doesNotRecognizeSelector:aSelector];
}

@end
