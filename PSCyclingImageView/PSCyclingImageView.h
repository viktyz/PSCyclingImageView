//
//  PSCyclingImageView.h
//  PSCyclingImageViewSampleProject
//
//  Created by viktyz on 16/3/14.
//  Copyright 2016 Alfred Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSCyclingImageViewDelegate;
@protocol PSCyclingImageViewDataSource;

@interface PSCyclingImageView : UIView

@property (nonatomic, weak, nullable) id <PSCyclingImageViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id <PSCyclingImageViewDelegate> delegate;

- (void)reloadData;

@end


@protocol PSCyclingImageViewDelegate <NSObject>

@optional

- (void)cyclingImageView:(nullable PSCyclingImageView *)cyclingImageView didSelectImageAtIndex:(NSInteger)index;

- (void)cyclingImageView:(nullable PSCyclingImageView *)cyclingImageView didScrollToIndex:(NSInteger)index;

@end


@protocol PSCyclingImageViewDataSource <NSObject>

@required

- (NSInteger)numberOfImagesInCyclingImageView:(nullable PSCyclingImageView *)cyclingImageView;

- (nullable NSString *)cyclingImageView:(nullable PSCyclingImageView *)cyclingImageView imagePathForViewAtIndex:(NSInteger)index;

@optional

- (nullable UIImage *)cyclingImageView:(nullable PSCyclingImageView *)cyclingImageView placeholderImageForViewAtIndex:(NSInteger)index;

- (nullable UIPageControl *)pageControlInCyclingImageView:(nullable PSCyclingImageView *)cyclingImageView;

- (NSTimeInterval)timeIntervalForCyclingImageView:(nullable PSCyclingImageView *)cyclingImageView;

@end