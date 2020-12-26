//
//  HeatBeatManager.h
//  HealthManager
//
//  Created by 赖星果 on 2020/12/25.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CurrentStateType) {
    CurrentStateTypePaused,
    CurrentStateTypeSampling
};

NS_ASSUME_NONNULL_BEGIN

@protocol HeatBeatManagerDelegate <NSObject>

- (void)startHeartRateError:(NSError *)error;
- (void)startHeartRateFrequency:(NSInteger)frequency;
- (void)startHeartRateTip:(NSString *)tipStr;

@end

@interface HeatBeatManager : NSObject

@property (nonatomic, weak) id<HeatBeatManagerDelegate> delegate;

+ (HeatBeatManager *)sharedInstance;

- (void)start;
- (void)retry;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
