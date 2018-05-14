//
//  DSExampleViewController.m
//  DashSync
//
//  Created by Andrew Podkovyrin on 03/19/2018.
//  Copyright (c) 2018 Andrew Podkovyrin. All rights reserved.
//

#import <DashSync/DashSync.h>

#import "DSExampleViewController.h"


@interface DSExampleViewController ()

@property (strong, nonatomic) IBOutlet UILabel *explanationLabel;
@property (strong, nonatomic) IBOutlet UILabel *percentageLabel;
@property (strong, nonatomic) IBOutlet UILabel *dbSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastBlockHeightLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView, *pulseView;
@property (strong, nonatomic) IBOutlet UISwitch *syncSPV;
@property (assign, nonatomic) NSTimeInterval timeout, start;
@property (strong, nonatomic) IBOutlet UISwitch *fullBlocksSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *syncMNListSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *syncSporksSwitch;
@property (strong, nonatomic) IBOutlet UILabel *connectedPeerCount;
@property (strong, nonatomic) IBOutlet UILabel *downloadPeerLabel;
@property (strong, nonatomic) IBOutlet UILabel *chainTipLabel;
@property (strong, nonatomic) IBOutlet UILabel *networkLabel;

- (IBAction)startSync:(id)sender;
- (IBAction)stopSync:(id)sender;
- (IBAction)wipeData:(id)sender;

@end

@implementation DSExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSyncing
{
    double progress = [[DSChainManager sharedInstance] mainnetManager].syncProgress;
    
    if (progress > DBL_EPSILON && progress + DBL_EPSILON < 1.0 && [DSWalletManager sharedInstance].seedCreationTime + DAY_TIME_INTERVAL < [NSDate timeIntervalSinceReferenceDate]) {
        self.explanationLabel.text = NSLocalizedString(@"Syncing:", nil);
    }
}

- (void)startActivityWithTimeout:(NSTimeInterval)timeout
{
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    
    if (timeout > 1 && start + timeout > self.start + self.timeout) {
        self.timeout = timeout;
        self.start = start;
    }
    
    if (timeout <= DBL_EPSILON) {
        if ([[DSChainManager sharedInstance] timestampForBlockHeight:[DSChainManager sharedInstance].lastBlockHeight] +
            WEEK_TIME_INTERVAL < [NSDate timeIntervalSinceReferenceDate]) {
            if ([DSWalletManager sharedInstance].seedCreationTime + DAY_TIME_INTERVAL < start) {
                self.explanationLabel.text = NSLocalizedString(@"Syncing", nil);
            }
        }
        else [self performSelector:@selector(showSyncing) withObject:nil afterDelay:5.0];
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.progressView.hidden = self.pulseView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{ self.progressView.alpha = 1.0; }];
    [self updateProgressView];
}

- (void)stopActivityWithSuccess:(BOOL)success
{
    double progressView = [DSChainManager sharedInstance].syncProgress;
    
    self.start = self.timeout = 0.0;
    if (progressView > DBL_EPSILON && progressView + DBL_EPSILON < 1.0) return; // not done syncing
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (self.progressView.alpha < 0.5) return;
    
    if (success) {
        [self.progressView setProgress:1.0 animated:YES];
        [self.pulseView setProgress:1.0 animated:YES];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.progressView.alpha = self.pulseView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.progressView.hidden = self.pulseView.hidden = YES;
            self.progressView.progress = self.pulseView.progress = 0.0;
        }];
    }
    else {
        self.progressView.hidden = self.pulseView.hidden = YES;
        self.progressView.progress = self.pulseView.progress = 0.0;
    }
}

- (void)setProgressViewTo:(NSNumber *)n
{
    self.progressView.progress = n.floatValue;
}

- (void)updateProgressView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateProgressView) object:nil];
    
    static int counter = 0;
    NSTimeInterval elapsed = [NSDate timeIntervalSinceReferenceDate] - self.start;
    double progress = [DSChainManager sharedInstance].syncProgress;
    uint64_t dbFileSize = [DashSync sharedSyncController].dbSize;
    uint32_t lastBlockHeight = [DSChainManager sharedInstance].lastBlockHeight;
    if (self.timeout > 1.0 && 0.1 + 0.9*elapsed/self.timeout < progress) progress = 0.1 + 0.9*elapsed/self.timeout;
    
    if ((counter % 13) == 0) {
        self.pulseView.alpha = 1.0;
        [self.pulseView setProgress:progress animated:progress > self.pulseView.progress];
        [self.progressView setProgress:progress animated:progress > self.progressView.progress];
        
        if (progress > self.progressView.progress) {
            [self performSelector:@selector(setProgressViewTo:) withObject:@(progress) afterDelay:1.0];
        }
        else self.progressView.progress = progress;
        
        [UIView animateWithDuration:1.59 delay:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.pulseView.alpha = 0.0;
        } completion:nil];
        
        [self.pulseView performSelector:@selector(setProgress:) withObject:nil afterDelay:2.59];
    }
    else if ((counter % 13) >= 5) {
        [self.progressView setProgress:progress animated:progress > self.progressView.progress];
        [self.pulseView setProgress:progress animated:progress > self.pulseView.progress];
    }
    
    counter++;
    
    uint64_t connectedPeerCount = [DSChainManager sharedInstance].peerCount;
    
    self.explanationLabel.text = NSLocalizedString(@"Syncing", nil);
    self.percentageLabel.text = [NSString stringWithFormat:@"%0.1f%%",(progress > 0.1 ? progress - 0.1 : 0.0)*111.0];
    self.dbSizeLabel.text = [NSString stringWithFormat:@"%0.1llu KB",dbFileSize/1000];
    self.lastBlockHeightLabel.text = [NSString stringWithFormat:@"%d",lastBlockHeight];
    self.connectedPeerCount.text = [NSString stringWithFormat:@"%llu",connectedPeerCount];
    self.downloadPeerLabel.text = [DSChainManager sharedInstance].downloadPeerName;
    self.chainTipLabel.text = [DSChainManager sharedInstance].chain.ch;
    if (progress + DBL_EPSILON >= 1.0) {
        if (self.timeout < 1.0) [self stopActivityWithSuccess:YES];
    }
    else [self performSelector:@selector(updateProgressView) withObject:nil afterDelay:0.2];
}

- (IBAction)startSync:(id)sender {
    [[DashSync sharedSyncController] startSync];
    [self startActivityWithTimeout:5.0];
}

- (IBAction)stopSync:(id)sender {
    [[DashSync sharedSyncController] stopSync];
    [self startActivityWithTimeout:5.0];
}

- (IBAction)wipeData:(id)sender {
    [[DashSync sharedSyncController] stopSync];
    [[DashSync sharedSyncController] wipeBlockchainData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1:
            {
                switch (indexPath.row) {
                    case 4:
                    {
                        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Network" message:NULL preferredStyle:UIAlertControllerStyleActionSheet];
                        [alertController addAction:[UIAlertAction actionWithTitle:@"Mainnet" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            <#code#>
                        }]];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            break;
            
        default:
            break;
    }
}

@end