//
//  PSCyclingImageView.h
//  PSCyclingImageViewSampleProject
//
//  Created by viktyz on 16/3/14.
//  Copyright 2016 Alfred Jiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,PSCyclingDirection) {
    PSCyclingDirection_Left = 0,
    PSCyclingDirection_Right
};

@class PSCyclingImageView;

@protocol PSCyclingImageViewDelegate;
@protocol PSCyclingImageViewDataSource;

@interface PSCyclingImageView : UIView

@property (nonatomic, weak, nullable) IBOutlet id <PSCyclingImageViewDataSource> dataSource;
@property (nonatomic, weak, nullable) IBOutlet id <PSCyclingImageViewDelegate> delegate;
@property (nonatomic, assign, readonly) NSInteger currentImageIndex;

- (void)reloadData;
- (void)celarCache;
- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;

@end


@protocol PSCyclingImageViewDelegate <NSObject>

@optional

- (void)cyclingImageView:(nullable PSCyclingImageView *)cyclingImageView didSelectImageAtIndex:(NSInteger)index;

- (void)cyclingImageView:(nullable PSCyclingImageView *)cyclingImageView didScrollToIndex:(NSInteger)index;

@end


@protocol PSCyclingImageViewDataSource <NSObject>

@required

- (NSInteger)numberOfImagesInCyclingImageView:(nullable PSCyclingImageView *)cyclingImageView;

- (nullable NSString *)cyclingImageView:(nullable PSCyclingImageView *)cyclingImageView urlForImageAtIndex:(NSInteger)index;

@optional

- (NSTimeInterval)timeIntervalForCyclingImageView:(nullable PSCyclingImageView *)cyclingImageView;

- (nullable UIImage *)cyclingImageView:(nullable PSCyclingImageView *)cyclingImageView placeholderImageForViewAtIndex:(NSInteger)index;

- (nullable UIPageControl *)pageControlInCyclingImageView:(nullable PSCyclingImageView *)cyclingImageView;

- (PSCyclingDirection)directionForCyclingImageView:(nullable PSCyclingImageView *)cyclingImageView;

- (UIViewContentMode)cyclingImageView:(nullable PSCyclingImageView *)cyclingImageView contentModeForViewAtIndex:(NSInteger)index;

@end