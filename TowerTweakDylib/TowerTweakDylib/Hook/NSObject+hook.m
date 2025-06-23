//
//  NSObject+hook.m
//  TowerTweakDylib
//
//  Created by sylar on 2025/6/20.
//

#import "NSObject+hook.h"
#import "JRSwizzle.h"
#import <objc/runtime.h>
@implementation NSObject (hook)
+(void)hookTower {
    NSLog(@"Begin Hook Tower");
    
    [objc_getClass("GTApplicationController") jr_swizzleMethod:@selector(openNewWindow:) withMethod:@selector(hook_GTApplicationControllerOpenNewWindow:) error:nil];
     
    [objc_getClass("GTApplicationController") jr_swizzleMethod:@selector(openFiles:) withMethod:@selector(hook_GTApplicationControllerOpenFiles:) error:nil];
    
    [objc_getClass("GTApplicationController") jr_swizzleMethod:@selector(openFileURLs:) withMethod:@selector(hook_GTApplicationControllerOpenFileURLs:) error:nil];
}

-(void)hook_GTApplicationControllerOpenNewWindow:(id)window{
    NSLog(@"");
    [self hook_GTApplicationControllerOpenNewWindow:window];
}

-(void)hook_GTApplicationControllerOpenFiles:(id)file{
    NSLog(@"");
    [self hook_GTApplicationControllerOpenFiles:file];
}

-(void)hook_GTApplicationControllerOpenFileURLs:(id)url{
    NSLog(@"");
    [self hook_GTApplicationControllerOpenFileURLs:url];
}

@end



