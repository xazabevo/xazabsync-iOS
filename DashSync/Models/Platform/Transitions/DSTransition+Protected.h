//  
//  Created by Sam Westrich
//  Copyright © 2019 Dash Core Group. All rights reserved.
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

#import "DSTransition.h"

NS_ASSUME_NONNULL_BEGIN

@interface DSTransition ()

@property (nonatomic, assign) BOOL saved; //don't trust this

@property (nonatomic, assign) uint16_t type;
@property (nonatomic, assign) uint64_t creditFee;
@property (nonatomic, assign) UInt256 transitionHash;

@property (nonatomic, assign) NSTimeInterval createdTimestamp;
@property (nonatomic, assign) NSTimeInterval registeredTimestamp;

@end

NS_ASSUME_NONNULL_END
