//
//  DSMasternodeListsViewController.m
//  DashSync_Example
//
//  Created by Sam Westrich on 6/18/19.
//  Copyright © 2019 Dash Core Group. All rights reserved.
//

#import "DSMasternodeListsViewController.h"
#import "DSMasternodeListTableViewCell.h"
#import <DashSync/DashSync.h>
#import "DSClaimMasternodeViewController.h"
#import "DSRegisterMasternodeViewController.h"
#import "DSMasternodeDetailViewController.h"
#import "DSMasternodeViewController.h"

@interface DSMasternodeListsViewController ()
@property (nonatomic,strong) NSFetchedResultsController * fetchedResultsController;

@end

@implementation DSMasternodeListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Automation KVO

-(NSManagedObjectContext*)managedObjectContext {
    return [NSManagedObject context];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController) return _fetchedResultsController;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DSMasternodeListEntity" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *heightSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"block.height" ascending:NO];
    NSArray *sortDescriptors = @[heightSortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"block.chain == %@",self.chain.chainEntity];
    [fetchRequest setPredicate:filterPredicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController = aFetchedResultsController;
    aFetchedResultsController.delegate = self;
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return aFetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DSMasternodeListTableViewCell *cell = (DSMasternodeListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MasternodeListTableViewCellIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


-(void)configureCell:(DSMasternodeListTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath {
    DSMasternodeListEntity *masternodeListEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.heightLabel.text = [NSString stringWithFormat:@"%u",masternodeListEntity.block.height];
    cell.countLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)masternodeListEntity.masternodes.count];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MasternodeListSegue"]) {
        NSIndexPath * indexPath = self.tableView.indexPathForSelectedRow;
        DSMasternodeListEntity *masternodeListEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
        DSMasternodeViewController * masternodeViewController = (DSMasternodeViewController*)segue.destinationViewController;
        masternodeViewController.chain = self.chain;
        DSMasternodeList * masternodeList = [self.chain.chainManager.masternodeManager masternodeListForBlockHash:masternodeListEntity.block.blockHash.UInt256];
        masternodeViewController.masternodeList = masternodeList;
    }
}
@end
