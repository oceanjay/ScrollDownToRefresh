// 
//  RefreshView.m
//
//  Created by Roger Fernandez Guri on 10/23/12.
//  Copyright (c) 2012 rogerfernandezg. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files, to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "RefreshView.h"

@implementation RefreshView

@synthesize refreshDelegate;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // Gradient background
        
        CAGradientLayer *gradientLayer = [self greyGradient];
        
        gradientLayer.frame = self.bounds;
        
        [self.layer addSublayer:gradientLayer];
        
        // Label
        
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(4.0f, frame.size.height - 38.0f, self.frame.size.width, 20.0f)];
		
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:11.0f];
		label.textColor = [UIColor whiteColor];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		
        [self addSubview:label];
        
		statusLabel=label;
		
        // Arrow
        
		CALayer *layer = [CALayer layer];
		
        layer.frame = CGRectMake(32.0f, frame.size.height - 52.5f, 21.5f, 46.5f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"arrow"].CGImage;
        
        
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            
			layer.contentsScale = [[UIScreen mainScreen] scale];
            
		}
		
		[[self layer] addSublayer:layer];
        
		arrowImage=layer;
		
        // Spinner
        
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		
        view.frame = CGRectMake(32.0f, frame.size.height - 39.5f, 20.0f, 20.0f);
        
        [self addSubview:view];
        
		activityView = view;
		
		[self setState:PullRefreshNormal];
        
    }
    
    return self;
    
}

- (CAGradientLayer*) greyGradient {
    
    UIColor *colorOne = [UIColor colorWithWhite:0.8 alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.6 alpha:1.0];
    UIColor *colorThree     = [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.4 alpha:1.0];
    UIColor *colorFour = [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.2 alpha:1.0];
    
    NSArray *colors =  [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, colorThree.CGColor, colorFour.CGColor, nil];
    
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:0.4];
    NSNumber *stopThree     = [NSNumber numberWithFloat:0.6];
    NSNumber *stopFour = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, stopThree, stopFour, nil];
    
    CAGradientLayer *layer = [CAGradientLayer layer];
    
    layer.colors = colors;
    layer.locations = locations;
    
    return layer;
    
}

- (void)setState:(PullRefreshState)refreshState{
    
	switch (refreshState) {
            
        case PullRefreshNormal:
			
			if (state == PullRefreshPulling) {
                
				[CATransaction begin];
				[CATransaction setAnimationDuration:0.18f];
                
				arrowImage.transform = CATransform3DIdentity;
                
				[CATransaction commit];
			}
			
			statusLabel.text = @"PULL DOWN TO REFRESH...";
            
			[activityView stopAnimating];
            
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            
			arrowImage.hidden = NO;
			arrowImage.transform = CATransform3DIdentity;
            
			[CATransaction commit];
			
			break;
            
		case PullRefreshPulling:
			
			statusLabel.text = @"RELEASE TO REFRESH...";
            
			[CATransaction begin];
			[CATransaction setAnimationDuration:0.18f];
            
			arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
            
			[CATransaction commit];
			
			break;
            
		case PullRefreshLoading:
			
			statusLabel.text = @"LOADING...";
            
			[activityView startAnimating];
            
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            
			arrowImage.hidden = YES;
            
			[CATransaction commit];
			
			break;
            
		default:
            
			break;
            
	}
	
	state = refreshState;
    
}

- (void)viewDidScroll:(UIScrollView *)scrollView {
    
	if (state == PullRefreshLoading) {
        
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
        
		offset = MIN(offset, 60);
        
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		
	} else if (scrollView.isDragging) {
        
		BOOL loading = NO;
        
		if ([scrollView.delegate respondsToSelector:@selector(RefreshTableHeaderDataSourceIsLoading:)]) {
            
			loading = [refreshDelegate dataIsLoading:self];
            
		}
		
		if (state == PullRefreshPulling && scrollView.contentOffset.y > -60.0f && scrollView.contentOffset.y < 0.0f && !loading) {
            
			[self setState:PullRefreshNormal];
            
		} else if (state == PullRefreshNormal && scrollView.contentOffset.y < -60.0f && !loading) {
            
			[self setState:PullRefreshPulling];
            
		}
		
		if (scrollView.contentInset.top != 0) {
            
			scrollView.contentInset = UIEdgeInsetsZero;
            
		}
		
	}
	
}

- (void)viewDidEndDragging:(UIScrollView *)scrollView {
    
    NSLog(@"viewDidEndDragging");
    
	BOOL loading = NO;
    
	if ([refreshDelegate respondsToSelector:@selector(dataIsLoading:)]) {
        
        NSLog(@"respondsToSelector:@selector(dataIsLoading:)");
        
		loading = [refreshDelegate dataIsLoading:self];
        
	}
	
	if (scrollView.contentOffset.y <= - 65.0f && !loading) {
        
        NSLog(@"dataIsNotLoading");
        
		if ([refreshDelegate respondsToSelector:@selector(didTriggerRefresh:)]) {
            
            NSLog(@"espondsToSelector:@selector(didTriggerRefresh:)");
			
            [refreshDelegate didTriggerRefresh:self];
            
		}
		
		[self setState:PullRefreshLoading];
        
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
        
		scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
        
		[UIView commitAnimations];
		
	}
	
}

- (void)viewDataDidFinishedLoading:(UIScrollView *)scrollView {
	
    NSLog(@"viewDataDidFinishedLoading");
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
    
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    
	[UIView commitAnimations];
	
	[self setState:PullRefreshNormal];
    
}

@end