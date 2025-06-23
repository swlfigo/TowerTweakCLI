//
//  main.m
//  TowerTweakDylib
//
//  Created by sylar on 2025/6/20.
//

#import <Foundation/Foundation.h>
#import "NSObject+hook.h"
static void __attribute__((constructor)) initialize(void) {
    [NSObject hookTower];
}

