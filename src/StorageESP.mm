#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface StorageESPMenu : UIViewController <UIPopoverPresentationControllerDelegate>
@property (nonatomic, assign) BOOL isESPEnabled;
@property (nonatomic, assign) BOOL isTracerEnabled;
@property (nonatomic, assign) int alphaValue; // 0 - 255
@property (nonatomic, assign) int shapeMode;  // 0: Lines, 1: Sides, 2: Both

@property (nonatomic, assign) BOOL filterChests;
@property (nonatomic, assign) BOOL filterEnderChests;
@property (nonatomic, assign) BOOL filterShulkers;
@property (nonatomic, assign) BOOL filterFurnaces;
@property (nonatomic, assign) BOOL filterBarrels;
@property (nonatomic, assign) BOOL filterHoppers;
@property (nonatomic, assign) BOOL filterPistons;
@property (nonatomic, assign) BOOL filterEnchantingTables;
@property (nonatomic, assign) BOOL filterSpawners;

@property (nonatomic, strong) UIView *tracerOverlayView;
@property (nonatomic, strong) UIView *mainWindowView;
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation StorageESPMenu

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Başlangıç Ayarları
    self.isESPEnabled = YES;
    self.isTracerEnabled = YES;
    self.alphaValue = 255;
    self.shapeMode = 2; // Both
    
    self.filterChests = YES;
    self.filterEnderChests = YES;
    self.filterShulkers = YES;
    self.filterFurnaces = YES;
    self.filterBarrels = YES;
    self.filterHoppers = YES;
    self.filterPistons = YES;
    self.filterEnchantingTables = YES;
    self.filterSpawners = YES;
    
    // --- 1. KÜÇÜK YUVARLAK YÜZEN BUTON (Açma/Kapama) ---
    UIButton *floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    floatingBtn.frame = CGRectMake(50, 100, 45, 45);
    floatingBtn.backgroundColor = [UIColor colorWithRed:0.12f green:0.12f blue:0.14f alpha:0.9f];
    [floatingBtn setTitle:@"⚡" forState:UIControlStateNormal];
    floatingBtn.titleLabel.font = [UIFont systemFontOfSize:22];
    floatingBtn.layer.cornerRadius = 22.5f;
    floatingBtn.layer.borderWidth = 2.0f;
    floatingBtn.layer.borderColor = [[UIColor systemPurpleColor] CGColor];
    [floatingBtn addTarget:self action:@selector(toggleMenuVisibility:) forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *floatPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragFloatingBtn:)];
    [floatingBtn addGestureRecognizer:floatPan];
    [self.view addSubview:floatingBtn];
    
    // --- 2. ANA PENCERE (GUI) ---
    self.mainWindowView = [[UIView alloc] initWithFrame:CGRectMake(50, 160, 280, 130)];
    self.mainWindowView.backgroundColor = [UIColor colorWithRed:0.12f green:0.10f blue:0.16f alpha:0.96f];
    self.mainWindowView.layer.cornerRadius = 8;
    self.mainWindowView.layer.borderWidth = 1.5f;
    self.mainWindowView.layer.borderColor = [[UIColor systemPurpleColor] CGColor];
    self.mainWindowView.hidden = YES;
    [self.view addSubview:self.mainWindowView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragWindow:)];
    [self.mainWindowView addGestureRecognizer:pan];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, 150, 25)];
    title.text = @"✨ Better Storage Esp";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:12];
    [self.mainWindowView addSubview:title];
    
    // Ayarlar Butonu (⚙️)
    UIButton *settingsBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    settingsBtn.frame = CGRectMake(200, 8, 32, 30);
    [settingsBtn setTitle:@"⚙️" forState:UIControlStateNormal];
    settingsBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [settingsBtn addTarget:self action:@selector(showSettingsMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.mainWindowView addSubview:settingsBtn];
    
    // Sağ Üst Kapatma Tuşu ("X")
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    closeBtn.frame = CGRectMake(240, 8, 30, 30);
    [closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [closeBtn addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.mainWindowView addSubview:closeBtn];
    
    // Ana Ekranda Storage ESP Modülü Toggle Tuşu
    [self createButtonOn:self.mainWindowView frame:CGRectMake(12, 45, 256, 36) title:@"Storage ESP [Modül]" state:self.isESPEnabled action:@selector(toggleMainESP:)];
    
    UILabel *subText = [[UILabel alloc] initWithFrame:CGRectMake(12, 92, 256, 20)];
    subText.text = @"Ayarlar için sağ üstteki ⚙️ simgesine tıklayın.";
    subText.textColor = [UIColor lightGrayColor];
    subText.font = [UIFont systemFontOfSize:9];
    subText.textAlignment = NSTextAlignmentCenter;
    [self.mainWindowView addSubview:subText];
    
    // Tracer/ESP Çizim Katmanı
    self.tracerOverlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.tracerOverlayView.backgroundColor = [UIColor clearColor];
    self.tracerOverlayView.userInteractionEnabled = NO;
    [self.view addSubview:self.tracerOverlayView];
    [self.view bringSubviewToFront:self.mainWindowView];
    
    // Çizim Döngüsü
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateESPAndTracers)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

// --- ⚙️ AYARLAR MENÜSÜ ---
- (void)showSettingsMenu:(UIButton *__strong)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Better Storage Esp - Ayarlar" message:@"Gelişmiş ESP filtrelerini ve modlarını buradan özelleştirin." preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Hafıza sızıntısını (Crash) önlemek için zayıf referans oluşturuyoruz
    __weak typeof(self) weakSelf = self;
    
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Alpha Değeri: %d (Değiştir)", self.alphaValue] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.alphaValue = (weakSelf.alphaValue == 255) ? 120 : (weakSelf.alphaValue == 120) ? 60 : 255;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Tracers: %@", self.isTracerEnabled ? @"AÇIK [■]" : @"KAPALI [ ]"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.isTracerEnabled = !weakSelf.isTracerEnabled;
    }]];
    
    NSString *shapeStr = (self.shapeMode == 0) ? @"Lines" : (self.shapeMode == 1) ? @"Sides" : @"Both";
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Shape Mode: %@ (Değiştir)", shapeStr] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.shapeMode = (weakSelf.shapeMode + 1) % 3;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Chests: %@", self.filterChests ? @"AÇIK [■]" : @"KAPALI [ ]"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.filterChests = !weakSelf.filterChests;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Ender Chests: %@", self.filterEnderChests ? @"AÇIK [■]" : @"KAPALI [ ]"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.filterEnderChests = !weakSelf.filterEnderChests;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Shulker Boxes: %@", self.filterShulkers ? @"AÇIK [■]" : @"KAPALI [ ]"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.filterShulkers = !weakSelf.filterShulkers;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Spawners: %@", self.filterSpawners ? @"AÇIK [■]" : @"KAPALI [ ]"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.filterSpawners = !weakSelf.filterSpawners;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Furnaces: %@", self.filterFurnaces ? @"AÇIK [■]" : @"KAPALI [ ]"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.filterFurnaces = !weakSelf.filterFurnaces;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Barrels: %@", self.filterBarrels ? @"AÇIK [■]" : @"KAPALI [ ]"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.filterBarrels = !weakSelf.filterBarrels;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Enchanting Tables: %@", self.filterEnchantingTables ? @"AÇIK [■]" : @"KAPALI [ ]"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.filterEnchantingTables = !weakSelf.filterEnchantingTables;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Pistons: %@", self.filterPistons ? @"AÇIK [■]" : @"KAPALI [ ]"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.filterPistons = !weakSelf.filterPistons;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Hoppers: %@", self.filterHoppers ? @"AÇIK [■]" : @"KAPALI [ ]"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.filterHoppers = !weakSelf.filterHoppers;
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Geri / Kapat" style:UIAlertActionStyleCancel handler:nil]];
    
    if (alert.popoverPresentationController) {
        alert.popoverPresentationController.sourceView = sender;
        alert.popoverPresentationController.sourceRect = sender.bounds;
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)toggleMenuVisibility:(UIButton *)sender {
    self.mainWindowView.hidden = !self.mainWindowView.hidden;
}

- (void)closeMenu {
    self.mainWindowView.hidden = YES;
}

- (void)dragFloatingBtn:(UIPanGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    if (!view) return;
    CGPoint translation = [gesture translationInView:self.view];
    CGPoint center = view.center;
    view.center = CGPointMake(center.x + translation.x, center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self.view];
}

- (void)createButtonOn:(UIView *)parent frame:(CGRect)frame title:(NSString *)title state:(BOOL)state action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor = state ? [UIColor colorWithRed:0.25f green:0.18f blue:0.35f alpha:1.0f] : [UIColor colorWithRed:0.15f green:0.15f blue:0.18f alpha:1.0f];
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

- (void)updateESPAndTracers {
    if (!self.isESPEnabled) {
        self.tracerOverlayView.layer.sublayers = nil;
        return;
    }
    
    // Her frame'de eski çizimleri temizliyoruz
    self.tracerOverlayView.layer.sublayers = nil;
    
    CGPoint crosshairCenter = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    CGRect sampleBoxRect = CGRectMake(160, 180, 45, 45); // Örnek hedef
    
    if (self.filterEnderChests) {
        float alphaFloat = (float)self.alphaValue / 255.0f;
        UIColor *boxColor = [UIColor colorWithRed:0.7f green:0.2f blue:1.0f alpha:alphaFloat];
        
        if (self.shapeMode != 0) { // Sides veya Both ise dolgu çiz
            CAShapeLayer *fillLayer = [CAShapeLayer layer];
            fillLayer.path = [UIBezierPath bezierPathWithRect:sampleBoxRect].CGPath;
            fillLayer.fillColor = [boxColor colorWithAlphaComponent:0.2f * alphaFloat].CGColor;
            [self.tracerOverlayView.layer addSublayer:fillLayer];
        }
        
        if (self.shapeMode != 1) { // Lines veya Both ise çerçeve çiz
            CAShapeLayer *borderLayer = [CAShapeLayer layer];
            borderLayer.path = [UIBezierPath bezierPathWithRect:sampleBoxRect].CGPath;
            borderLayer.strokeColor = boxColor.CGColor;
            borderLayer.fillColor = [UIColor clearColor].CGColor;
            borderLayer.lineWidth = 1.2f;
            [self.tracerOverlayView.layer addSublayer:borderLayer];
        }
        
        if (self.isTracerEnabled) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:crosshairCenter];
            [path addLineToPoint:CGPointMake(CGRectGetMidX(sampleBoxRect), CGRectGetMidY(sampleBoxRect))];
            
            CAShapeLayer *lineLayer = [CAShapeLayer layer];
            lineLayer.path = path.CGPath;
            lineLayer.strokeColor = boxColor.CGColor;
            lineLayer.lineWidth = 1.5f;
            [self.tracerOverlayView.layer addSublayer:lineLayer];
        }
    }
}

- (void)toggleMainESP:(UIButton *)sender {
    self.isESPEnabled = !self.isESPEnabled;
    sender.backgroundColor = self.isESPEnabled ? [UIColor colorWithRed:0.25f green:0.18f blue:0.35f alpha:1.0f] : [UIColor colorWithRed:0.15f green:0.15f blue:0.18f alpha:1.0f];
}

- (void)dealloc {
    [self.displayLink invalidate];
    [super dealloc];
}

@end

// Tekillik ve Crash Önleme Kontrolü
static BOOL isMenuLoaded = NO;

__attribute__((constructor)) static void init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isMenuLoaded) return;
        
        UIWindow *window = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        window = [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
        
        if (!window) {
            window = [UIApplication sharedApplication].windows.firstObject;
        }
        
        if (window) {
            isMenuLoaded = YES;
            StorageESPMenu *menu = [[StorageESPMenu alloc] init];
            menu.view.frame = window.bounds;
            menu.view.backgroundColor = [UIColor clearColor];
            [window addSubview:menu.view];
        }
    });
}
