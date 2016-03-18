//
//  PSCyclingManager.h
//  PSCyclingImageViewSampleProject
//
//  Created by viktyz on 16/3/17.
//  Copyright © 2016年 Alfred Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface PSCOperation : NSInvocationOperation

@property (nonatomic,assign) NSInteger tag;

@end



@interface PSCyclingManager : NSObject

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSCache *cache;

+ (instancetype)sharedInstance;

- (void)clearCache;
- (void)cancelQueue;

- (void)addOperation:(PSCOperation *)operation;

@end
