//
//  InterfaceController.h
//  AppleWatchHandMadeCalendar WatchKit Extension
//
//  Created by 酒井文也 on 2015/03/24.
//  Copyright (c) 2015年 just1factory. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *yearAndMonthLabel;

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *dayOfWeekLabel;

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *dayDisplay;

@end
