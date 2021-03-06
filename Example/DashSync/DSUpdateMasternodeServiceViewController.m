//
//  DSUpdateMasternodeServiceViewController.m
//  DashSync_Example
//
//  Created by Sam Westrich on 2/21/19.
//  Copyright © 2019 Dash Core Group. All rights reserved.
//

#import "DSUpdateMasternodeServiceViewController.h"
#import "DSAccountChooserTableViewCell.h"
#import "DSKeyValueTableViewCell.h"
#import "DSLocalMasternode.h"
#import "DSProviderRegistrationTransaction.h"
#include <arpa/inet.h>

@interface DSUpdateMasternodeServiceViewController ()

@property (nonatomic, strong) DSKeyValueTableViewCell *ipAddressTableViewCell;
@property (nonatomic, strong) DSKeyValueTableViewCell *portTableViewCell;
@property (nonatomic, strong) DSAccountChooserTableViewCell *accountChooserTableViewCell;
@property (nonatomic, strong) DSAccount *account;

@end

@implementation DSUpdateMasternodeServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ipAddressTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:@"MasternodeIPAddressCellIdentifier"];
    char s[INET6_ADDRSTRLEN];
    uint32_t ipAddress = self.localMasternode.ipAddress.u32[3];
    self.ipAddressTableViewCell.valueTextField.text = [NSString stringWithFormat:@"%s", inet_ntop(AF_INET, &ipAddress, s, sizeof(s))];
    self.portTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:@"MasternodePortCellIdentifier"];
    self.portTableViewCell.valueTextField.text = [NSString stringWithFormat:@"%d", self.localMasternode.port];
    self.accountChooserTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:@"MasternodeFundingAccountCellIdentifier"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    return self.ipAddressTableViewCell;
                case 1:
                    return self.portTableViewCell;
                case 2:
                    return self.accountChooserTableViewCell;
            }
        }
    }
    return nil;
}

- (IBAction)updateMasternode:(id)sender {
    NSString *ipAddressString = self.ipAddressTableViewCell.valueTextField.text;
    NSString *portString = self.portTableViewCell.valueTextField.text;
    UInt128 ipAddress = {.u32 = {0, 0, CFSwapInt32HostToBig(0xffff), 0}};
    struct in_addr addrV4;
    if (inet_aton([ipAddressString UTF8String], &addrV4) != 0) {
        uint32_t ip = ntohl(addrV4.s_addr);
        ipAddress.u32[3] = CFSwapInt32HostToBig(ip);
        DSLogPrivate(@"%08x", ip);
    }
    uint16_t port = [portString intValue];
    [self.localMasternode updateTransactionFundedByAccount:self.account
                                               toIPAddress:ipAddress
                                                      port:port
                                             payoutAddress:nil
                                                completion:^(DSProviderUpdateServiceTransaction *_Nonnull providerUpdateServiceTransaction) {
                                                    if (providerUpdateServiceTransaction) {
                                                        [self.account signTransaction:providerUpdateServiceTransaction
                                                                           withPrompt:@"Would you like to update this masternode?"
                                                                           completion:^(BOOL signedTransaction, BOOL cancelled) {
                                                                               if (signedTransaction) {
                                                                                   [self.localMasternode.providerRegistrationTransaction.chain.chainManager.transactionManager publishTransaction:providerUpdateServiceTransaction
                                                                                                                                                                                       completion:^(NSError *_Nullable error) {
                                                                                                                                                                                           if (error) {
                                                                                                                                                                                               [self raiseIssue:@"Error" message:error.localizedDescription];
                                                                                                                                                                                           } else {
                                                                                                                                                                                               //[masternode registerInWallet];
                                                                                                                                                                                               [self.presentingViewController dismissViewControllerAnimated:TRUE completion:nil];
                                                                                                                                                                                           }
                                                                                                                                                                                       }];
                                                                               } else {
                                                                                   [self raiseIssue:@"Error" message:@"Transaction was not signed."];
                                                                               }
                                                                           }];
                                                    } else {
                                                        [self raiseIssue:@"Error" message:@"Unable to create ProviderRegistrationTransaction."];
                                                    }
                                                }];
}

- (void)raiseIssue:(NSString *)issue message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:issue message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction *_Nonnull action){

                                            }]];
    [self presentViewController:alert
                       animated:TRUE
                     completion:^{

                     }];
}

- (void)viewController:(UIViewController *)controller didChooseAccount:(DSAccount *)account {
    self.account = account;
    self.accountChooserTableViewCell.accountLabel.text = [NSString stringWithFormat:@"%@-%u", self.account.wallet.uniqueIDString, self.account.accountNumber];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ChooseUpdateFundingAccountSegue"]) {
        DSAccountChooserViewController *chooseAccountSegue = (DSAccountChooserViewController *)segue.destinationViewController;
        chooseAccountSegue.chain = self.localMasternode.providerRegistrationTransaction.chain;
        chooseAccountSegue.minAccountBalanceNeeded = 375;
        chooseAccountSegue.delegate = self;
    }
}

- (IBAction)cancel {
    [self.presentingViewController dismissViewControllerAnimated:TRUE completion:nil];
}

@end
