//
//  RateFilter.h
//  HealthManager
//
//  Created by 赖星果 on 2020/12/25.
//

#import <Foundation/Foundation.h>

#define NZEROS 10
#define NPOLES 10

NS_ASSUME_NONNULL_BEGIN

@interface RateFilter : NSObject {
    float xv[NZEROS+1], yv[NPOLES+1];
}

- (float)processValue:(float)value;

@end

NS_ASSUME_NONNULL_END
