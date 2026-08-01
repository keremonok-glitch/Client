#import <UIKit/UIKit.h>
#include <iostream>

@interface StorageESPMenu : UIViewController
@property (nonatomic, assign) BOOL isESPEnabled;
@property (nonatomic, assign) BOOL isTracerEnabled;
@property (nonatomic, assign) BOOL filterChests;
@property (nonatomic, assign) BOOL filterEnderChests;
@property (nonatomic, assign) BOOL filterShulkers;
@property (nonatomic, assign) BOOL filterFurnaces;
@property (nonatomic, assign) BOOL filterBarrels;
@property (nonatomic, assign) BOOL filterHoppers;
@property (nonatomic, assign) BOOL filterPistons;
@property (nonatomic, assign) BOOL filterStickyPistons;
@property (nonatomic, assign) BOOL filterSpawners;

// Bloklara Ait Dinamik Renk Tutucular (GUI'den Değişir)
@property (nonatomic, strong) UIColor *colorChest;
@property (nonatomic, strong) UIColor *colorEnder;
@property (nonatomic, strong) UIColor *colorShulker;
@property (nonatomic, strong) UIColor *colorFurnace;
@property (nonatomic, strong) UIColor *colorBarrel;
@property (nonatomic, strong) UIColor *colorHopper;
@property (nonatomic, strong) UIColor *colorPiston;
@property (nonatomic, strong) UIColor *colorSticky;
@property (nonatomic, strong) UIColor *colorSpawner;

@property (nonatomic, strong) UIView *tracerOverlayView;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation StorageESPMenu

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Varsayılan Ayarlar & İstediğin Özel Renkler
    self.isESPEnabled = YES;
    self.isTracerEnabled = NO;
    self.filterChests = YES;
    self.filterEnderChests = YES;
    self.filterShulkers = YES;
    self.filterFurnaces = NO;   
    self.filterBarrels = YES;
    self.filterHoppers = YES;
    self.filterPistons = NO;    
    self.filterStickyPistons = NO; 
    self.filterSpawners = YES;  
    
    // İstediğin Başlangıç Renkleri
    self.colorChest   = [UIColor colorWithRed:1.0f green:0.65f blue:0.0f alpha:1.0f];      // Canlı Turuncu
    self.colorEnder   = [UIColor systemPurpleColor];                                       // Mor
    self.colorShulker = [UIColor systemPinkColor];                                       // Pembe
    self.colorFurnace = [UIColor darkGrayColor];                                       // Gri
    self.colorBarrel  = [UIColor colorWithRed:0.9f green:0.75f blue:0.55f alpha:0.7f];    // Soluk Turuncu
    self.colorHopper  = [UIColor colorWithRed:0.35f green:0.38f blue:0.42f alpha:1.0f];    // Farklı Koyu Gri
    self.colorPiston  = [UIColor colorWithRed:0.85f green:0.70f blue:0.55f alpha:1.0f];    // Meşe / Ten Rengi
    self.colorSticky  = [UIColor systemGreenColor];                                      // Yeşil
    self.colorSpawner = [UIColor systemRedColor];                                      // Kırmızı
    
    // Ana Pencere
    UIView *windowView = [[UIView alloc] initWithFrame:CGRectMake(30, 50, 310, 580)];
    windowView.backgroundColor = [UIColor colorWithRed:0.12f green:0.12f blue:0.14f alpha:0.95f];
    windowView.layer.cornerRadius = 10;
    windowView.layer.borderWidth = 1.5f;
    windowView.layer.borderColor = [[UIColor systemPinkColor] CGColor];
    [self.view addSubview:windowView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragWindow:)];
    [windowView addGestureRecognizer:pan];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 280, 25)];
    title.text = @"⚡ MyPvP | Custom Color GUI ESP";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:13];
    [windowView addSubview:title];
    
    int startY = 45;
    int height = 28;
    int gap = 32;
    
    [self createButtonOn:windowView frame:CGRectMake(15, startY, 280, height) title:@"3D Storage ESP" state:self.isESPEnabled action:@selector(toggleESP:)];
    [self createButtonOn:windowView frame:CGRectMake(15, startY + gap, 280, height) title:@"Tracers (Crosshair)" state:self.isTracerEnabled action:@selector(toggleTracer:)];
    [self createButtonOn:windowView frame:CGRectMake(15, startY + (gap*2), 280, height) title:@"Chests [Değiştir]" state:self.filterChests action:@selector(cycleChestColor:)];
    [self createButtonOn:windowView frame:CGRectMake(15, startY + (gap*3), 280, height) title:@"Ender Chests [Değiştir]" state:self.filterEnderChests action:@selector(cycleEnderColor:)];
    [self createButtonOn:windowView frame:CGRectMake(15, startY + (gap*4), 280, height) title:@"Shulker Boxes [Değiştir]" state:self.filterShulkers action:@selector(cycleShulkerColor:)];
    [self createButtonOn:windowView frame:CGRectMake(15, startY + (gap*5), 280, height) title:@"Furnaces [Değiştir]" state:self.filterFurnaces action:@selector(cycleFurnaceColor:)];
    [self createButtonOn:windowView frame:CGRectMake(15, startY + (gap*6), 280, height) title:@"Barrels [Değiştir]" state:self.filterBarrels action:@selector(cycleBarrelColor:)];
    [self createButtonOn:windowView frame:CGRectMake(15, startY + (gap*7), 280, height) title:@"Hoppers [Değiştir]" state:self.filterHoppers action:@selector(cycleHopperColor:)];
    [self.createButtonOn:windowView frame:CGRectMake(15, startY + (gap*8), 280, height) title:@"Pistons [Değiştir]" state:self.filterPistons action:@selector(cyclePistonColor:)];
    [self.createButtonOn:windowView frame:CGRectMake(15, startY + (gap*9), 280, height) title:@"Sticky Pistons [Değiştir]" state:self.filterStickyPistons action:@selector(cycleStickyColor:)];
    [self.createButtonOn:windowView frame:CGRectMake(15, startY + (gap*10), 280, height) title:@"Spawners [Değiştir]" state:self.filterSpawners action:@selector(cycleSpawnerColor:)];
    
    self.tracerOverlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.tracerOverlayView.backgroundColor = [UIColor clearColor];
    self.tracerOverlayView.userInteractionEnabled = NO;
    [self.view addSubview:self.tracerOverlayView];
    [self.view bringSubviewToFront:windowView];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateESPAndTracers)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)createButtonOn:(UIView *)parent frame:(CGRect)frame title:(NSString *)title state:(BOOL)state action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = state ? [UIColor colorWithRed:0.25f green:0.25f blue:0.28f alpha:1.0f] : [UIColor colorWithRed:0.18f green:0.18f blue:0.20f alpha:1.0f];
    btn.layer.cornerRadius = 6;
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [parent addSubview:btn];
}

- (void)dragWindow:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    if (!view) return;
    CGPoint translation = [gesture translationInView:self.view];
    CGPoint center = view.center;
    view.center = CGPointMake(center.x + translation.x, center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self.view];
}

// --- 3D ESP VE TRACER ÇİZİM DÖNGÜSÜ ---
- (void)updateESPAndTracers {
    if (!self.isESPEnabled) {
        self.tracerOverlayView.layer.sublayers = nil;
        return;
    }
    self.tracerOverlayView.layer.sublayers = nil;
    
    CGPoint crosshairCenter = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    
    CGRect sampleBoxRect = CGRectMake(160, 180, 45, 45);
    
    if (self.filterEnderChests) {
        [self draw3DBoxAtRect:sampleBoxRect withColor:self.colorEnder];
        
        if (self.isTracerEnabled) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:crosshairCenter];
            [path addLineToPoint:CGPointMake(CGRectGetMidX(sampleBoxRect), CGRectGetMidY(sampleBoxRect))];
            
            CAShapeLayer *lineLayer = [CAShapeLayer layer];
            lineLayer.path = path.CGPath;
            lineLayer.strokeColor = [self.colorEnder CGColor];
            lineLayer.lineWidth = 1.5f;
            [self.tracerOverlayView.layer addSublayer:lineLayer];
        }
    }
}

// 3D Küp Çizici
- (void)draw3DBoxAtRect:(CGRect)rect withColor:(UIColor *)color {
    CAShapeLayer *boxLayer = [CAShapeLayer layer];
    boxLayer.path = [UIBezierPath bezierPathWithRect:rect].CGPath;
    boxLayer.strokeColor = [color CGColor];
    boxLayer.fillColor = [[color colorWithAlphaComponent:0.15f] CGColor];
    boxLayer.lineWidth = 1.2f;
    [self.tracerOverlayView.layer addSublayer:boxLayer];
}

// --- RENK DÖNGÜSÜ METOTLARI ---
- (UIColor *)nextColorAfter:(UIColor *)current {
    if (current == [UIColor systemPurpleColor]) return [UIColor systemRedColor];
    if (current == [UIColor systemRedColor]) return [UIColor systemGreenColor];
    if (current == [UIColor systemGreenColor]) return [UIColor systemBlueColor];
    if (current == [UIColor systemBlueColor]) return [UIColor systemYellowColor];
    return [UIColor systemPurpleColor];
}

- (void)cycleChestColor:(UIButton *)sender { self.colorChest = [self nextColorAfter:self.colorChest]; }
- (void)cycleEnderColor:(UIButton *)sender { self.colorEnder = [self nextColorAfter:self.colorEnder]; }
- (void)cycleShulkerColor:(UIButton *)sender { self.colorShulker = [self nextColorAfter:self.colorShulker]; }
- (void)cycleFurnaceColor:(UIButton *)sender { self.colorFurnace = [self nextColorAfter:self.colorFurnace]; }
- (void)cycleBarrelColor:(UIButton *)sender { self.colorBarrel = [self nextColorAfter:self.colorBarrel]; }
- (void)cycleHopperColor:(UIButton *)sender { self.colorHopper = [self nextColorAfter:self.colorHopper]; }
- (void)cyclePistonColor:(UIButton *)sender { self.colorPiston = [self nextColorAfter:self.colorPiston]; }
- (void)cycleStickyColor:(UIButton *)sender { self.colorSticky = [self nextColorAfter:self.colorSticky]; }
- (void)cycleSpawnerColor:(UIButton *)sender { self.colorSpawner = [self nextColorAfter:self.colorSpawner]; }

- (void)toggleESP:(UIButton *)sender { self.isESPEnabled = !self.isESPEnabled; [self updateBtnStyle:sender state:self.isESPEnabled]; }
- (void)toggleTracer:(UIButton *)sender { self.isTracerEnabled = !self.isTracerEnabled; [self updateBtnStyle:sender state:self.isTracerEnabled]; }

- (void)updateBtnStyle:(UIButton *)btn state:(BOOL)state {
    btn.backgroundColor = state ? [UIColor colorWithRed:0.25f green:0.25f blue:0.28f alpha:1.0f] : [UIColor colorWithRed:0.18f green:0.18f blue:0.20f alpha:1.0f];
}

- (void)dealloc {
    [self.displayLink invalidate];
}

@end

extern "C" void InitMyPvPMenu() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window) {
            StorageESPMenu *menu = [[StorageESPMenu alloc] init];
            menu.view.frame = window.bounds;
            menu.view.backgroundColor = [UIColor clearColor];
            [window addSubview:menu.view];
        }
    });
}
