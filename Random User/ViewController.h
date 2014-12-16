//
//  ViewController.h
//  Random User
//
//  Created by Jorge Valbuena on 2014-12-14.
//  Copyright (c) 2014 com.jorgedeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LABEL_ROW_HEIGHT 130
#define IMAGEVIEW_ROW_HEIGHT 370

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

