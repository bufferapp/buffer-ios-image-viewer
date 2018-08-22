//
//  BFRImageViewerDownloadProgressView.m
//  BFRImageViewer
//
//  Created by Jordan Morgan on 8/22/18.
//  Copyright © 2018 Andrew Yates. All rights reserved.
//

#import "BFRImageViewerDownloadProgressView.h"

static const CGFloat BFR_PROGRESS_LINE_WIDTH = 3.0f;

@interface BFRImageViewerDownloadProgressView()

@property (strong, nonatomic, nonnull) CAShapeLayer *progressBackingLayer;
@property (strong, nonatomic, nonnull) CAShapeLayer *progressLayer;
@property (strong, nonatomic, nonnull) UIBezierPath *progressPath;
@property (nonatomic, readwrite) CGSize progessSize;

@end

@implementation BFRImageViewerDownloadProgressView

#pragma mark - Lazy Loads

- (CAShapeLayer *)progressBackingLayer {
    if (!_progressBackingLayer) {
        _progressBackingLayer = [CAShapeLayer new];
        _progressBackingLayer.strokeColor = [UIColor lightTextColor].CGColor;
        _progressBackingLayer.fillColor = [UIColor clearColor].CGColor;
        _progressBackingLayer.strokeEnd = 1;
        _progressBackingLayer.lineCap = kCALineCapRound;
        _progressBackingLayer.lineWidth = BFR_PROGRESS_LINE_WIDTH;
    }
    
    return _progressBackingLayer;
}

- (CAShapeLayer *)progressLayer {
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer new];
        _progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeEnd = 0;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.lineWidth = BFR_PROGRESS_LINE_WIDTH;
    }
    
    return _progressLayer;
}

#pragma mark - Custom setters

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    if (_progressLayer == nil) return;
    _progressLayer.strokeEnd = progress;
}

#pragma mark - Initializers

- (instancetype)init {
    self = [super init];
    
    if (self) {
        CGFloat targetHeightWidth = floorf([UIScreen mainScreen].bounds.size.width * .15f);
        self.progessSize = CGSizeMake(targetHeightWidth, targetHeightWidth);
        
        CGRect baseRect = CGRectMake(0, 0, self.progessSize.width, self.progessSize.height);
        CGRect targetRect = CGRectInset(baseRect, BFR_PROGRESS_LINE_WIDTH/2, BFR_PROGRESS_LINE_WIDTH/2);
        
        // Progress circle
        CGFloat startAngle = M_PI_2 * 3.0f;;
        CGFloat endAngle = startAngle + (M_PI * 2.0);
        CGFloat width = CGRectGetWidth(targetRect)/2.0f;
        CGFloat height = CGRectGetHeight(targetRect)/2.0f;
        CGPoint centerPoint = CGPointMake(width, height);
        float radius = targetRect.size.width/2;
        
        self.progressPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                           radius:radius
                                                       startAngle:startAngle
                                                         endAngle:endAngle
                                                        clockwise:YES];
        
        self.progressBackingLayer.path = self.progressPath.CGPath;
        self.progressLayer.path = self.progressPath.CGPath;
        
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;

        [self.layer addSublayer:self.progressBackingLayer];
        [self.layer addSublayer:self.progressLayer];
    }
    
    return self;
}

@end
