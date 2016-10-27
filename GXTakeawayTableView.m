//
//  GXTakeawayTableView.m
//  GetZ
//
//  Created by 方秋鸣 on 16/8/18.
//  Copyright © 2016年 makeupopular.com. All rights reserved.
//

#import "GXTakeawayTableView.h"
#import "GXCourier.h"

static NSString * const kDelegate = @"delegate";

@interface GXTakeawayTableView () <UITableViewDelegate, GXCourierProxy>

@property (nonatomic) GXCourier *masterDelegateCourier;
@property (nonatomic) GXCourier *detailDelegateCourier;

@end

@implementation GXTakeawayTableView

{
    UITableView *_masterTableView;
    UITableView *_detailTableView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _widthPercentageOfMaster = 0.25;
        _masterDelegateCourier = [[GXCourier alloc] init];
        _detailDelegateCourier = [[GXCourier alloc] init];
        _masterDelegateCourier.proxy = self;
        _detailDelegateCourier.proxy = self;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.masterTableView setFrame:CGRectMake(0, 0, self.frame.size.width * self.widthPercentageOfMaster, self.frame.size.height / 3)];
    [self.detailTableView setFrame:CGRectMake(self.masterTableView.frame.size.width, 0, self.frame.size.width * (1 - self.widthPercentageOfMaster), self.frame.size.height / 3)];
    // test code
    id d = self.masterDelegateCourier;
    CGFloat f = [d yes];
    NSLog(@"%f",f);
}

- (void)dealloc
{
    [_masterTableView removeObserver:self forKeyPath:kDelegate];
    [_detailTableView removeObserver:self forKeyPath:kDelegate];
}

#pragma mark - GXCourierProxy

- (GXCourierProxyOption)proxyOptionForSelector:(SEL)aSelector
{
    NSString *selectorString = NSStringFromSelector(aSelector);
    if ([selectorString isEqualToString:NSStringFromSelector(@selector(yes))]) {
        return GXCourierProxyOptionBefore;
    }
    if ([selectorString isEqualToString:NSStringFromSelector(@selector(tableView:didSelectRowAtIndexPath:))]) {
        return GXCourierProxyOptionAfter | GXCourierProxyOptionAlways;
    }
    return GXCourierProxyOptionNone;
}

- (CGFloat)yes
{
    return 3;
}

#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.masterTableView]) {
        [self.detailTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - Custom Accessors

- (void)setWidthPercentageOfMaster:(CGFloat)widthPercentageOfMaster
{
    if (widthPercentageOfMaster > 1 || widthPercentageOfMaster < 0) {
        return;
    }
    _widthPercentageOfMaster =  widthPercentageOfMaster;
}

- (UITableView *)masterTableView
{
    if (_masterTableView == nil)
    {
        _masterTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    }
    return _masterTableView;
}

- (UITableView *)detailTableView
{
    if (_detailTableView == nil)
    {
        _detailTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    }
    return _detailTableView;
}

- (void)setMasterTableView:(UITableView *)masterTableView
{
    if (![masterTableView isEqual:_masterTableView]) {
        [_masterTableView removeObserver:self forKeyPath:kDelegate];
        [_masterTableView removeFromSuperview];
        _masterTableView = masterTableView;
        [self addSubview:_masterTableView];
        [_masterTableView addObserver:self forKeyPath:kDelegate options:NSKeyValueObservingOptionInitial context:nil];
    }
}

- (void)setDetailTableView:(UITableView *)detailTableView
{
    if (![detailTableView isEqual:_detailTableView]) {
        [_detailTableView removeObserver:self forKeyPath:kDelegate];
        [_detailTableView removeFromSuperview];
        _detailTableView = detailTableView;
        [self addSubview:_detailTableView];
        [_detailTableView addObserver:self forKeyPath:kDelegate options:NSKeyValueObservingOptionInitial context:nil];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString: kDelegate]) {
        if ([object isEqual:self.masterTableView] && ![self.masterTableView.delegate isEqual:self.masterDelegateCourier]) {
            self.masterDelegateCourier.target = self.masterTableView.delegate;
            self.masterTableView.delegate = (id<UITableViewDelegate>)self.masterDelegateCourier;
        } else if ([object isEqual:self.detailTableView] && ![self.detailTableView.delegate isEqual:self.detailDelegateCourier]) {
            self.detailDelegateCourier.target = self.detailTableView.delegate;
            self.detailTableView.delegate = (id<UITableViewDelegate>)self.detailDelegateCourier;
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end