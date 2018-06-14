//
//  DSDashSync.h
//  dashsync
//
//  Created by Sam Westrich on 3/4/18.
//  Copyright © 2018 dashcore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSChainPeerManager.h"
#import "DSChain.h"
#import "DSDerivationPath.h"
#import "DSChainManager.h"
#import "DSWalletManager.h"
#import "DSMasternodeManager.h"
#import "DSGovernanceSyncManager.h"
#import "DSSporkManager.h"
#import "DSAuthenticationManager.h"
#import "DSEventManager.h"
#import "DSShapeshiftManager.h"
#import "DSBIP39Mnemonic.h"
#import "DSWallet.h"
#import "DSAccount.h"
#import "DSDerivationPath.h"
#import "NSString+Dash.h"
#import "NSMutableData+Dash.h"
#import "DSOptionsManager.h"
#import "NSData+Dash.h"
#import "DSAddressEntity+CoreDataProperties.h"
#import "DSDerivationPathEntity+CoreDataProperties.h"
#import "DSMerkleBlockEntity+CoreDataProperties.h"
#import "DSMasternodeBroadcastHashEntity+CoreDataProperties.h"
#import "DSMasternodeBroadcastEntity+CoreDataProperties.h"
#import "DSGovernanceObjectEntity+CoreDataProperties.h"
#import "DSGovernanceObjectHashEntity+CoreDataProperties.h"
#import "NSManagedObject+Sugar.h"

//! Project version number for dashsync.
FOUNDATION_EXPORT double DashSyncVersionNumber;

//! Project version string for dashsync.
FOUNDATION_EXPORT const unsigned char DashSyncVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <dashsync/PublicHeader.h>

@interface DashSync : NSObject

@property (nonatomic,assign) BOOL deviceIsJailbroken;

+ (instancetype _Nullable)sharedSyncController;

-(void)startSyncForChain:(DSChain*)chain;
-(void)stopSyncForChain:(DSChain*)chain;
-(void)stopSyncAllChains;

-(void)wipeBlockchainData;

-(uint64_t)dbSize;


@end
