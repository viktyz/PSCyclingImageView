//
//  ViewController.m
//  PSCyclingImageViewSampleProject
//
//  Created by viktyz on 16/3/14.
//  Copyright 2016 Alfred Jiang. All rights reserved.
//

#import "ViewController.h"
#import "PSCyclingImageView.h"

@interface ViewController ()
<
    PSCyclingImageViewDelegate,
    PSCyclingImageViewDataSource
>
{
    PSCyclingImageView *pssImagesView;
}

@property (nonatomic, strong) NSMutableArray *placeholderImages;
@property (nonatomic, strong) NSMutableArray *images;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    pssImagesView = [[PSCyclingImageView alloc] init];
    pssImagesView.delegate = self;
    pssImagesView.dataSource = self;
    [self.view addSubview:pssImagesView];
    pssImagesView.frame = self.view.bounds;

    _placeholderImages = [NSMutableArray arrayWithArray:@[
                              [UIImage imageNamed:@"001.jpg"],
                              [UIImage imageNamed:@"002.jpg"],
                              [UIImage imageNamed:@"003.jpg"],
                              [UIImage imageNamed:@"004.jpg"],
                              [UIImage imageNamed:@"005.jpg"],
                              [UIImage imageNamed:@"006.jpg"],
                              [UIImage imageNamed:@"007.jpg"],
                              [UIImage imageNamed:@"008.jpg"],
                              [UIImage imageNamed:@"009.jpg"],
                              [UIImage imageNamed:@"010.jpg"],
                              [UIImage imageNamed:@"011.jpg"],
                              [UIImage imageNamed:@"012.jpg"],
                          ]];

    _images = [NSMutableArray arrayWithArray:@[
                   @"http://img3.3lian.com/2013/s1/20/d/56.jpg",
                   @"http://img3.3lian.com/2013/s1/20/d/57.jpg",
                   @"http://img3.3lian.com/2013/s1/20/d/58.jpg",
                   @"http://img3.3lian.com/2013/s1/20/d/59.jpg",
                   @"http://img3.3lian.com/2013/s1/20/d/60.jpg",
                   @"http://img3.3lian.com/2013/s1/20/d/61.jpg",
                   @"http://img3.3lian.com/2013/s1/18/d/75.jpg",
                   @"http://img3.3lian.com/2013/s1/18/d/76.jpg",
                   @"http://img3.3lian.com/2013/s1/18/d/77.jpg",
                   @"http://img3.3lian.com/2013/s1/18/d/78.jpg",
                   @"http://img3.3lian.com/2013/s1/18/d/79.jpg",
                   @"xxxxxx",
               ]];



    [pssImagesView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PSCyclingImageViewDelegate

- (void)cyclingImageView:(nullable PSCyclingImageView *)cyclingImageView didSelectImageAtIndex:(NSInteger)index {
    NSLog(@"didSelectImageAtIndex : %ld", (long)index);
}

- (void)cyclingImageView:(PSCyclingImageView *)cyclingImageView didScrollToIndex:(NSInteger)index {
    NSLog(@"didScrollToIndex : %ld", (long)index);
}

#pragma makr - PSCyclingImageViewDataSource

- (NSInteger)numberOfImagesInCyclingImageView:(nullable PSCyclingImageView *)cyclingImageView {
    return [_images count];
}

- (nullable NSString *)cyclingImageView:(nullable PSCyclingImageView *)cyclingImageView imagePathForViewAtIndex:(NSInteger)index {
    return [_images objectAtIndex:index];
}

- (nullable UIPageControl *)pageControlInCyclingImageView:(PSCyclingImageView *)cyclingImageView {
    UIPageControl *pageControl = [[UIPageControl alloc] init];

    pageControl = [[UIPageControl alloc] init];
    pageControl.center = CGPointMake(cyclingImageView.frame.size.width / 2, cyclingImageView.frame.size.height - 100);
    pageControl.pageIndicatorTintColor = [UIColor colorWithRed:193 / 255.0 green:219 / 255.0 blue:249 / 255.0 alpha:1];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0 green:150 / 255.0 blue:1 alpha:1];
    return pageControl;
}

- (nullable UIImage *)cyclingImageView:(PSCyclingImageView *)cyclingImageView placeholderImageForViewAtIndex:(NSInteger)index {
    return [_placeholderImages objectAtIndex:index];
}

- (CGFloat)timeIntervalForCyclingImageView:(PSCyclingImageView *)cyclingImageView {
    return 5.0;
//    return 0;
}

@end
