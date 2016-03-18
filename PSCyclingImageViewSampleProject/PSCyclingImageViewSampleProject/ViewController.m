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
    PSCyclingImageView *cyclingImageView1;
}

@property (weak, nonatomic) IBOutlet PSCyclingImageView *cyclingImageView0;
@property (weak, nonatomic) IBOutlet PSCyclingImageView *cyclingImageView2;
@property (weak, nonatomic) IBOutlet PSCyclingImageView *cyclingImageView3;

@property (weak, nonatomic) IBOutlet UIView *viewCyclingImagePanel;
@property (nonatomic, strong) NSMutableArray *placeholderImages;
@property (nonatomic, strong) NSMutableArray *images;

@end

@implementation ViewController

- (void)dealloc {
    cyclingImageView1.delegate = nil;
    cyclingImageView1.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

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
}

- (IBAction)clickRandomBtn:(UIButton *)sender {
    [_cyclingImageView3 scrollToIndex:(random()%[_images count]) animated:YES];
}

- (void)viewDidLayoutSubviews {
    
    _cyclingImageView0.tag = 0;
    [_cyclingImageView0 reloadData];


    if (cyclingImageView1.superview != _viewCyclingImagePanel) {
        cyclingImageView1 = [[PSCyclingImageView alloc] initWithFrame:_viewCyclingImagePanel.bounds];
        cyclingImageView1.tag = 1;
        cyclingImageView1.delegate = self;
        cyclingImageView1.dataSource = self;
        [self.viewCyclingImagePanel addSubview:cyclingImageView1];
    }


    [cyclingImageView1 reloadData];


    _cyclingImageView2.tag = 2;
    [_cyclingImageView2 reloadData];
    
    _cyclingImageView3.tag = 3;
    [_cyclingImageView3 reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PSCyclingImageViewDelegate

- (void)cyclingImageView:(nullable PSCyclingImageView *)cyclingImageView didSelectImageAtIndex:(NSInteger)index {
    NSLog(@"cyclingImageView : %ld, didSelectImageAtIndex : %ld",cyclingImageView.tag,(long)index);
}

- (void)cyclingImageView:(PSCyclingImageView *)cyclingImageView didScrollToIndex:(NSInteger)index {
    NSLog(@"cyclingImageView : %ld, didScrollToIndex : %ld",(long)cyclingImageView.tag,(long)index);
}

#pragma makr - PSCyclingImageViewDataSource

- (NSInteger)numberOfImagesInCyclingImageView:(nullable PSCyclingImageView *)cyclingImageView {
    return [_images count];
}

- (nullable NSString *)cyclingImageView:(nullable PSCyclingImageView *)cyclingImageView urlForImageAtIndex:(NSInteger)index {
    return [_images objectAtIndex:index];
}

- (nullable UIPageControl *)pageControlInCyclingImageView:(PSCyclingImageView *)cyclingImageView {
    UIPageControl *pageControl = [[UIPageControl alloc] init];

    pageControl = [[UIPageControl alloc] init];
    pageControl.center = CGPointMake(cyclingImageView.frame.size.width / 2, cyclingImageView.frame.size.height - 5);
    pageControl.pageIndicatorTintColor = [UIColor colorWithRed:193 / 255.0 green:219 / 255.0 blue:249 / 255.0 alpha:1];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0 green:150 / 255.0 blue:1 alpha:1];
    return pageControl;
}

- (nullable UIImage *)cyclingImageView:(PSCyclingImageView *)cyclingImageView placeholderImageForViewAtIndex:(NSInteger)index {
    return [_placeholderImages objectAtIndex:index];
}

- (NSTimeInterval)timeIntervalForCyclingImageView:(PSCyclingImageView *)cyclingImageView {
    if (cyclingImageView.tag == 0) {
        return 1.0;
    } else if (cyclingImageView.tag == 1) {
        return 2.0;
    } else if (cyclingImageView.tag == 2) {
        return 0.5;
    } else {
        return 0;
    }
}

- (PSCyclingDirection)directionForCyclingImageView:(PSCyclingImageView *)cyclingImageView
{
    if (cyclingImageView.tag == 2) {
        return PSCyclingDirection_Left;
    } else {
        return PSCyclingDirection_Right;
    }
}

- (UIViewContentMode)cyclingImageView:(nullable PSCyclingImageView *)cyclingImageView contentModeForViewAtIndex:(NSInteger)index
{
    if (cyclingImageView.tag == 0) {
        return UIViewContentModeScaleAspectFit;
    } else if (cyclingImageView.tag == 1) {
        return UIViewContentModeScaleToFill;
    } else if (cyclingImageView.tag == 2) {
        return UIViewContentModeScaleAspectFill;
    } else {
        return UIViewContentModeCenter;
    }
}

@end
