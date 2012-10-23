//
//  ViewController.m
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

#import <QuartzCore/QuartzCore.h>

#import "ViewController.h"
#import "RefreshView.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize mainView, navBar;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Nav bar title
    
    self.navigationItem.title = @"Title";
    
    // Nav bar background
    
    navBar = self.navigationController.navigationBar;
    
    //[navBar setBackgroundImage:[UIImage imageNamed:@"navbar_background"] forBarMetrics:UIBarMetricsDefault];
    
    // Nav bar shadow
    
    [self drawShadow:[self.navigationController navigationBar].layer red:0.0f/255.f green:0.0f/255.f blue:0.0f/255.f alpha:1 opacity:0.5f offsetX:0.0f offsetY:1.0f radius:0.0f rasterize:YES];
    
    // App background
    
    self.view.backgroundColor = [UIColor colorWithRed:239.0f/255.0f green:239.0f/255.0f blue:239.0f/255.0f alpha:1];
    
    // Main view
    
    mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    mainView.contentSize = CGSizeMake(self.view.frame.size.width, 500);
    
    mainView.delegate = self;
    
    [self.view addSubview:mainView];
    
    // Pull down to refresh
    
    if (refreshView == nil) {
        
		RefreshView *pullToRefreshView = [[RefreshView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.mainView.bounds.size.height, self.view.frame.size.width, self.mainView.bounds.size.height)];
		
        pullToRefreshView.refreshDelegate = self;
		
        [self.mainView addSubview:pullToRefreshView];
		
        refreshView = pullToRefreshView;
		
	}
    
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
}

- (void)drawShadow:(CALayer *)layer red:(float)red green:(float)green blue:(float)blue alpha:(float)alpha opacity:(float)opacity offsetX:(float)offsetX offsetY:(float)offsetY radius:(float)radius rasterize:(BOOL)rasterize {
    
    layer.shadowColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha].CGColor;
    layer.shadowOpacity = opacity;
    layer.shadowOffset = CGSizeMake(offsetX, offsetY);
    layer.shadowRadius = radius;
    layer.shouldRasterize = rasterize;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
	[refreshView viewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    NSLog(@"scrollViewDidEndDragging");
    
	[refreshView viewDidEndDragging:scrollView];
	
}

- (void)didTriggerRefresh:(RefreshView*)view{
	
    NSLog(@"didTriggerRefresh");
    
	[self reloadData];
	[self performSelector:@selector(doneLoadingData) withObject:nil afterDelay:0.5f];
	
}

- (BOOL)dataIsLoading:(RefreshView*)view{
    
    NSLog(@"dataIsLoading");
    
	return reloading;
    
}

- (void)reloadData{
    
    NSLog(@"reloadData");
    
	reloading = YES;
    
}

- (void)doneLoadingData{
    
    NSLog(@"doneLoadingData");
    
	reloading = NO;
    
	[refreshView viewDataDidFinishedLoading:self.mainView];
	
}

@end