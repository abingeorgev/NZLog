//
//  NZLog.h
//  NZlog
//
//  Created by Abin on 07/05/16.
//  Copyright © 2016 Nubicz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NZLog : NSObject
{
    NSString *deviceId;
    NSString *deviceName;
    NSString *model;
    NSString *version;
    NSString *projectId;
}

#define NZLogId(x) [[NZLog instance] projectId:x]
#define NZLog(x) [[NZLog instance] log:x tag:NZtag]
#define NZtag [NSString stringWithFormat:@"%s, line:%d",__func__,__LINE__]

typedef enum
{
    NZLogTypeWarning,
    NZLogTypeError,
    NZLogTypeInfo,
    NZLogTypeVerbose
}
NZLogType;

+ (instancetype)instance;

@property (nonatomic, assign) NZLogType logType;
@property BOOL shouldLog;

-(void)log:(NSString*)message tag:(NSString*)tag;
-(void)projectId:(NSString*)projctId;

@end
