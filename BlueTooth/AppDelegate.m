//
//  AppDelegate.m
//  BlueTooth
//
//  Created by tangzhiqiang on 2023/8/16.
//

#import "AppDelegate.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <CocoaLumberjack/CocoaLumberjack.h>


//设置默认的log等级
DDLogLevel ddLogLevel = DDLogLevelDebug;

@interface AppDelegate ()<DDLogFormatter>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupLog];
    [SVProgressHUD setMinimumDismissTimeInterval:1];
    [SVProgressHUD setMaximumDismissTimeInterval:2];
    return YES;
}

- (void)setupLog {
    //修改Logs文件夹的位置
    NSString *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *logsDirectory = [paths stringByAppendingPathComponent:@"BlueToothApp"];
    DDLogFileManagerDefault *defaultManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logsDirectory];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:defaultManager];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hours
    fileLogger.logFileManager.maximumNumberOfLogFiles = 12;
    fileLogger.logFileManager.logFilesDiskQuota = 1024*1024*20;
    fileLogger.logFormatter = self;
    [DDLog addLogger:fileLogger];
}

#pragma mark - DDLogFormatter
- (nullable NSString *)formatLogMessage:(DDLogMessage *)logMessage NS_SWIFT_NAME(format(message:)) {
    logMessage->_timestamp = [self getLocalDate];
//    NSString *formatLog = [NSString stringWithFormat:@"%@%@ line:%ld %@\n\n",logMessage->_timestamp, logMessage->_function,logMessage->_line,logMessage->_message];
    NSString *formatLog = [NSString stringWithFormat:@"%@%@\n\n",logMessage->_timestamp, logMessage->_message];
    return formatLog;
}
// 调整timestamp
- (NSDate *)getLocalDate{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localDate = [date dateByAddingTimeInterval: interval];
    return localDate;
}

@end
