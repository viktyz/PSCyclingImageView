//
//  PSCyclingManager.m
//  PSCyclingImageViewSampleProject
//
//  Created by viktyz on 16/3/17.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import "PSCyclingManager.h"
#import "PSCOperation.h"



@implementation PSCOperation

@end



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

- (void)addOperation:(PSCOperation *)operation
{
    [_queue.operations enumerateObjectsUsingBlock:^(PSCOperation *tOperation, NSUInteger idx, BOOL * _Nonnull stop) {
        if (tOperation.tag == operation.tag) {
            NSLog(@"Tag With %ld has been canceled",tOperation.tag);
            [tOperation cancel];
            *stop = YES;
        }
    }];
    
    [_queue addOperation:operation];
}

@end
