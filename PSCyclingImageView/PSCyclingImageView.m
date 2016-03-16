//
//  PSCyclingImageView.m
//  PSCyclingImageViewSampleProject
//
//  Created by viktyz on 16/3/14.
//  Copyright 2016 Alfred Jiang. All rights reserved.
//

#import "PSCyclingImageView.h"

#define SINGEL_IMAGE     1
#define MULTI_IMAGES     3
#define MIN_TIMEINTERVAL 0.1

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
    NSInteger currentImageIndex;
    NSInteger imageCount;
    CGSize imageSize;
    CGFloat timeInterval;
    NSCache *cache;
    
    NSOperationQueue *queue;
    NSTimer *timer;

    UIProgressView *progressView;

    struct {
        unsigned int didSelectImageAtIndex : 1;
        unsigned int didScrollToIndex : 1;

        unsigned int pageControlInCyclingImageView : 1;
        unsigned int placeholderImageForViewAtIndex : 1;
        unsigned int timeIntervalForCyclingImageView : 1;
    } checkFlags;
}

@end

@implementation PSCyclingImageView

- (void)dealloc {
    if (timer) {
        [timer invalidate];
    }
    
    if (queue) {
        [queue cancelAllOperations];
    }
}

- (instancetype)init {
    if ((self = [super init])) {
        cache = [NSCache new];

        // Cache a maximum of 100 URLs
        cache.countLimit = 100;

        /**
         * The size in bytes of data is used as the cost,
         * so this sets a cost limit of 25MB.
         */
        cache.totalCostLimit = 25 * 1024 * 1024;
    }

    return self;
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
    [cache removeAllObjects];

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

#pragma mark - Private Method


- (void)p_loadImageData {
    imageCount = [_dataSource numberOfImagesInCyclingImageView:self];
    imageSize  = self.bounds.size;

    if (checkFlags.timeIntervalForCyclingImageView) {
        timeInterval = [_dataSource timeIntervalForCyclingImageView:self];
    }
}

- (void)p_setDefaultImage {
    NSURL *leftUrl = [NSURL URLWithString:[_dataSource cyclingImageView:self imagePathForViewAtIndex:(imageCount - 1)]];

    if (checkFlags.placeholderImageForViewAtIndex) {
        leftImageView.image = [_dataSource cyclingImageView:self placeholderImageForViewAtIndex:(imageCount - 1)];
    }

    [self fetchDataWithURL:leftUrl forImageView:leftImageView];

    if (imageCount != SINGEL_IMAGE) {
        if (checkFlags.placeholderImageForViewAtIndex) {
            centerImageView.image = [_dataSource cyclingImageView:self placeholderImageForViewAtIndex:0];
        }

        NSURL *centerUrl = [NSURL URLWithString:[_dataSource cyclingImageView:self imagePathForViewAtIndex:0]];
        [self fetchDataWithURL:centerUrl forImageView:centerImageView];

        if (checkFlags.placeholderImageForViewAtIndex) {
            rightImageView.image = [_dataSource cyclingImageView:self placeholderImageForViewAtIndex:1];
        }

        NSURL *rightUrl = [NSURL URLWithString:[_dataSource cyclingImageView:self imagePathForViewAtIndex:1]];
        [self fetchDataWithURL:rightUrl forImageView:rightImageView];
    }

    currentImageIndex = 0;

    pageControl.currentPage = currentImageIndex;

    if (checkFlags.didScrollToIndex) {
        [_delegate cyclingImageView:self didScrollToIndex:currentImageIndex];
    }

    if (timeInterval > MIN_TIMEINTERVAL && imageCount > SINGEL_IMAGE) {
        timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(p_scrollCyclingView) userInfo:nil repeats:YES];
    }
}

- (void)p_addBgScrollView {
    bgScrollView = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self addSubview:bgScrollView];
    bgScrollView.delegate    = self;
    bgScrollView.contentSize = CGSizeMake((imageCount == SINGEL_IMAGE ? SINGEL_IMAGE : MULTI_IMAGES) * imageSize.width, imageSize.height);
    bgScrollView.pagingEnabled                  = YES;
    bgScrollView.showsHorizontalScrollIndicator = NO;
    [bgScrollView setContentOffset:CGPointMake(((imageCount == SINGEL_IMAGE ? 0 : imageSize.width)), 0) animated:NO];
}

- (void)p_addImageViews {
    leftImageView = [self p_addImageViewWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];

    if (imageCount == SINGEL_IMAGE) {
        return;
    }

    centerImageView = [self p_addImageViewWithFrame:CGRectMake(imageSize.width, 0, imageSize.width, imageSize.height)];
    rightImageView  = [self p_addImageViewWithFrame:CGRectMake(2 * imageSize.width, 0, imageSize.width, imageSize.height)];
}

- (UIImageView *)p_addImageViewWithFrame:(CGRect)frame {
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];

    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [bgScrollView addSubview:imageView];

    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *rightImageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_tapCurrentImage)];
    [imageView addGestureRecognizer:rightImageViewTap];

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
        currentImageIndex = (currentImageIndex + 1) % imageCount;
    } else if (offset.x < imageSize.width) {
        currentImageIndex = (currentImageIndex + imageCount - 1) % imageCount;
    }

    if (checkFlags.placeholderImageForViewAtIndex) {
        centerImageView.image = [_dataSource cyclingImageView:self placeholderImageForViewAtIndex:currentImageIndex];
    }

    NSURL *centerUrl = [NSURL URLWithString:[_dataSource cyclingImageView:self imagePathForViewAtIndex:currentImageIndex]];
    [self fetchDataWithURL:centerUrl forImageView:centerImageView];

    NSInteger leftImageIndex  = (currentImageIndex + imageCount - 1) % imageCount;
    NSInteger rightImageIndex = (currentImageIndex + 1) % imageCount;

    if (checkFlags.placeholderImageForViewAtIndex) {
        leftImageView.image = [_dataSource cyclingImageView:self placeholderImageForViewAtIndex:leftImageIndex];
    }

    NSURL *leftUrl = [NSURL URLWithString:[_dataSource cyclingImageView:self imagePathForViewAtIndex:leftImageIndex]];
    [self fetchDataWithURL:leftUrl forImageView:leftImageView];

    if (checkFlags.placeholderImageForViewAtIndex) {
        rightImageView.image = [_dataSource cyclingImageView:self placeholderImageForViewAtIndex:rightImageIndex];
    }

    NSURL *rightUrl = [NSURL URLWithString:[_dataSource cyclingImageView:self imagePathForViewAtIndex:rightImageIndex]];
    [self fetchDataWithURL:rightUrl forImageView:rightImageView];
}

- (void)p_operationScrollView {
    [self p_reloadImage];

    [bgScrollView setContentOffset:CGPointMake(imageSize.width, 0) animated:NO];

    pageControl.currentPage = currentImageIndex;

    if (checkFlags.didScrollToIndex) {
        [_delegate cyclingImageView:self didScrollToIndex:currentImageIndex];
    }
}

- (void)p_tapCurrentImage {
    if (checkFlags.didSelectImageAtIndex) {
        [_delegate cyclingImageView:self didSelectImageAtIndex:currentImageIndex];
    }
}

- (void)p_scrollCyclingView {
    CGPoint currentPoint = bgScrollView.contentOffset;

    [bgScrollView setContentOffset:CGPointMake(currentPoint.x + imageSize.width, 0) animated:YES];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self p_operationScrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self p_operationScrollView];
}

#pragma mark - Fetch And Cache Image Data

- (void)fetchDataWithURL:(NSURL *)url forImageView:(UIImageView *)imageView {
    NSPurgeableData *cachedData = [cache objectForKey:url];
    
    if (cachedData) {
        [cachedData beginContentAccess];
        
        imageView.image = [UIImage imageWithData:cachedData];
        
        [cachedData endContentAccess];
    } else {
        if (!queue) {
            queue = [[NSOperationQueue alloc] init];
            queue.maxConcurrentOperationCount = 1;
        }
        
        [queue addOperationWithBlock:^{
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            if (!data) {
                return;
            }
            
            NSPurgeableData *purgeableData = [NSPurgeableData dataWithData:data];
            [cache        setObject:purgeableData
                             forKey:url
                               cost:purgeableData.length];
            
            UIImage *image = [UIImage imageWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = image;
                [purgeableData endContentAccess];
            });
        }];
    }
}

@end
