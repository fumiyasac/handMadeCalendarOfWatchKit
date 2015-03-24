//
//  InterfaceController.m
//  AppleWatchHandMadeCalendar WatchKit Extension
//
//  Created by 酒井文也 on 2015/03/24.
//  Copyright (c) 2015年 just1factory. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController() {
    
    //カレンダー表示用メンバ変数
    NSDate *now;
    int year;
    int month;
    int day;
    int maxDay;
    int dayOfWeek;
    
    //カレンダーから取得したものを格納する
    NSUInteger flags;
    NSDateComponents *comps;
    
    //ボタンのフォントカラー
    UIColor *calendarFontColor;
    
    /* ----------- 祝日判定計算用メンバ変数（はじめ） -----------*/
    //9月の国民の祝日判定用変数
    int kokumin;
    //5月のゴールデンウィークが日曜日と重なる場合の判定用変数
    bool goldenWeekFlag;
    /* ----------- 祝日判定計算用メンバ変数（おわり） -----------*/
    
    NSArray *monthName;
}
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    
    //曜日を取得
    monthName = [NSArray arrayWithObjects:@"(日)",@"(月)",@"(火)",@"(水)",@"(木)",@"(金)",@"(土)", nil];
    
    //現在の日付を取得
    now = [NSDate date];
    
    //inUnit:で指定した単位（月）の中で、rangeOfUnit:で指定した単位（日）が取り得る範囲
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:now];
    
    //最初にメンバ変数に格納するための現在日付の情報を取得する
    flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    comps = [calendar components:flags fromDate:now];
    
    //年月日と最後の日付を取得(NSIntegerをintへ変換)
    NSInteger orgYear      = comps.year;
    NSInteger orgMonth     = comps.month;
    NSInteger orgDay       = comps.day;
    NSInteger orgDayOfWeek = comps.weekday;
    NSInteger max          = range.length;
    
    year      = (int)orgYear;
    month     = (int)orgMonth;
    day       = (int)orgDay;
    dayOfWeek = (int)orgDayOfWeek;
    
    //月末日(NSIntegerをintへ変換)
    maxDay = (int)max;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    //現在のカレンダーを表示
    [self displayCalendar];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)prevButtonTapped {
    
    //前の日を設定する
    day = day - 1;
    [self setupDayCalendar];
}

- (IBAction)nextButtonTapped {
    
    //次の日を設定する
    day = day + 1;
    [self setupDayCalendar];
}

- (void)displayCalendar {
    
    //1. 年月を取得
    NSString *yearAndMonthStr = [NSString stringWithFormat:@"%d年%d月", year, month];
    [self.yearAndMonthLabel setText:yearAndMonthStr];
    
    //2. 曜日を取得
    int youbiKey = dayOfWeek - 1;
    [self.dayOfWeekLabel setText:monthName[youbiKey]];
    
    //3. 日を取得
    [self.dayDisplay setText:[NSString stringWithFormat:@"%d", day]];
    
    //4. 祝祭日の判定をする
    BOOL holidayFlag = [self holidayCalc:year tMonth:month tDay:(int)day tIndex:youbiKey];
    
    UIColor *defaultColor = [UIColor whiteColor];
    UIColor *holidayColor = [UIColor colorWithRed:0.831 green:0.349 blue:0.224 alpha:1.0];
    UIColor *saturdayColor = [UIColor colorWithRed:0.400 green:0.471 blue:0.980 alpha:1.0];
    
    //ボタンデザインと配色の決定
    if(youbiKey == 0){
        
        [self.dayOfWeekLabel setTextColor:holidayColor];
        [self.yearAndMonthLabel setTextColor:holidayColor];
        [self.dayDisplay setTextColor:holidayColor];
        
    }else if(youbiKey == 6){
        
        //祝日フラグの判定
        if(holidayFlag){
            
            [self.dayOfWeekLabel setText:@"(祝)"];
            [self.dayOfWeekLabel setTextColor:holidayColor];
            [self.yearAndMonthLabel setTextColor:holidayColor];
            [self.dayDisplay setTextColor:holidayColor];
            
        }else{
            [self.dayOfWeekLabel setTextColor:saturdayColor];
            [self.yearAndMonthLabel setTextColor:saturdayColor];
            [self.dayDisplay setTextColor:saturdayColor];
        }
        
    }else{
        
        //祝日フラグの判定
        if(holidayFlag){
            
            [self.dayOfWeekLabel setText:@"(祝)"];
            [self.dayOfWeekLabel setTextColor:holidayColor];
            [self.yearAndMonthLabel setTextColor:holidayColor];
            [self.dayDisplay setTextColor:holidayColor];
            
        }else{
            [self.dayOfWeekLabel setTextColor:defaultColor];
            [self.yearAndMonthLabel setTextColor:defaultColor];
            [self.dayDisplay setTextColor:defaultColor];
        }
        
    }
    
}

- (void)setupDayCalendar {
    
    //inUnit:で指定した単位（月）の中で、rangeOfUnit:で指定した単位（日）が取り得る範囲
    NSCalendar *nextCalendar = [NSCalendar currentCalendar];
    NSDateComponents *nextComps = [[NSDateComponents alloc] init];
    
    //該当月の1日の情報を取得する（※カレンダーが始まる場所を取得するため）
    [nextComps setYear:year];
    [nextComps setMonth:month];
    [nextComps setDay:day];
    NSDate *nextDate = [nextCalendar dateFromComponents:nextComps];
    
    //カレンダー情報を再作成する
    [self recreateCalendarParameter:nextCalendar dateObject:nextDate];
}

//カレンダーのパラメータを作成する関数
- (void)recreateCalendarParameter:(NSCalendar *)currentCalendar dateObject:(NSDate *)currentDate
{
    flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    comps = [currentCalendar components:flags fromDate:currentDate];
    
    NSRange currentRange = [currentCalendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:currentDate];
    
    //年月日と最後の日付を取得(NSIntegerをintへ変換)
    NSInteger currentYear      = comps.year;
    NSInteger currentMonth     = comps.month;
    NSInteger currentDay       = comps.day;
    NSInteger currentDayOfWeek = comps.weekday;
    NSInteger currentMax       = currentRange.length;
    
    year      = (int)currentYear;
    month     = (int)currentMonth;
    day       = (int)currentDay;
    dayOfWeek = (int)currentDayOfWeek;
    maxDay    = (int)currentMax;
    
    [self displayCalendar];
}

//祝日を判定する
/* ----------- 祝日計算用の関数（はじめ） -----------*/
- (BOOL)holidayCalc:(int)tYear tMonth:(int)tMonth tDay:(int)tagNumber tIndex:(int)i{
    
    //春分・秋分の計算式
    int y2 = (tYear - 2000);
    int syunbun = (int)(20.69115 + 0.2421904 * y2 - (int)(y2/4 + y2/100 + y2/400));
    int syuubun = (int)(23.09000 + 0.2421904 * y2 - (int)(y2/4 + y2/100 + y2/400));
    bool holidayFlag = false;
    
    if ((tMonth == 1) && (tagNumber == 1)) {
        
        //元日（1月1日なら）
        holidayFlag = true;
    }
    else if ((tMonth == 1) && (i % 7 == 1) && (tagNumber == 2)) {
        
        //元日の振替休日（1月2日が月曜なら）
        holidayFlag = true;
    }
    else if ((tMonth == 1) && ( (i == 8 || i == 15) && (tagNumber >= 8 && tagNumber <= 14) ) && (i % 7 == 1)) {
        
        //成人の日（1月の第2月曜なら）
        holidayFlag = true;
    }
    else if ((tMonth == 2) && (tagNumber == 11)) {
        
        //建国記念の日（2月11日なら）
        holidayFlag = true;
    }
    else if ((tMonth == 2) && (tagNumber == 12) && (i % 7 == 1)) {
        
        //建国記念の日の振替休日（2月12日が月曜なら）
        holidayFlag = true;
    }
    else if ((tYear  > 1999) && (tMonth == 3) && (tagNumber == syunbun)) {
        
        //春分の日（計算式による）
        holidayFlag = true;
    }
    else if ((tYear  > 1999) && (tMonth == 3) && (tagNumber == (syunbun + 1)) && (i % 7 == 1)) {
        
        //春分の日の振替休日
        holidayFlag = true;
    }
    else if ((tMonth == 4) && (tagNumber == 29)) {
        
        //2006年みどりの日（4月29日なら）
        holidayFlag = true;
    }
    else if ((tMonth == 4) && (tagNumber == 30) && (i % 7 == 1)) {
        
        //みどりの日の振替休日（4月30日が月曜なら）
        holidayFlag = true;
    }
    else if ((tMonth == 5) && (tagNumber == 3)) {
        if ((tYear > 2006) && (i % 7 == 0)) {
            goldenWeekFlag = true;
        }else{
            goldenWeekFlag = false;
        }
        holidayFlag = true;
    }
    else if (
             ((tYear < 2007) && (tMonth == 5) && (tagNumber == 4) && (i % 7 == 2)) ||
             ((tYear < 2007) && (tMonth == 5) && (tagNumber == 4) && (i % 7 == 3)) ||
             ((tYear < 2007) && (tMonth == 5) && (tagNumber == 4) && (i % 7 == 4)) ||
             ((tYear < 2007) && (tMonth == 5) && (tagNumber == 4) && (i % 7 == 5)) ||
             ((tYear < 2007) && (tMonth == 5) && (tagNumber == 4) && (i % 7 == 6))
             ) {
        
        //国民の休日（5月4日が火～土曜日なら）
        holidayFlag = true;
    }
    else if ((tYear > 2006) && (tMonth == 5) && (tagNumber == 4)) {
        
        //2007年以降みどりの日（5月4日なら）
        if ((tYear > 2006) && (goldenWeekFlag != true) && (i % 7 == 0)) {
            //みどりの日が日曜なら
            goldenWeekFlag = true;
        }
        holidayFlag = true;
    }
    else if ((tMonth == 5) && (tagNumber == 5)) {
        
        //こどもの日（5月5日なら）
        if ((tYear > 2006) && (goldenWeekFlag != true) && (i % 7 == 0)) {
            //こどもの日が日曜なら
            goldenWeekFlag = true;
        }
        holidayFlag = true;
    }
    else if ((tYear < 2007) && (tMonth == 5) && (tagNumber == 6) && (i % 7 == 1)) {
        
        //こどもの日の振替休日（5月6日が月曜なら）
        holidayFlag = true;
    }
    else if ((tYear > 2006) && (goldenWeekFlag == true) && (tMonth == 5) && (tagNumber == 6)) {
        
        //３連祝日のどれかが日曜なら振替休日
        holidayFlag = true;
    }
    else if ((tMonth == 7) && ((i == 15 || i == 22) && (tagNumber >= 15 && tagNumber <= 21)) && (i % 7 == 1)) {
        
        //海の日（7月の第3月曜なら）
        holidayFlag = true;
    }
    else if ((tYear > 2015) && (tMonth == 8) && (tagNumber == 11)) {
        
        //2016年以降、山の日（8月11日）なら
        holidayFlag = true;
    }
    else if ((tYear > 2015) && (tMonth == 8) && (tagNumber == 12) && (i % 7 == 1)) {
        
        //山の日の振替休日（8月12日が月曜なら）
        holidayFlag = true;
    }
    else if ((tMonth == 9) && ((i == 15 || i == 22) && (tagNumber >= 15 && tagNumber <= 21)) && (i % 7 == 1)) {
        
        //敬老の日（9月の第3月曜なら）
        int keiro = tagNumber;
        if ((syuubun - keiro) == 2) {
            kokumin = syuubun - 1;
        }
        holidayFlag = true;
    }
    else if ((kokumin) && ((tMonth == 9) && (tagNumber == kokumin))) {
        
        //９月の国民の休日が有りなら
        holidayFlag = true;
    }
    else if ((tYear  > 1999 ) && (tMonth == 9) && (tagNumber == syuubun)) {
        
        //秋分の日（計算式による）
        holidayFlag = true;
    }
    else if ((tYear  > 1999 ) && (tMonth == 9) && (tagNumber == (syuubun + 1)) && (i % 7 == 1)) {
        
        //秋分の日の振替休日
        holidayFlag = true;
    }
    else if ((tMonth == 10) && ((i == 8 || i == 15) && (tagNumber >= 8 && tagNumber <= 14)) && (i % 7 == 1)) {
        
        //体育の日（10月の第2月曜なら）
        holidayFlag = true;
    }
    else if ((tMonth == 11) && (tagNumber == 3)) {
        
        //文化の日（11月3日なら）
        holidayFlag = true;
    }
    else if ((tMonth == 11) && (tagNumber == 4) && (i % 7 == 1)) {
        
        //文化の日の振替休日（11月4日が月曜なら）
        holidayFlag = true;
    }
    else if ((tMonth == 11) && (tagNumber == 23)) {
        
        //勤労感謝の日（11月23日なら）
        holidayFlag = true;
    }
    else if ((tMonth == 11) && (tagNumber == 24) && (i % 7 == 1)) {
        
        //勤労感謝の日の振替休日（11月24日が月曜なら）
        holidayFlag = true;
    }
    else if ((tMonth == 12) && (tagNumber == 23)) {
        
        //天皇誕生日（12月23日なら）
        holidayFlag = true;
    }
    else if ((tMonth == 12) && (tagNumber == 24) && (i % 7 == 1)) {
        
        //天皇誕生日の振替休日（12月24日が月曜なら）
        holidayFlag = true;
    }
    return holidayFlag;
}
/* ----------- 祝日計算用の関数（おわり） -----------*/

@end



