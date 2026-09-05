#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface CardView : NSView @end
@implementation CardView
- (instancetype)initWithFrame:(NSRect)f { if((self=[super initWithFrame:f])){ self.wantsLayer=YES; CAGradientLayer*g=[CAGradientLayer layer];g.colors=@[(id)[NSColor colorWithWhite:1 alpha:1].CGColor,(id)[NSColor colorWithRed:.965 green:.972 blue:.985 alpha:1].CGColor];g.startPoint=CGPointMake(0,1);g.endPoint=CGPointMake(1,0);g.cornerRadius=14;[self.layer addSublayer:g]; self.layer.cornerRadius=14; self.layer.borderWidth=1; self.layer.borderColor=[NSColor colorWithWhite:0 alpha:.08].CGColor; self.layer.shadowColor=NSColor.blackColor.CGColor;self.layer.shadowOpacity=.08;self.layer.shadowRadius=18;self.layer.shadowOffset=CGSizeMake(0,-5); } return self; }
- (void)layout{[super layout];self.layer.sublayers.firstObject.frame=self.bounds;}
@end

@interface GraphView:NSView @property NSArray<NSNumber*>*values; @end
@implementation GraphView
- (BOOL)isFlipped{return YES;}
- (void)drawRect:(NSRect)dirty{[super drawRect:dirty];CGFloat w=self.bounds.size.width,h=self.bounds.size.height;[[NSColor colorWithWhite:0 alpha:.07]setStroke];for(int i=0;i<4;i++){NSBezierPath*p=[NSBezierPath bezierPath];[p moveToPoint:NSMakePoint(0,i*h/3)];[p lineToPoint:NSMakePoint(w,i*h/3)];p.lineWidth=1;[p stroke];}NSArray<NSNumber*>*v=self.values?:@[@42,@43,@45,@44,@47,@46,@50,@48,@52,@50,@54,@53,@57,@55,@59];NSBezierPath*line=[NSBezierPath bezierPath];for(NSUInteger i=0;i<v.count;i++){CGFloat x=w*i/(v.count-1),y=h-([v[i] doubleValue]-35)/30*h;y=MAX(5,MIN(h-5,y));if(i==0)[line moveToPoint:NSMakePoint(x,y)];else [line lineToPoint:NSMakePoint(x,y)];}line.lineWidth=2.5;line.lineJoinStyle=NSLineJoinStyleRound;[[NSColor colorWithRed:.25 green:.49 blue:.96 alpha:1]setStroke];[line stroke];[NSGraphicsContext.currentContext saveGraphicsState];NSShadow*s=[NSShadow new];s.shadowColor=[NSColor colorWithRed:.25 green:.49 blue:.96 alpha:.3];s.shadowBlurRadius=8;s.shadowOffset=NSZeroSize;[s set];[line stroke];[NSGraphicsContext.currentContext restoreGraphicsState];}
@end

@interface HealthIconView:NSView @end
@implementation HealthIconView
- (void)drawRect:(NSRect)d{NSRect r=NSInsetRect(self.bounds,2,2);[[NSColor colorWithRed:.33 green:.88 blue:.62 alpha:.12]setFill];[[NSBezierPath bezierPathWithOvalInRect:r]fill];[[NSColor colorWithRed:.33 green:.88 blue:.62 alpha:.28]setStroke];NSBezierPath*circle=[NSBezierPath bezierPathWithOvalInRect:r];circle.lineWidth=1;[circle stroke];NSBezierPath*check=[NSBezierPath bezierPath];[check moveToPoint:NSMakePoint(12,19)];[check lineToPoint:NSMakePoint(17,14)];[check lineToPoint:NSMakePoint(26,24)];check.lineWidth=2.2;check.lineCapStyle=NSLineCapStyleRound;[[NSColor colorWithRed:.35 green:.9 blue:.65 alpha:1]setStroke];[check stroke];}
@end

@interface RotorView:NSView @end
@implementation RotorView
- (BOOL)isOpaque{return NO;}
- (void)drawRect:(NSRect)d{NSPoint c=NSMakePoint(NSMidX(self.bounds),NSMidY(self.bounds));[[NSColor colorWithRed:.48 green:.65 blue:1 alpha:.9]setFill];for(int i=0;i<5;i++){CGFloat a=i*M_PI*2/5;NSAffineTransform*t=[NSAffineTransform transform];[t translateXBy:c.x yBy:c.y];[t rotateByRadians:a];NSBezierPath*blade=[NSBezierPath bezierPath];[blade moveToPoint:NSMakePoint(3,-3)];[blade curveToPoint:NSMakePoint(12,-30) controlPoint1:NSMakePoint(18,-8) controlPoint2:NSMakePoint(20,-24)];[blade curveToPoint:NSMakePoint(1,-11) controlPoint1:NSMakePoint(4,-33) controlPoint2:NSMakePoint(-2,-20)];[blade closePath];[blade transformUsingAffineTransform:t];[blade fill];}[[NSColor colorWithRed:.7 green:.8 blue:1 alpha:1]setFill];[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(c.x-7,c.y-7,14,14)]fill];}
@end

@interface FanGraphicView:NSView @property double rpm,angle; @property NSTimer*spinTimer; -(void)setFanRPM:(double)rpm; @end
@implementation FanGraphicView
- (instancetype)initWithFrame:(NSRect)frame{if((self=[super initWithFrame:frame])){_rpm=1000;_angle=0;}return self;}
- (void)viewDidMoveToWindow{[super viewDidMoveToWindow];[self.spinTimer invalidate];self.spinTimer=nil;if(self.window&&!NSWorkspace.sharedWorkspace.accessibilityDisplayShouldReduceMotion){__weak typeof(self)w=self;self.spinTimer=[NSTimer scheduledTimerWithTimeInterval:1.0/30 repeats:YES block:^(NSTimer*t){typeof(self)s=w;if(!s)return;double normalized=MAX(0,MIN(1,(s.rpm-800)/4200));s.angle+=.035+normalized*.12;s.needsDisplay=YES;}];}}
- (void)setFanRPM:(double)rpm{_rpm=rpm;}
- (void)drawRect:(NSRect)d{[super drawRect:d];double power=MAX(0,MIN(1,(self.rpm-800)/4200));NSPoint c=NSMakePoint(58,58);NSRect b=NSMakeRect(13,13,90,90);
  // Front-facing airflow: expanding pressure rings and radial particles.
  for(int i=0;i<4;i++){double phase=fmod(self.angle*.34+i*.25,1);CGFloat radius=17+phase*40;CGFloat fade=(1-phase)*(.16+power*.26);NSBezierPath*wave=[NSBezierPath bezierPath];CGFloat start=self.angle*34+i*76;[wave appendBezierPathWithArcWithCenter:c radius:radius startAngle:start endAngle:start+235];wave.lineWidth=.8+(1-phase)*1.1;CGFloat dash[2]={7+power*4,5};[wave setLineDash:dash count:2 phase:self.angle*8];[[NSColor colorWithRed:.46 green:.75 blue:1 alpha:fade]setStroke];[wave stroke];}
  for(int i=0;i<10;i++){double phase=fmod(self.angle*.42+i*.137,1);double theta=i*M_PI*2/10+self.angle*.13;CGFloat radius=13+phase*45;CGFloat px=c.x+cos(theta)*radius,py=c.y+sin(theta)*radius;CGFloat size=1.4+(1-phase)*1.8;[[NSColor colorWithRed:.66 green:.86 blue:1 alpha:(1-phase)*(.25+power*.5)]setFill];[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(px-size/2,py-size/2,size,size)]fill];}
  NSBezierPath*vortex=[NSBezierPath bezierPath];[vortex appendBezierPathWithArcWithCenter:c radius:31 startAngle:-self.angle*50 endAngle:-self.angle*50+280];vortex.lineWidth=1;[[NSColor colorWithRed:.48 green:.72 blue:1 alpha:.16+power*.2]setStroke];[vortex stroke];
  NSBezierPath*ring=[NSBezierPath bezierPathWithOvalInRect:b];ring.lineWidth=1.5;[[NSColor colorWithRed:.45 green:.64 blue:1 alpha:.32]setStroke];[ring stroke];
  [[NSColor colorWithRed:.48 green:.65 blue:1 alpha:.9]setFill];for(int i=0;i<5;i++){CGFloat a=self.angle+i*M_PI*2/5;NSAffineTransform*t=[NSAffineTransform transform];[t translateXBy:c.x yBy:c.y];[t rotateByRadians:a];NSBezierPath*blade=[NSBezierPath bezierPath];[blade moveToPoint:NSMakePoint(3,-3)];[blade curveToPoint:NSMakePoint(12,-30) controlPoint1:NSMakePoint(18,-8) controlPoint2:NSMakePoint(20,-24)];[blade curveToPoint:NSMakePoint(1,-11) controlPoint1:NSMakePoint(4,-33) controlPoint2:NSMakePoint(-2,-20)];[blade closePath];[blade transformUsingAffineTransform:t];[blade fill];}[[NSColor colorWithRed:.7 green:.8 blue:1 alpha:1]setFill];[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(c.x-7,c.y-7,14,14)]fill];}
@end

@interface FanTuneController : NSViewController
@property NSTextField *temperature, *rpm, *chipTitle, *profileTitle, *status;
@property NSTextField *healthText, *rangeText, *healthFanValue, *healthRangeValue;
@property NSTextField *airflowStatus;
@property FanGraphicView *fanGraphic;
@property NSSlider *slider;
@property NSButton *autoButton, *manualButton;
@property NSInteger selectedChip;
@property NSArray *temps;
@property NSString *helperPath;
@property NSString *socketPath;
@property NSString *installedHelperPath;
@property NSString *launchDaemonPath;
@property NSString *launchDaemonLabel;
@property NSTimer *heartbeat;
@property NSUInteger profileRequestID;
@property dispatch_queue_t controlQueue;
@property NSArray<NSButton*> *profileButtons;
@end

@implementation FanTuneController
- (NSTextField*)label:(NSString*)text size:(CGFloat)size weight:(NSFontWeight)weight color:(NSColor*)color {
  NSTextField *l=[NSTextField labelWithString:text]; l.font=[NSFont systemFontOfSize:size weight:weight]; l.textColor=color; return l;
}
- (NSButton*)button:(NSString*)title action:(SEL)action {
  NSButton *b=[NSButton buttonWithTitle:title target:self action:action];
  b.bordered=NO; b.wantsLayer=YES; b.layer.backgroundColor=[NSColor colorWithWhite:0 alpha:.045].CGColor; b.layer.cornerRadius=9;
  NSMutableParagraphStyle *p=[NSMutableParagraphStyle new]; p.alignment=NSTextAlignmentCenter;
  b.attributedTitle=[[NSAttributedString alloc]initWithString:title attributes:@{NSForegroundColorAttributeName:[NSColor colorWithWhite:.16 alpha:1],NSFontAttributeName:[NSFont systemFontOfSize:11 weight:NSFontWeightSemibold],NSParagraphStyleAttributeName:p}];
  return b;
}
- (void)active:(NSButton*)button yes:(BOOL)yes { button.layer.backgroundColor=(yes?[NSColor colorWithRed:.25 green:.48 blue:.94 alpha:1]:[NSColor colorWithWhite:0 alpha:.045]).CGColor; button.layer.borderWidth=yes?1:0; button.layer.borderColor=[NSColor colorWithRed:.2 green:.42 blue:.9 alpha:1].CGColor;NSMutableParagraphStyle*p=[NSMutableParagraphStyle new];p.alignment=NSTextAlignmentCenter;button.attributedTitle=[[NSAttributedString alloc]initWithString:button.title attributes:@{NSForegroundColorAttributeName:yes?NSColor.whiteColor:[NSColor colorWithWhite:.16 alpha:1],NSFontAttributeName:[NSFont systemFontOfSize:11 weight:NSFontWeightSemibold],NSParagraphStyleAttributeName:p}]; }
- (void)add:(NSView*)v to:(NSView*)p x:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h { v.frame=NSMakeRect(x,y,w,h); [p addSubview:v]; }
- (void)loadView {
  self.helperPath=[NSBundle.mainBundle pathForResource:@"fantune-smc" ofType:nil];
  self.socketPath=[NSString stringWithFormat:@"/tmp/fantune-smc-%u.sock",getuid()];
  self.launchDaemonLabel=@"com.fantune.smc-helper";
  self.installedHelperPath=@"/Library/PrivilegedHelperTools/com.fantune.smc-helper";
  self.launchDaemonPath=@"/Library/LaunchDaemons/com.fantune.smc-helper.plist";
  self.controlQueue=dispatch_queue_create("com.fantune.hardware-control",DISPATCH_QUEUE_SERIAL);
  self.temps=@[@47,@43,@36]; self.selectedChip=0;
  NSView *root=[[NSView alloc] initWithFrame:NSMakeRect(0,0,1040,720)]; root.wantsLayer=YES; CAGradientLayer*bg=[CAGradientLayer layer];bg.colors=@[(id)[NSColor colorWithRed:.965 green:.975 blue:.995 alpha:1].CGColor,(id)[NSColor colorWithRed:.91 green:.93 blue:.965 alpha:1].CGColor];bg.startPoint=CGPointMake(0,1);bg.endPoint=CGPointMake(1,0);bg.frame=root.bounds;[root.layer addSublayer:bg]; self.view=root;
  NSColor *white=[NSColor colorWithWhite:.11 alpha:1],*muted=[NSColor colorWithWhite:.43 alpha:1],*blue=[NSColor colorWithRed:.22 green:.46 blue:.92 alpha:1];
  [self add:[self label:@"●  现在很舒服" size:11 weight:NSFontWeightMedium color:[NSColor colorWithRed:.35 green:.86 blue:.62 alpha:1]] to:root x:36 y:677 w:200 h:18];
  [self add:[self label:@"让 Mac 凉快一下" size:30 weight:NSFontWeightBold color:white] to:root x:36 y:632 w:360 h:42];
  [self add:[self label:@"热了就吹吹风，忙起来也不慌。" size:12 weight:NSFontWeightRegular color:muted] to:root x:36 y:611 w:300 h:18];
  NSArray *names=@[@"Apple M3 Max\nCPU        47°",@"40 核\nGPU        43°",@"2 TB\nSSD        36°"];
  for(int i=0;i<3;i++){ NSButton *b=[self button:names[i] action:@selector(selectChip:)]; b.tag=100+i; [self add:b to:root x:36+i*322 y:532 w:310 h:65]; [self active:b yes:i==0]; }
  CardView *tempCard=[[CardView alloc]initWithFrame:NSZeroRect]; [self add:tempCard to:root x:36 y:240 w:620 h:276];
  self.chipTitle=[self label:@"CPU 温度" size:11 weight:NSFontWeightSemibold color:muted]; [self add:self.chipTitle to:tempCard x:22 y:235 w:150 h:18];
  self.temperature=[self label:@"47°C" size:46 weight:NSFontWeightSemibold color:white]; [self add:self.temperature to:tempCard x:20 y:178 w:180 h:56];
  [self add:[self label:@"↘ 3°\n过去 5 分钟" size:11 weight:NSFontWeightMedium color:[NSColor colorWithRed:.35 green:.86 blue:.62 alpha:1]] to:tempCard x:500 y:205 w:95 h:38];
  GraphView*graph=[GraphView new];[self add:graph to:tempCard x:25 y:55 w:570 h:118];
  NSArray<NSString*>*times=@[@"10:20",@"10:25",@"10:30",@"10:35",@"现在"];
  for(int i=0;i<5;i++){NSTextField*t=[self label:times[i] size:9 weight:NSFontWeightRegular color:muted];t.alignment=i==0?NSTextAlignmentLeft:(i==4?NSTextAlignmentRight:NSTextAlignmentCenter);CGFloat x=25+i*131.25;[self add:t to:tempCard x:x y:28 w:45 h:18];}
  CardView *fan=[[CardView alloc]initWithFrame:NSZeroRect]; [self add:fan to:root x:672 y:240 w:332 h:276];
  [self add:[self label:@"风扇转速" size:11 weight:NSFontWeightSemibold color:muted] to:fan x:22 y:235 w:120 h:18];
  self.rpm=[self label:@"1,849 RPM" size:26 weight:NSFontWeightBold color:white]; [self add:self.rpm to:fan x:20 y:198 w:220 h:34];
  self.fanGraphic=[FanGraphicView new];[self add:self.fanGraphic to:fan x:18 y:80 w:140 h:116];
  self.airflowStatus=[self label:@"小风慢慢吹\n适合阅读、写作和摸鱼" size:13 weight:NSFontWeightMedium color:blue];[self add:self.airflowStatus to:fan x:178 y:123 w:142 h:45];
  self.slider=[NSSlider sliderWithValue:1849 minValue:1000 maxValue:5200 target:self action:@selector(slide:)]; self.slider.enabled=NO; self.slider.continuous=NO; [self add:self.slider to:fan x:22 y:50 w:288 h:26];
  self.rangeText=[self label:@"1,000                         5,200" size:9 weight:NSFontWeightRegular color:muted]; [self add:self.rangeText to:fan x:22 y:29 w:288 h:16];
  CardView *profile=[[CardView alloc]initWithFrame:NSZeroRect]; [self add:profile to:root x:36 y:55 w:620 h:169];
  [self add:[self label:@"吹风方式" size:11 weight:NSFontWeightSemibold color:muted] to:profile x:22 y:128 w:120 h:18]; self.profileTitle=[self label:@"舒服吹" size:21 weight:NSFontWeightBold color:white]; [self add:self.profileTitle to:profile x:22 y:98 w:120 h:28];
  NSArray *profiles=@[@"☾  悄悄吹\n轻轻散热，尽量不出声",@"◇  舒服吹\n不吵也不热，日常刚好",@"ϟ  大力吹\n重活和高负载都安排上"];
  NSMutableArray*profileList=[NSMutableArray array];for(int i=0;i<3;i++){NSButton*b=[self button:profiles[i] action:@selector(selectProfile:)];b.tag=200+i;[self add:b to:profile x:20+i*195 y:22 w:183 h:62];[self active:b yes:i==1];[profileList addObject:b];}self.profileButtons=profileList;
  CardView *health=[[CardView alloc]initWithFrame:NSZeroRect]; [self add:health to:root x:672 y:55 w:332 h:169];
  [self add:[self label:@"散热系统" size:11 weight:NSFontWeightSemibold color:muted] to:health x:22 y:128 w:120 h:18];
  HealthIconView*ok=[HealthIconView new];[self add:ok to:health x:22 y:78 w:40 h:40];
  [self add:[self label:@"现在很舒服" size:15 weight:NSFontWeightSemibold color:white] to:health x:75 y:99 w:180 h:21];
  [self add:[self label:@"温度不错，风扇也很有精神" size:9 weight:NSFontWeightRegular color:muted] to:health x:75 y:82 w:210 h:16];
  NSBox*healthLine=[NSBox new];healthLine.boxType=NSBoxSeparator;[self add:healthLine to:health x:22 y:65 w:288 h:1];
  self.healthFanValue=[self label:@"—" size:14 weight:NSFontWeightSemibold color:white];[self add:self.healthFanValue to:health x:22 y:37 w:75 h:19];
  [self add:[self label:@"风扇" size:8 weight:NSFontWeightRegular color:muted] to:health x:22 y:22 w:75 h:14];
  [self add:[self label:@"AppleSMC" size:13 weight:NSFontWeightSemibold color:white] to:health x:115 y:37 w:85 h:19];
  [self add:[self label:@"控制接口" size:8 weight:NSFontWeightRegular color:muted] to:health x:115 y:22 w:75 h:14];
  self.healthRangeValue=[self label:@"—" size:13 weight:NSFontWeightSemibold color:white];[self add:self.healthRangeValue to:health x:218 y:37 w:92 h:19];
  [self add:[self label:@"RPM 范围" size:8 weight:NSFontWeightRegular color:muted] to:health x:218 y:22 w:75 h:14];
  for(NSNumber*x in @[@105,@208]){NSBox*v=[NSBox new];v.boxType=NSBoxSeparator;[self add:v to:health x:x.doubleValue y:22 w:1 h:34];}
  self.status=[self label:@"" size:10 weight:NSFontWeightRegular color:muted];
  [self refreshHardware];
  self.heartbeat=[NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer*t){ if([[NSFileManager defaultManager]fileExistsAtPath:self.socketPath])[self run:@[@"send",self.socketPath,@"PING"] privileged:NO]; }];
}
- (NSString*)run:(NSArray<NSString*>*)args privileged:(BOOL)privileged {
  if(!self.helperPath)return @"硬件控制组件缺失";
  NSTask *task=[NSTask new]; NSPipe *pipe=[NSPipe pipe]; task.standardOutput=pipe; task.standardError=pipe;
  if(privileged){
    NSString *cmd=[NSString stringWithFormat:@"'%@' %@",[self.helperPath stringByReplacingOccurrencesOfString:@"'" withString:@"'\\''"],[args componentsJoinedByString:@" "]];
    NSString *script=[NSString stringWithFormat:@"do shell script %@ with administrator privileges",[NSString stringWithFormat:@"\"%@\"",[cmd stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]]];
    task.executableURL=[NSURL fileURLWithPath:@"/usr/bin/osascript"]; task.arguments=@[@"-e",script];
  } else { task.executableURL=[NSURL fileURLWithPath:self.helperPath]; task.arguments=args; }
  @try{[task launch];[task waitUntilExit];NSData*d=[[pipe fileHandleForReading]readDataToEndOfFile];NSString*out=[[NSString alloc]initWithData:d encoding:NSUTF8StringEncoding];return task.terminationStatus==0?out:[NSString stringWithFormat:@"控制失败：%@",out.length?out:@"未知错误"];}@catch(NSException*e){return [NSString stringWithFormat:@"控制失败：%@",e.reason];}
}
- (void)refreshHardware {
  NSString *out=[self run:@[@"list"] privileged:NO]; NSData*d=[out dataUsingEncoding:NSUTF8StringEncoding]; NSDictionary*j=d?[NSJSONSerialization JSONObjectWithData:d options:0 error:nil]:nil; NSArray*fans=j[@"fans"];
  if(fans.count){NSDictionary*f=fans[0];double actual=[f[@"actual"]doubleValue],target=[f[@"target"]doubleValue],lo=[f[@"min"]doubleValue],hi=[f[@"max"]doubleValue];NSInteger mode=[f[@"mode"]integerValue];if(hi>lo){self.slider.minValue=lo;self.slider.maxValue=hi;self.slider.doubleValue=MAX(lo,actual);self.rpm.stringValue=[NSString stringWithFormat:@"%.0f RPM",actual];[self.fanGraphic setFanRPM:actual];self.rangeText.stringValue=[NSString stringWithFormat:@"%.0f                         %.0f",lo,hi];self.healthFanValue.stringValue=[NSString stringWithFormat:@"%ld",fans.count];self.healthRangeValue.stringValue=[NSString stringWithFormat:@"%.0f–%.0f",lo,hi];NSInteger selected=(mode==0||mode==3)?0:(target>=hi*.9?2:1);for(NSButton*b in self.profileButtons)[self active:b yes:b.tag==200+selected];self.profileTitle.stringValue=@[@"悄悄吹",@"舒服吹",@"大力吹"][selected];self.airflowStatus.stringValue=selected==0?@"小风慢慢吹\n适合阅读、写作和摸鱼":(selected==1?@"清风营业中\n凉快一点，声音少一点":@"火力全开\n会有风声，降温很认真");self.slider.enabled=selected!=0;self.status.stringValue=[NSString stringWithFormat:@"风扇已经听你指挥 · %ld 个风扇",fans.count];}}
  else self.status.stringValue=@"未检测到可控风扇（MacBook Air 等无风扇机型不支持）";
}
- (BOOL)installPersistentHelper {
  self.status.stringValue=@"首次启用需要管理员授权…";
  NSString *temporaryPlist=[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%u.plist",self.launchDaemonLabel,getuid()]];
  NSDictionary *configuration=@{
    @"Label":self.launchDaemonLabel,
    @"ProgramArguments":@[self.installedHelperPath,@"serve",self.socketPath,[NSString stringWithFormat:@"%u",getuid()]],
    @"RunAtLoad":@YES,
    @"KeepAlive":@YES,
    @"ProcessType":@"Interactive",
    @"StandardOutPath":@"/tmp/fantune-smc.log",
    @"StandardErrorPath":@"/tmp/fantune-smc.log"
  };
  if(![configuration writeToFile:temporaryPlist atomically:YES]){self.status.stringValue=@"辅助服务配置失败";return NO;}
  NSString *(^quote)(NSString*)=^NSString*(NSString *value){return [NSString stringWithFormat:@"'%@'",[value stringByReplacingOccurrencesOfString:@"'" withString:@"'\\''"]];};
  NSString *command=[NSString stringWithFormat:@"/usr/bin/install -d -m 755 /Library/PrivilegedHelperTools; /usr/bin/install -m 755 %@ %@; /usr/bin/install -m 644 %@ %@; /bin/launchctl bootout system/%@ >/dev/null 2>&1 || true; /bin/launchctl bootstrap system %@",quote(self.helperPath),quote(self.installedHelperPath),quote(temporaryPlist),quote(self.launchDaemonPath),self.launchDaemonLabel,quote(self.launchDaemonPath)];
  NSTask *task=[NSTask new];NSPipe*p=[NSPipe pipe];task.standardOutput=p;task.standardError=p;task.executableURL=[NSURL fileURLWithPath:@"/usr/bin/osascript"];
  NSString *script=[NSString stringWithFormat:@"do shell script %@ with administrator privileges",[NSString stringWithFormat:@"\"%@\"",[command stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]]];task.arguments=@[@"-e",script];
  @try{[task launch];[task waitUntilExit];} @catch(NSException*e){[[NSFileManager defaultManager]removeItemAtPath:temporaryPlist error:nil];self.status.stringValue=@"辅助服务安装失败";return NO;}
  NSData*d=[[p fileHandleForReading]readDataToEndOfFile];NSString*detail=[[NSString alloc]initWithData:d encoding:NSUTF8StringEncoding];
  [[NSFileManager defaultManager]removeItemAtPath:temporaryPlist error:nil];
  if(task.terminationStatus!=0){self.status.stringValue=[NSString stringWithFormat:@"辅助服务安装失败：%@",detail.length?detail:@"授权已取消"];return NO;}
  return YES;
}
- (BOOL)ensureDaemon {
  BOOL installed=[[NSFileManager defaultManager]fileExistsAtPath:self.installedHelperPath]&&[[NSFileManager defaultManager]fileExistsAtPath:self.launchDaemonPath];
  if(installed&&[[NSFileManager defaultManager]fileExistsAtPath:self.socketPath]){
    NSString *ping=[self run:@[@"send",self.socketPath,@"PING"] privileged:NO];
    if([ping hasPrefix:@"OK"])return YES;
    [[NSFileManager defaultManager]removeItemAtPath:self.socketPath error:nil];
  }
  if(![self installPersistentHelper])return NO;
  for(int i=0;i<30;i++){usleep(100000);if([[NSFileManager defaultManager]fileExistsAtPath:self.socketPath]){NSString*ping=[self run:@[@"send",self.socketPath,@"PING"] privileged:NO];if([ping hasPrefix:@"OK"])return YES;}}
  NSString*detail=[[NSString alloc]initWithContentsOfFile:@"/tmp/fantune-smc.log" encoding:NSUTF8StringEncoding error:nil];self.status.stringValue=[NSString stringWithFormat:@"辅助服务启动失败：%@",detail.length?detail:@"未生成 Socket"];return NO;
}
- (NSString*)hardware:(NSString*)command { if(![self ensureDaemon])return @"控制失败：辅助服务不可用";return [self run:@[@"send",self.socketPath,command] privileged:NO]; }
- (void)setMode:(NSButton*)sender {
  BOOL manual=sender.tag==1;
  NSString*r=[self hardware:manual?[NSString stringWithFormat:@"SET %.0f",self.slider.doubleValue]:@"AUTO"];
  if(![r hasPrefix:@"OK"]){self.status.stringValue=r;return;}
  self.slider.enabled=manual; [self active:self.autoButton yes:!manual]; [self active:self.manualButton yes:manual]; self.status.stringValue=manual?@"真实硬件控制中 · 拖动滑杆可调节":@"已归还 macOS 自动温控";
}
- (void)selectChip:(NSButton*)sender { NSInteger i=sender.tag-100; self.selectedChip=i; for(NSView*v in self.view.subviews)if([v isKindOfClass:NSButton.class]&&v.tag>=100&&v.tag<103)[self active:(NSButton*)v yes:v.tag==sender.tag]; NSArray*n=@[@"CPU 温度",@"GPU 温度",@"SSD 温度"]; self.chipTitle.stringValue=n[i]; self.temperature.stringValue=[NSString stringWithFormat:@"%@°C",self.temps[i]]; self.status.stringValue=[NSString stringWithFormat:@"已切换至 %@ · 演示数据",@[@"CPU",@"GPU",@"SSD"][i]]; }
- (void)slide:(NSSlider*)s { self.rpm.stringValue=[NSString stringWithFormat:@"%ld RPM",(long)s.integerValue];[self.fanGraphic setFanRPM:s.doubleValue];double p=(s.doubleValue-s.minValue)/(s.maxValue-s.minValue);self.airflowStatus.stringValue=p<.35?@"小风慢慢吹\n轻轻散热，尽量不出声":(p<.75?@"清风营业中\n凉快一点，声音少一点":@"火力全开\n会有风声，降温很认真");NSString*r=[self hardware:[NSString stringWithFormat:@"SET %ld",(long)s.integerValue]];self.status.stringValue=[r hasPrefix:@"OK"]?@"好啦，已经调整好了":r; }
- (void)restoreAuto { if([[NSFileManager defaultManager]fileExistsAtPath:self.socketPath])[self run:@[@"send",self.socketPath,@"AUTO"] privileged:NO]; }
- (void)selectProfile:(NSButton*)sender {
  NSInteger i=sender.tag-200; NSString *name=@[@"悄悄吹",@"舒服吹",@"大力吹"][i];
  for(NSView*v in sender.superview.subviews)if([v isKindOfClass:NSButton.class]&&v.tag>=200&&v.tag<203)[self active:(NSButton*)v yes:v.tag==sender.tag];
  self.profileTitle.stringValue=name; BOOL manual=i!=0; self.slider.enabled=manual;
  self.airflowStatus.stringValue=i==0?@"小风慢慢吹\n适合阅读、写作和摸鱼":(i==1?@"清风营业中\n凉快一点，声音少一点":@"火力全开\n会有风声，降温很认真");
  double target=i==1?self.slider.minValue+(self.slider.maxValue-self.slider.minValue)*.62:self.slider.maxValue;
  if(manual){self.slider.doubleValue=target;self.rpm.stringValue=[NSString stringWithFormat:@"%.0f RPM",target];[self.fanGraphic setFanRPM:target];}
  NSUInteger request=++self.profileRequestID; NSString*command=i==0?@"AUTO":[NSString stringWithFormat:@"SET %.0f",target];
  dispatch_async(self.controlQueue,^{NSString*result=[self hardware:command];dispatch_async(dispatch_get_main_queue(),^{if(request!=self.profileRequestID)return;if(![result hasPrefix:@"OK"]){NSAlert*a=[NSAlert new];a.messageText=@"风扇没听清";a.informativeText=@"这次没有调整成功，再试一次吧。";a.alertStyle=NSAlertStyleWarning;[a beginSheetModalForWindow:self.view.window completionHandler:nil];return;}self.status.stringValue=@"好啦，已经调整好了";});});
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate> @property NSWindow *window; @property FanTuneController *controller; @end
@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification*)note { self.controller=[FanTuneController new]; self.window=[[NSWindow alloc]initWithContentRect:NSMakeRect(0,0,1040,720) styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskMiniaturizable backing:NSBackingStoreBuffered defer:NO]; self.window.title=@"FanTune"; self.window.titlebarAppearsTransparent=YES; self.window.appearance=[NSAppearance appearanceNamed:NSAppearanceNameAqua]; self.window.backgroundColor=[NSColor colorWithWhite:.96 alpha:1]; self.window.contentViewController=self.controller; [self.window center]; [self.window makeKeyAndOrderFront:nil]; [NSApp activateIgnoringOtherApps:YES]; }
- (void)applicationWillTerminate:(NSNotification*)notification { [self.controller restoreAuto]; }
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender{return YES;}
@end
int main(int argc,const char*argv[]){@autoreleasepool{NSApplication*app=NSApplication.sharedApplication;AppDelegate*d=[AppDelegate new];app.delegate=d;[app run];}return 0;}
