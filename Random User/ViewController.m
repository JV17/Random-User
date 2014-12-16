//
//  ViewController.m
//  Random User
//
//  Created by Jorge Valbuena on 2014-12-14.
//  Copyright (c) 2014 com.jorgedeveloper. All rights reserved.
//

#import "ViewController.h"
#import "FontAwesomeKit.h"
#import "KVNProgress.h"


@interface ViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableDictionary *json;

@property (nonatomic, strong) NSMutableDictionary *userInfo;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UILabel *myLbl;
@property (nonatomic, strong) UILabel *displayLbl;
@property (nonatomic, strong) UIButton *name;
@property (nonatomic, strong) UIButton *email;
@property (nonatomic, strong) UIButton *dob;
@property (nonatomic, strong) UIButton *address;
@property (nonatomic, strong) UIButton *phone;
@property (nonatomic, strong) UIButton *pass;
@property (nonatomic, strong) UIButton *user;
@property (nonatomic, strong) UIView *underline;

@property (nonatomic) BOOL newRandomUser;
@property (nonatomic) CGRect bounds;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // show HUD
    [KVNProgress showSuccessWithStatus:@"Loading"];
    
    self.bounds = [UIScreen mainScreen].bounds;
    self.userInfo = [[NSMutableDictionary alloc] init];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(getRandomUser)
                                                userInfo:nil
                                                 repeats:YES];
    
    [self ApiRequestWithURL:@"http://api.randomuser.me/" andUsername:@"" andPassword:@""];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API Request

-(void)ApiRequestWithURL:(NSString*)requestUrl andUsername:(NSString*)user andPassword:(NSString*)pass {

    NSString *post = [NSString stringWithFormat:@"Username=%@&Password=%@",user,pass];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:requestUrl]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               self.json = [NSJSONSerialization JSONObjectWithData:data 
                                                                      options:0
                                                                        error:nil];
//                               NSLog(@"Async JSON: %@", self.json);
                           }];
    
}

#pragma mark - User Setters

-(void)getRandomUserInfo {
    
    if ([self.json isKindOfClass:[NSDictionary class]])
    {
        NSArray *myDictionaryArray = self.json[@"results"];
        if ([myDictionaryArray isKindOfClass:[NSArray class]])
        {
            NSString *title, *first, *last, *email, *bday, *address, *phone, *pass;
            UIImage *image;
            
            // getting all user information
            for (NSDictionary *dictionary in myDictionaryArray)
            {
                title = [[[dictionary objectForKey:@"user"] objectForKey:@"name"] objectForKey:@"title"];
                first = [[[dictionary objectForKey:@"user"] objectForKey:@"name"] objectForKey:@"first"];
                last = [[[dictionary objectForKey:@"user"] objectForKey:@"name"] objectForKey:@"last"];
                email = [[dictionary objectForKey:@"user"] objectForKey:@"email"];
                bday = [[dictionary objectForKey:@"user"] objectForKey:@"dob"];
                address = [[[dictionary objectForKey:@"user"] objectForKey:@"location"] objectForKey:@"street"];
                phone = [[dictionary objectForKey:@"user"] objectForKey:@"cell"];
                pass = [[dictionary objectForKey:@"user"] objectForKey:@"password"];
                NSURL *imageURL = [NSURL URLWithString:[[[dictionary objectForKey:@"user"] objectForKey:@"picture"] objectForKey:@"medium"]];
                NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                image = [UIImage imageWithData:imageData];
            }

            // formatting user information
            title = [self capitalizeStringFromString:title];
            first = [self capitalizeStringFromString:first];
            last = [self capitalizeStringFromString:last];
            
            NSString *name = [NSString stringWithFormat:@"%@. %@ %@", title,first,last];
            
            // saving user information to dictionary
            [self.userInfo setObject:name forKey:@"fullname"];
            [self.userInfo setObject:email forKey:@"email"];
            [self.userInfo setObject:bday forKey:@"bday"];
            [self.userInfo setObject:address forKey:@"address"];
            [self.userInfo setObject:phone forKey:@"phone"];
            [self.userInfo setObject:pass forKey:@"password"];
            [self.userInfo setObject:image forKey:@"picture"];
            
            [self setupUI];
        }
    }
}

-(NSString*)capitalizeStringFromString:(NSString*)string {
    NSString *firstCapChar = [[string substringToIndex:1] capitalizedString];
    NSString *cappedString = [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstCapChar];
    return cappedString;
}

-(void)getRandomUser {
    
    if(self.json != nil){
        [self getRandomUserInfo];
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void)setupUI {
    
    self.titleLbl = [self myTitle];
    self.imageView = [self myImageView];
    self.line = [self myLine];
    self.myLbl = [self myLbl];
    self.displayLbl = [self myLabel];
    [self setAllIcons];
    self.underline = [self myUnderline];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    self.tableView.scrollEnabled = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    // Dismiss
    [KVNProgress dismiss];
}

#pragma mark - Getter and Settr

-(UIImageView*)myImageView {

    if(!_imageView || _imageView != nil) {
        _imageView = [[UIImageView alloc] initWithImage:[self.userInfo valueForKey:@"picture"]];
        _imageView.frame = CGRectMake(self.bounds.size.width/2-100, 140, 200, 200);
        _imageView.layer.backgroundColor = [[UIColor clearColor] CGColor];
        _imageView.layer.cornerRadius = 100;
        _imageView.layer.borderWidth = 1.0;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    }
    
    return _imageView;
}

-(UIView*)myLine {
    
    if(!_line || _line != nil) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, 240, self.bounds.size.width, 0.7)];
        _line.backgroundColor = [UIColor lightGrayColor];
        _line.alpha = 0.7;
    }
    
    return _line;
}

-(UIView*)myUnderline {
    
    if(!_underline || _underline != nil) {
        _underline = [[UIView alloc] initWithFrame:CGRectMake(self.name.frame.origin.x+4.5, self.bounds.size.height-IMAGEVIEW_ROW_HEIGHT-LABEL_ROW_HEIGHT-8, 20, 2)];
        _underline.backgroundColor = [UIColor blackColor];
        _underline.alpha = 0.9;
    }
    
    return _underline;
}

-(UILabel*)myTitle {
    
    if(!_titleLbl || _titleLbl != nil) {
        _titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, LABEL_ROW_HEIGHT)];
        _titleLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:34];
        _titleLbl.textAlignment = NSTextAlignmentCenter;
        _titleLbl.textColor = [UIColor blackColor];
        _titleLbl.text = @"Random User";
    }
    
    return _titleLbl;
}

-(UILabel*)myLabel {
    
    if(!_displayLbl || _displayLbl != nil) {
        _displayLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, self.bounds.size.width, LABEL_ROW_HEIGHT)];
        _displayLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24];
        _displayLbl.textAlignment = NSTextAlignmentCenter;
        _displayLbl.textColor = [UIColor blackColor];
        _displayLbl.text = [self.userInfo valueForKey:@"fullname"];
        _displayLbl.lineBreakMode = NSLineBreakByWordWrapping;
        _displayLbl.numberOfLines = 0;
    }
    
    return _displayLbl;
}

-(UILabel*)myLbl {
    
    if(!_myLbl || _myLbl != nil) {
        _myLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, -30, self.bounds.size.width, LABEL_ROW_HEIGHT)];
        _myLbl.font = [UIFont fontWithName:@"HelveticaNeue" size:22];
        _myLbl.textAlignment = NSTextAlignmentCenter;
        _myLbl.textColor = [UIColor lightGrayColor];
        _myLbl.text = @"Hi, My name is";
    }
    
    return _myLbl;
}

-(void)setAllIcons {
    
    CGFloat originY = self.bounds.size.height-IMAGEVIEW_ROW_HEIGHT-LABEL_ROW_HEIGHT-40;
    
    FAKFontAwesome *userIcon = [FAKFontAwesome userIconWithSize:30];
    [userIcon addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
    UIImage *userImage = [userIcon imageWithSize:CGSizeMake(30, 30)];
    self.name = [self createButton:self.name withTag:1 andFrame:CGRectMake(self.bounds.size.width*0.10, originY, 30, 30) andImage:userImage];
    
    FAKIonIcons *emailIcon = [FAKIonIcons emailIconWithSize:35];
    [emailIcon addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
    UIImage *userEmail = [emailIcon imageWithSize:CGSizeMake(35, 35)];
    self.email = [self createButton:self.name withTag:2 andFrame:CGRectMake(self.bounds.size.width*0.24, originY, 35, 35) andImage:userEmail];
    
    FAKFontAwesome *calendarIcon = [FAKFontAwesome calendarIconWithSize:25];
    [calendarIcon addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
    UIImage *userDob = [calendarIcon imageWithSize:CGSizeMake(25, 25)];
    self.dob = [self createButton:self.name withTag:3 andFrame:CGRectMake(self.bounds.size.width*0.405, originY+2, 25, 25) andImage:userDob];
    
    FAKFoundationIcons *mapIcon = [FAKFoundationIcons mapIconWithSize:27];
    [mapIcon addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
    UIImage *userLocation = [mapIcon imageWithSize:CGSizeMake(27, 27)];
    self.address = [self createButton:self.name withTag:4 andFrame:CGRectMake(self.bounds.size.width*0.55, originY+1, 27, 27) andImage:userLocation];
    
    FAKFontAwesome *phoneIcon = [FAKFontAwesome mobileIconWithSize:36];
    [phoneIcon addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
    UIImage *userPhone = [phoneIcon imageWithSize:CGSizeMake(36, 36)];
    self.phone = [self createButton:self.name withTag:5 andFrame:CGRectMake(self.bounds.size.width*0.68, originY-4, 36, 36) andImage:userPhone];
    
    FAKFontAwesome *lockIcon = [FAKFontAwesome lockIconWithSize:32];
    [lockIcon addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
    UIImage *userPass = [lockIcon imageWithSize:CGSizeMake(32, 32)];
    self.pass = [self createButton:self.name withTag:6 andFrame:CGRectMake(self.bounds.size.width*0.83, originY-1, 32, 32) andImage:userPass];
    
    FAKFontAwesome *refreshIcon = [FAKFontAwesome refreshIconWithSize:28];
    [refreshIcon addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
    UIImage *anotherUser = [refreshIcon imageWithSize:CGSizeMake(28, 28)];
    self.user = [self createButton:self.user withTag:7 andFrame:CGRectMake(self.bounds.size.width*0.90, 30, 28, 28) andImage:anotherUser];

}

-(UIButton*)createButton:(UIButton*)sender withTag:(NSInteger)tag andFrame:(CGRect)frame andImage:(UIImage*)image{
    
    sender = [[UIButton alloc] init];
    sender = [UIButton buttonWithType:UIButtonTypeCustom];
    sender.frame = frame;
    sender.tag = tag;
    [sender setBackgroundImage:image forState:UIControlStateNormal];
    if(tag == 7)
        [sender addTarget:self action:@selector(updateRandomUser:) forControlEvents:UIControlEventTouchUpInside];
    else
        [sender addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventTouchUpInside];
    
    return sender;
}

#pragma mark - UITableView Delegate & Datasource

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if(indexPath.row == 0) {
        [cell.contentView addSubview:self.titleLbl];
        [cell.contentView addSubview:self.user];
        [cell.contentView addSubview:self.line];
        [cell.contentView addSubview:self.imageView];
    }
    else if (indexPath.row == 1) {
        [cell.contentView addSubview:self.myLbl];
        [cell.contentView addSubview:self.displayLbl];
    }
    else {
        [cell.contentView addSubview:self.name];
        [cell.contentView addSubview:self.underline];
        [cell.contentView addSubview:self.email];
        [cell.contentView addSubview:self.dob];
        [cell.contentView addSubview:self.address];
        [cell.contentView addSubview:self.phone];
        [cell.contentView addSubview:self.pass];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0)
        return IMAGEVIEW_ROW_HEIGHT;
    if(indexPath.row == 1)
        return LABEL_ROW_HEIGHT;
    else
        return self.bounds.size.height-IMAGEVIEW_ROW_HEIGHT-LABEL_ROW_HEIGHT;
}


#pragma mark - Helper Functions

-(void)updateLabel:(UIButton*)btn {
    
    if(btn.tag == 1) {
        _myLbl.text = @"Hi, My name is";
        self.displayLbl.text = [self.userInfo valueForKey:@"fullname"];
        [self startShake:self.name];
        [self moveUnderline:self.underline toOriginX:self.name.frame.origin.x-0.5];
    }
    else if (btn.tag == 2) {
        _myLbl.text = @"My email address is";
        self.displayLbl.text = [self.userInfo valueForKey:@"email"];
        [self startShake:self.email];
        [self moveUnderline:self.underline toOriginX:self.email.frame.origin.x+2];
    }
    else if (btn.tag == 3) {
        _myLbl.text = @"My birthday is";
        self.displayLbl.text = [self.userInfo valueForKey:@"bday"];
        [self startShake:self.dob];
        [self moveUnderline:self.underline toOriginX:self.dob.frame.origin.x-3];
    }
    else if (btn.tag == 4) {
        _myLbl.text = @"My address is";
        self.displayLbl.text = [self.userInfo valueForKey:@"address"];
        [self startShake:self.address];
        [self moveUnderline:self.underline toOriginX:self.address.frame.origin.x-1.5];
    }
    else if (btn.tag == 5) {
        _myLbl.text = @"My phone number is";
        self.displayLbl.text = [self.userInfo valueForKey:@"phone"];
        [self startShake:self.phone];
        [self moveUnderline:self.underline toOriginX:self.phone.frame.origin.x+2.5];
    }
    else if (btn.tag == 6) {
        _myLbl.text = @"My password is";
        self.displayLbl.text = [self.userInfo valueForKey:@"password"];
        [self startShake:self.pass];
        [self moveUnderline:self.underline toOriginX:self.pass.frame.origin.x+1];
    }
    [self fadeInLabel:self.displayLbl];
}

-(void)updateRandomUser:(UIButton*)btn {
    
    self.userInfo = nil;
    self.json = nil;
    self.imageView = nil;
    self.line = nil;
    self.underline = nil;
    self.titleLbl = nil;
    self.myLbl = nil;
    self.displayLbl = nil;
    self.name = nil;
    self.email = nil;
    self.dob = nil;
    self.address = nil;
    self.phone = nil;
    self.pass = nil;
    self.tableView = nil;
    
    [self viewDidLoad];
    [self viewWillAppear:NO];
}

#pragma mark - UIView Animations

- (void)startShake:(UIView*)view
{
    CGAffineTransform leftShake = CGAffineTransformMakeTranslation(-5, 0);
    CGAffineTransform rightShake = CGAffineTransformMakeTranslation(5, 0);
    
    view.transform = leftShake;  // starting point
    
    [UIView beginAnimations:@"shake_button" context:(__bridge void *)(view)];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:3];
    [UIView setAnimationDuration:0.06];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(shakeEnded:finished:context:)];
    
    view.transform = rightShake; // end here & auto-reverse
    
    [UIView commitAnimations];
}

- (void)shakeEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([finished boolValue]) {
        UIView* item = (__bridge UIView *)context;
        item.transform = CGAffineTransformIdentity;
    }
}

- (void)moveUnderline:(UIView*)view toOriginX:(CGFloat)originX
{
    CGRect frame = self.underline.frame;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.underline.frame = CGRectMake(originX, frame.origin.y, frame.size.width, frame.size.height);
                     }
                     completion:^(BOOL finished){
                     }];
}

-(void)fadeInLabel:(UILabel*)lbl {
    
    self.displayLbl.alpha = 0.0;
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.displayLbl.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                     }];
    
}

@end
