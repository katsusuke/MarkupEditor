//
//  ColorPickupViewController.m
//  MarkupEditor
//
//  Created by  on 11/12/19.
//  Copyright 2011 MK System. All rights reserved.
//

#import "ColorPickupViewController.h"

BOOL isInCircle(CGPoint point, CGPoint center, CGFloat r)
{
    CGFloat x = (point.x - center.x);
    CGFloat y = (point.y - center.y);
    x *= x;
    y *= y;
    if(x + y < r * r){
        return YES;
    }else{
        return NO;
    }
}

static const CGPoint const ColorCenters[] = {
    {115, 20},  //  0 上
    {162, 34},  // 30
    {196, 70},  // 60
    {208, 115}, // 90
    {196, 161}, //120
    {163, 196}, //150
    {115, 210}, //180
    {68, 198},  //210
    {34, 164},  //240
    {20, 115},  //270
    {34, 68},   //300
    {68, 34},   //330
    {115, 115}, //中心
};
static const int ColorsCount = sizeof(ColorCenters) / sizeof(ColorCenters[0]);

static NSInteger ColorDiff(UIColor* left, UIColor* right)
{
    CGFloat lr, lg, lb, rr, rg, rb, a;
    [left getRed:&lr green:&lg blue:&lb alpha:&a];
    [right getRed:&rr green:&rg blue:&rb alpha:&a];
    CGFloat r = lr - rr;
    CGFloat g = lg - rg;
    CGFloat b = lb - rb;
    return r * r + g * g + b * b;
}

@implementation ColorPickupViewController

@synthesize color=color_;
@synthesize colors=colors_;
@synthesize delegate=delegate_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        colors_ = [[NSMutableArray alloc]init];
        [colors_ addObject:[UIColor colorWithRed:1.000000 green:0.894118 blue:0.160784 alpha:1]];
        [colors_ addObject:[UIColor colorWithRed:0.768627 green:0.854902 blue:0.180392 alpha:1]];
        [colors_ addObject:[UIColor colorWithRed:0.247059 green:0.639216 blue:0.403922 alpha:1]];
        [colors_ addObject:[UIColor colorWithRed:0.176471 green:0.552941 blue:0.525490 alpha:1]];
        [colors_ addObject:[UIColor colorWithRed:0.133333 green:0.482353 blue:0.576471 alpha:1]];
        [colors_ addObject:[UIColor colorWithRed:0.039216 green:0.356863 blue:0.658824 alpha:1]];
        [colors_ addObject:[UIColor colorWithRed:0.286275 green:0.258824 blue:0.615686 alpha:1]];
        [colors_ addObject:[UIColor colorWithRed:0.470588 green:0.219608 blue:0.588235 alpha:1]];
        [colors_ addObject:[UIColor colorWithRed:0.713726 green:0.188235 blue:0.411765 alpha:1]];
        [colors_ addObject:[UIColor colorWithRed:0.988235 green:0.156863 blue:0.317647 alpha:1]];
        [colors_ addObject:[UIColor colorWithRed:0.964706 green:0.368627 blue:0.000000 alpha:1]];
        [colors_ addObject:[UIColor colorWithRed:0.976471 green:0.615686 blue:0.074510 alpha:1]];
        [colors_ addObject:[UIColor colorWithRed:0.000000 green:0.000000 blue:0.000000 alpha:1]];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc{
    [imageView release];
    [color_ release];
    [super dealloc];
}

- (void)loadView{
    [super loadView];
    
}

- (void)setRingWithIndex:(NSInteger)colorIndex
{
    ring_.frame =
    CGRectMake(ColorCenters[colorIndex].x - ring_.frame.size.width / 2,
               ColorCenters[colorIndex].y - ring_.frame.size.height / 2,
               ring_.frame.size.width, 
               ring_.frame.size.height);
    
}

- (void)setSimilarColor:(UIColor*)color{
    CGFloat min = 3;
    NSInteger minIndex = 0;
    NSInteger i = 0;
    for(UIColor* c in colors_){
        CGFloat diff = ColorDiff(c, color);
        if(diff < min){
            min = diff;
            minIndex = i;
        }
        i++;
    }
    self.color = [colors_ objectAtIndex:i];
    [self setRingWithIndex:i];
}


#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    ring_ = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ring.png"]];
    [imageView addSubview:ring_];
    [self setRingWithIndex:ColorsCount - 1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [ring_ release];
    ring_ = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)handleSingleTap:(id)sender
{
    
    PO(sender);
    UITapGestureRecognizer* tap = (UITapGestureRecognizer*)sender;
    CGPoint point = [tap locationInView:imageView];
    POINTLOG(point);
    int i = 0;
    for(i = 0; i < ColorsCount; ++i){
        if(isInCircle(ColorCenters[i], point, 23)){
            break;
        }
    }
    if(i != ColorsCount){
        self.color = [colors_ objectAtIndex:i];
        [self setRingWithIndex:i];
        [delegate_ colorPickupViewController:self didSelectedColor:self.color];
    }else{
        self.color = nil;
    }
}

@end
