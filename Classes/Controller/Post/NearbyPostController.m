//
//  NearbyPostController.m
//  Dipan
//
//  Created by qqn_pipi on 11-5-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "NearbyPostController.h"
#import "Post.h"
#import "PostManager.h"
#import "UserManager.h"
#import "LocalDataService.h"
#import "DipanAppDelegate.h"
#import "NetworkRequestResultCode.h"
#import "PostControllerUtils.h"
#import "PostTableViewCell.h"
#import "ResultUtils.h"
#import "MoreTableViewCell.h"
#import "PostActionCell.h"
#import "PrivateMessageControllerUtils.h"

@implementation NearbyPostController

@synthesize superController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{    
    [superController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadDataList
{
    self.dataList = [PostManager getAllNearbyPost:nil];     
    [self updateMoreRowIndexPath];    
}

- (void)nearbyPostDataRefresh:(int)result
{    
    if (result == ERROR_SUCCESS){
        [self loadDataList];
        [self.dataTableView reloadData];
    }

    if ([self isReloading]){
        [self dataSourceDidFinishLoadingNewData];
    }
    
    if ([self.moreLoadingView isAnimating]){
        [self.moreLoadingView stopAnimating];
        [self.dataTableView deselectRowAtIndexPath:moreRowIndexPath animated:NO];
    }
}

- (void)requestPostListFromServer:(BOOL)isRequestLastest
{
    double longitude;
    double latitude;
    
    LocationService* locationService = GlobalGetLocationService();
    longitude = locationService.currentLocation.coordinate.longitude;
    latitude = locationService.currentLocation.coordinate.latitude;
    
    LocalDataService* localService = GlobalGetLocalDataService();
    
    if (!isRequestLastest){
        NSString* lastPostId = [PostControllerUtils getLastPostId:dataList];        
        [localService requestNearbyPostData:self beforeTimeStamp:lastPostId longitude:longitude latitude:latitude cleanData:NO];
    }
    else{

        [localService requestNearbyPostData:self beforeTimeStamp:nil longitude:longitude latitude:latitude cleanData:YES];
    }        
}



- (void)initDataList
{
    [self loadDataList];
    [self requestPostListFromServer:YES];    
}

- (void)viewDidLoad
{
    supportRefreshHeader = YES;
    
    [self initDataList];
    [self enableMoreRowAtSection:0];
    
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];

}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadDataList];
    [super viewDidAppear:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Table View Delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {		
	return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// return [self getRowHeight:indexPath.row totalRow:[dataList count]];
	// return cellImageHeight;
    if ([self.controlRowIndexPath isEqual:indexPath])
        return [PostActionCell getCellHeight];
    
    if ([self isMoreRowIndexPath:indexPath]){
        return [MoreTableViewCell getRowHeight];
    }

	return [PostTableViewCell getCellHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;		
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {  
    return [self calcRowCount];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isMoreRowIndexPath:indexPath]){
        MoreTableViewCell* moreCell = [MoreTableViewCell createCell:theTableView];
        self.moreLoadingView = moreCell.loadingView;
        return moreCell;
    }

    if ([self isControlRowIndexPath:indexPath]){
        NSString *CellIdentifier = [PostActionCell getCellIdentifier];
        PostActionCell *cell = (PostActionCell*)[theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [PostActionCell createCell];
        }        
        return cell;
    }
    
    NSString *CellIdentifier = [PostTableViewCell getCellIdentifier];
	PostTableViewCell *cell = (PostTableViewCell*)[theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [PostTableViewCell createCell:self];
	}
	
    indexPath = [self modelIndexPathForIndexPath:indexPath];
    
	cell.accessoryView = accessoryView;
	
	// set text label
	int row = [indexPath row];	
	int count = [dataList count];
	if (row >= count){
		NSLog(@"[WARN] cellForRowAtIndexPath, row(%d) > data list total number(%d)", row, count);
		return cell;
	}
	
    //	[self setCellBackground:cell row:row count:count];        
	
	Post* post = [dataList objectAtIndex:row];
    [cell setCellInfoWithPost:post indexPath:indexPath];
	
	return cell;
	
}

- (void)clickPlaceNameButton:(id)sender atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [dataList count])
        return;
    
    Post* post = [dataList objectAtIndex:indexPath.row];
    [PostControllerUtils askFollowPlace:post.placeId placeName:post.placeName  viewController:self];            
}

- (void)clickUserAvatarButton:(id)sender atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [dataList count])
        return;
    
    Post* post = [dataList objectAtIndex:indexPath.row];    
    [PrivateMessageControllerUtils showPrivateMessageController:post.userId 
                                                   userNickName:post.userNickName
                                                     userAvatar:post.userAvatar
                                                 viewController:self.superController];      
}

- (void)didSelectMoreRow
{
    [self requestPostListFromServer:YES];
}

#pragma Pull Refresh Delegate

- (void) reloadTableViewDataSource
{
    [self requestPostListFromServer:YES];
}

@end
