//
//  DSBlockchainIdentityTopupTransition.m
//  DashSync
//
//  Created by Sam Westrich on 7/30/18.
//

#import "DSBlockchainIdentityTopupTransition.h"
#import "DSBlockchainIdentityTopupTransitionEntity+CoreDataClass.h"
#import "DSECDSAKey.h"
#import "DSTransactionFactory.h"
#import "NSData+Bitcoin.h"
#import "NSMutableData+Dash.h"
#import "NSString+Bitcoin.h"

@interface DSBlockchainIdentityTopupTransition ()

@end

@implementation DSBlockchainIdentityTopupTransition

- (Class)entityClass {
    return [DSBlockchainIdentityTopupTransitionEntity class];
}

@end
