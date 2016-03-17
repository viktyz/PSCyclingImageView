//
//  PSCyclingManager.m
//  PSCyclingImageViewSampleProject
//
//  Created by viktyz on 16/3/17.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "PSCyclingManager.h"

@implementation PSCyclingManager

+ (instancetype)sharedInstance {
    static PSCyclingManager *sharedInstance = nil;
    
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}

- (void)clearCache
{
    [_cache removeAllObjects];
}

- (void)cancelQueue
{
    [_queue cancelAllOperations];
}

@end
