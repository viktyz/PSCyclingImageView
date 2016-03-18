//
//  PSCyclingImageView.m
//  PSCyclingImageViewSampleProject
//
//  Created by viktyz on 16/3/14.
//  Copyright 2016 Alfred Jiang. All rights reserved.
//

#import "PSCyclingImageView.h"
#import "PSCyclingManager.h"

#define SINGEL_IMAGE     1
#define MULTI_IMAGES     3
#define MIN_TIMEINTERVAL 0.1


typedef NS_ENUM(NSInteger,PSImageViewTag) {
    PSImageViewTag_Left = 0,
    PSImageViewTag_Center,
    PSImageViewTag_Right
};

@interface PSCyclingImageView ()
<
UIScrollViewDelegate
>
{
    UIScrollView *bgScrollView;
    UIImageView *leftImageView;
    UIImageView *centerImageView;
    UIImageView *rightImageView;
    UIPageControl *pageControl;
    NSInteger imageCount;
    CGSize imageSize;
    CGFloat timeInterval;
    
    UIProgressView *progressView;
    
    struct {
        unsigned int didSelectImageAtIndex : 1;
        unsigned int didScrollToIndex : 1;
        
        unsigned int pageControlInCyclingImageView : 1;
        unsigned int placeholderImageForViewAtIndex : 1;
        unsigned int timeIntervalForCyclingImageView : 1;
    } checkFlags;
}

@property (nonatomic, assign, readwrite) NSInteger currentImageIndex;


@end

@implementation PSCyclingImageView

- (void)dealloc
{
    [[PSCyclingManager sharedInstance] clearCache];
    [[PSCyclingManager sharedInstance] cancelQueue];
}

- (void)setDelegate:(id<PSCyclingImageViewDelegate>)delegate {
    _delegate = delegate;
    
    checkFlags.didSelectImageAtIndex = [delegate respondsToSelector:@selector(cyclingImageView:didSelectImageAtIndex:)];
    
    checkFlags.didScrollToIndex = [delegate respondsToSelector:@selector(cyclingImageView:didScrollToIndex:)];
}

- (void)setDataSource:(id<PSCyclingImageViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    checkFlags.pageControlInCyclingImageView = [dataSource respondsToSelector:@selector(pageControlInCyclingImageView:)];
    
    checkFlags.placeholderImageForViewAtIndex = [dataSource respondsToSelector:@selector(cyclingImageView:placeholderImageForViewAtIndex:)];
    
    checkFlags.timeIntervalForCyclingImageView = [dataSource respondsToSelector:@selector(timeIntervalForCyclingImageView:)];
}

#pragma mark - Public Method

- (void)reloadData {
    
    NSCache *cache = [[PSCyclingManager sharedInstance] cache];
    
    if (!cache) {
        cache = [NSCache new];
        cache.countLimit = 100;
        cache.totalCostLimit = 25 * 1024 * 1024;
        
        [[PSCyclingManager sharedInstance] setCache:cache];
    }
    
    NSOperationQueue *queue = [[PSCyclingManager sharedInstance] queue];
    
    if (!queue) {
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 1;
        
        [[PSCyclingManager sharedInstance] setQueue:queue];
    }
    
    [self p_loadImageData];
    
    if (!bgScrollView) {
        [self p_addBgScrollView];
    }
    
    if (!leftImageView || !centerImageView || rightImageView) {
        [self p_addImageViews];
    }
    
    if (!pageControl) {
        [self p_addPageControl];
    }
    
    [self p_setDefaultImage];
}

- (void)celarCache {
    [[PSCyclingManager sharedInstance] clearCache];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    //TODO::
    _currentImageIndex = index;
    CGPoint currentPoint = bgScrollView.contentOffset;
    [bgScrollView setContentOffset:CGPointMake(currentPoint.x + imageSize.width, 0) animated:animated];
}

#pragma mark - Private Method


- (void)p_loadImageData {
    imageCount = [_dataSource numberOfImagesInCyclingImageView:self];
    imageSize  = self.bounds.size;
    
    if (checkFlags.timeIntervalForCyclingImageView) {
        timeInterval = [_dataSource timeIntervalForCyclingImageView:self];
    }
}

- (void)p_setDefaultImage {
    NSURL *leftUrl = [NSURL URLWithString:[_dataSource cyclingImageView:self urlForImageAtIndex:(imageCount - 1)]];
    
    [self fetchDataWithURL:leftUrl forImageView:leftImageView withIndex:(imageCount - 1)];
    
    if (imageCount != SINGEL_IMAGE) {
        NSURL *centerUrl = [NSURL URLWithString:[_dataSource cyclingImageView:self urlForImageAtIndex:0]];
        [self fetchDataWithURL:centerUrl forImageView:centerImageView withIndex:0];
        
        NSURL *rightUrl = [NSURL URLWithString:[_dataSource cyclingImageView:self urlForImageAtIndex:1]];
        [self fetchDataWithURL:rightUrl forImageView:rightImageView withIndex:1];
    }
    
    _currentImageIndex = 0;
    
    pageControl.currentPage = _currentImageIndex;
    
    if (checkFlags.didScrollToIndex) {
        [_delegate cyclingImageView:self didScrollToIndex:_currentImageIndex];
    }
    
    if (timeInterval > MIN_TIMEINTERVAL && imageCount > SINGEL_IMAGE) {
        [self performSelector:@selector(p_scrollCyclingView) withObject:nil afterDelay:timeInterval];
    }
}

- (void)p_addBgScrollView {
    bgScrollView = [[UIScrollView alloc] initWithFrame:[self bounds]];
    [self addSubview:bgScrollView];
    bgScrollView.delegate    = self;
    bgScrollView.contentSize = CGSizeMake((imageCount == SINGEL_IMAGE ? SINGEL_IMAGE : MULTI_IMAGES) * imageSize.width, imageSize.height);
    bgScrollView.pagingEnabled                  = YES;
    bgScrollView.showsHorizontalScrollIndicator = NO;
    [bgScrollView setContentOffset:CGPointMake(((imageCount == SINGEL_IMAGE ? 0 : imageSize.width)), 0) animated:NO];
    
    UITapGestureRecognizer *rightImageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_tapCurrentImage)];
    [bgScrollView addGestureRecognizer:rightImageViewTap];
}

- (void)p_addImageViews {
    
    [[bgScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    leftImageView = [self p_addImageViewWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
    leftImageView.tag = PSImageViewTag_Left;
    
    if (imageCount == SINGEL_IMAGE) {
        return;
    }
    
    centerImageView = [self p_addImageViewWithFrame:CGRectMake(imageSize.width, 0, imageSize.width, imageSize.height)];
    centerImageView.tag = PSImageViewTag_Center;
    
    rightImageView  = [self p_addImageViewWithFrame:CGRectMake(2 * imageSize.width, 0, imageSize.width, imageSize.height)];
    rightImageView.tag = PSImageViewTag_Right;
}

- (UIImageView *)p_addImageViewWithFrame:(CGRect)frame {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    [bgScrollView addSubview:imageView];
    
    return imageView;
}

- (void)p_addPageControl {
    if (!checkFlags.pageControlInCyclingImageView) {
        return;
    }
    
    pageControl = [_dataSource pageControlInCyclingImageView:self];
    
    if (!pageControl) {
        return;
    }
    
    CGSize size = [pageControl sizeForNumberOfPages:imageCount];
    pageControl.bounds        = CGRectMake(0, 0, size.width, size.height);
    pageControl.numberOfPages = imageCount;
    
    [self addSubview:pageControl];
}

- (void)p_reloadImage {
    CGPoint offset = [bgScrollView contentOffset];
    
    if (offset.x > imageSize.width) {
        _currentImageIndex = (_currentImageIndex + 1) % imageCount;
    } else if (offset.x < imageSize.width) {
        _currentImageIndex = (_currentImageIndex + imageCount - 1) % imageCount;
    }
    
    NSURL *centerUrl = [NSURL URLWithString:[_dataSource cyclingImageView:self urlForImageAtIndex:_currentImageIndex]];
    [self fetchDataWithURL:centerUrl forImageView:centerImageView withIndex:_currentImageIndex];
    
    NSInteger leftImageIndex  = (_currentImageIndex + imageCount - 1) % imageCount;
    NSInteger rightImageIndex = (_currentImageIndex + 1) % imageCount;
    
    NSURL *leftUrl = [NSURL URLWithString:[_dataSource cyclingImageView:self urlForImageAtIndex:leftImageIndex]];
    [self fetchDataWithURL:leftUrl forImageView:leftImageView withIndex:leftImageIndex];
    
    NSURL *rightUrl = [NSURL URLWithString:[_dataSource cyclingImageView:self urlForImageAtIndex:rightImageIndex]];
    [self fetchDataWithURL:rightUrl forImageView:rightImageView withIndex:rightImageIndex];
}

- (void)p_operationScrollView {
    [self p_reloadImage];
    [bgScrollView setContentOffset:CGPointMake(imageSize.width, 0) animated:NO];
    pageControl.currentPage = _currentImageIndex;
    
    if (checkFlags.didScrollToIndex) {
        [_delegate cyclingImageView:self didScrollToIndex:_currentImageIndex];
    }
}

- (void)p_tapCurrentImage {
    if (checkFlags.didSelectImageAtIndex) {
        [_delegate cyclingImageView:self didSelectImageAtIndex:_currentImageIndex];
    }
}

- (void)p_scrollCyclingView {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(p_scrollCyclingView) object:nil];
    CGPoint currentPoint = bgScrollView.contentOffset;
    [bgScrollView setContentOffset:CGPointMake(currentPoint.x + imageSize.width, 0) animated:YES];
    [self performSelector:_cmd withObject:nil afterDelay:timeInterval];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self p_operationScrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self p_operationScrollView];
}

#pragma mark - Fetch And Cache Image Data

- (void)fetchDataWithURL:(NSURL *)url forImageView:(UIImageView *)imageView withIndex:(NSInteger)index {
    
    imageView.image = nil;
    
    NSCache *cache = [[PSCyclingManager sharedInstance] cache];
    
    NSPurgeableData *cachedData = [cache objectForKey:url];
    
    if (cachedData) {
        [cachedData beginContentAccess];
        imageView.image = [UIImage imageWithData:cachedData];
        [cachedData endContentAccess];
    } else {
        
        if (checkFlags.placeholderImageForViewAtIndex) {
            UIImage *image = [_dataSource cyclingImageView:self placeholderImageForViewAtIndex:index];
            imageView.image = image;
        }
        
        PSCOperation *operation = [[PSCOperation alloc] initWithTarget:self
                                                              selector:@selector(threadOperationInfo:)
                                                                object:@{
                                                                         @"url" : url,
                                                                         @"imageView" : imageView
                                                                         }];
        operation.tag = imageView.tag;
        [[PSCyclingManager sharedInstance] addOperation:operation];
    }
}

- (void)threadOperationInfo:(NSDictionary *)userInfo{
    
    NSURL *url = userInfo[@"url"];
    UIImageView *imageView = userInfo[@"imageView"];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (!data) {
        return;
    }
    
    NSCache *cache = [[PSCyclingManager sharedInstance] cache];
    
    NSPurgeableData *purgeableData = [NSPurgeableData dataWithData:data];
    [cache        setObject:purgeableData
                     forKey:url
                       cost:purgeableData.length];
    
    UIImage *image = [UIImage imageWithData:data];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        imageView.image = image;
        [purgeableData endContentAccess];
    });
}

@end
