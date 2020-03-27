//  
//  Created by Sam Westrich
//  Copyright © 2020 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <XCTest/XCTest.h>
#import "NSMutableData+Dash.h"
#import "NSString+Bitcoin.h"
#import "BigIntTypes.h"
#import "NSData+Bitcoin.h"
#import "NSData+Dash.h"
#import "DSChain.h"
#import "DSWallet.h"
#import "DSBlockchainIdentity.h"
#import "DSCreditFundingTransaction.h"
#import "DSAccount.h"

@interface DSAttackTests : XCTestCase

@end

@implementation DSAttackTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testBasicGrindingAttack {
    UInt256 randomNumber = uint256_RANDOM;
    UInt256 seed = uint256_RANDOM;
    NSUInteger maxDepth = 0;
    NSTimeInterval timeToRun = 360;
    NSDate * startTime = [NSDate date];
    while ([startTime timeIntervalSinceNow] < timeToRun) {
        UInt256 hash = [uint256_data([[NSData dataWithUInt256:seed] SHA256_2]) blake2s];
        UInt256 xor = uint256_xor(randomNumber, hash);
        uint16_t depth = uint256_firstbits(xor);
        if (depth > maxDepth) {
            NSLog(@"found a new max %d",depth);
            maxDepth = depth;
        }
        seed = uInt256AddOne(seed);
    }
}

- (void)testIdentityGrindingAttack {
    DSChain * chain = [DSChain devnetWithIdentifier:@"devnet-mobile"];
    
    //NSString * seedPhrase = @"burger second sausage shriff police accident bargain survey unhappy juice flag script";

    DSWallet * wallet = [[chain wallets] objectAtIndex:0];
    
    DSBlockchainIdentity * firstIdentity = [wallet defaultBlockchainIdentity];
    
    //[DSWallet standardWalletWithSeedPhrase:seedPhrase setCreationDate:0 forChain:chain storeSeedPhrase:NO isTransient:YES];

    UInt256 firstIdentityUniqueIDBlake2s = [uint256_data(firstIdentity.uniqueID) blake2s];

    DSBlockchainIdentity * identity = [wallet createBlockchainIdentityOfType:DSBlockchainIdentityType_User];

    NSUInteger maxDepth = 0;
    NSTimeInterval timeToRun = 360;
    uint32_t amount = 100;
    NSDate * startTime = [NSDate date];

    NSMutableData *script = [NSMutableData data];

    [script appendCreditBurnScriptPubKeyForAddress:[identity registrationFundingAddress] forChain:chain];
    DSAccount * account = [wallet accountWithNumber:0];
    
    DSECDSAKey * signingKey = [DSECDSAKey keyWithPrivateKey:@"cPjNYqR7hwygxzAPs2makWSbY96kJd5pA7PQxmcdWpFkvCobxMtw" onChain:chain];

    DSCreditFundingTransaction *transaction = [[DSCreditFundingTransaction alloc] initOnChain:chain];
    [account updateTransaction:transaction forAmounts:@[@(amount)] toOutputScripts:@[script] withFee:1000 shuffleOutputOrder:NO];
    uint32_t changeAmount = [transaction.amounts[1] unsignedIntValue];
    while ([startTime timeIntervalSinceNow] < timeToRun) {
        transaction.amounts = [NSMutableArray arrayWithObjects:@(amount),@(changeAmount),nil];
        [transaction signWithPreorderedPrivateKeys:@[signingKey]];
        DSUTXO outpoint = { .hash = uint256_reverse(transaction.txHash), .n = 0 };
        UInt256 hash = [uint256_data([dsutxo_data(outpoint) SHA256_2]) blake2s];
        UInt256 xor = uint256_xor(firstIdentityUniqueIDBlake2s, hash);
        uint16_t depth = uint256_firstbits(xor);
        if (amount % 1000 == 0) {
            NSTimeInterval timeSinceStart = [startTime timeIntervalSinceNow];
            NSLog(@"Speed %.2f/s",-(amount/timeSinceStart));
        }
        if (depth > maxDepth) {
            NSLog(@"found a new max %d at %d/%d",depth,amount,changeAmount);
            maxDepth = depth;
            if (depth > 20) {
                NSLog(@"found it %@",transaction.toData);
            }
        }
        amount++;
        changeAmount--;
    }
}

@end
