//
//  PublicTimelinePostController.m
//  Dipan
//
//  Created by qqn_pipi on 11-5-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PublicTimelinePostController.h"
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
#import "CreatePrivateMessageController.h"
#import "ImageController.h"
#import "PostService.h"
#import "DipanAppDelegate.h"
#import "NewMakeFriendPostMainController.h"

@implementation PublicTimelinePostController

@synthesize superController;
@synthesize privateMssageController;
@synthesize selectedIndexPath;

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
    [privateMssageController release];
    [superController release];
    [selectedIndexPath release];
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
    self.dataList = [PostManager getAllPostByUseFor:POST_FOR_PUBLIC];
    [self updateMoreRowIndexPath];    
}

- (void)postDataRefresh:(int)result
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
        [localService requestAppPublicTimelinePostData:self beforeTimeStamp:lastPostId cleanData:NO];         
    }
    else{
        [localService requestAppPublicTimelinePostData:self beforeTimeStamp:nil cleanData:YES];         
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
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(presentNewMakeFriendPostMainController)];
    self.navigationItem.title = @"最新";
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
    
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)presentNewMakeFriendPostMainController
{
    NewMakeFriendPostMainController *viewController = [[NewMakeFriendPostMainController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [viewController release];
    [self presentModalViewController:navController animated:YES];
    [navController release];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadDataList];
    [super viewDidAppear:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.privateMssageController = nil;
    self.superController = nil;
    self.selectedIndexPath = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Table View Delegate

- (Post*)postByIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath* modelIndexPath = [self modelIndexPathForIndexPath:indexPath];
    if (modelIndexPath.row < [dataList count]){
        return [dataList objectAtIndex:modelIndexPath.row];
    }
    else{
        NSLog(@"<WARN> postByIndexPath by index path row (%d) > data list count (%d)",
              modelIndexPath.row, [dataList count]);
        return nil;
    }
}

- (Post*)postByControlRowIndexPath:(NSIndexPath*)indexPath
{
    NSIndexPath* modelIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
    if (modelIndexPath.row < [dataList count]){
        return [dataList objectAtIndex:modelIndexPath.row];
    }
    else{
        NSLog(@"<WARN> postByIndexPath by index path row (%d) > data list count (%d)",
              modelIndexPath.row, [dataList count]);
        return nil;
    }
}

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
    
    PostTableViewCell *cell = [PostTableViewCell createCell:self];      		
    Post *post = [self postByIndexPath:indexPath];
    if (post == nil)
        return tableView.rowHeight;
    [cell setCellInfoWithPost:post indexPath:indexPath];
	
	return cell.frame.size.height;
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
    
    NSString *CellIdentifier = [PostTableViewCell getCellIdentifier];
	PostTableViewCell *cell = (PostTableViewCell*)[theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [PostTableViewCell createCell:self];
	}
	
    indexPath = [self modelIndexPathForIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
	//cell.accessoryView = accessoryView;
    //	[self setCellBackground:cell row:row count:count];        		
	
    Post* post = [self postByIndexPath:indexPath];
    if (post == nil)
        return cell;
	
    [cell setCellInfoWithPost:post indexPath:indexPath];
	
	return cell;
	
}

- (void)clickPlaceNameButton:(id)sender atIndexPath:(NSIndexPath *)indexPath
{
    Post* post = [self postByIndexPath:indexPath];
    if (post == nil)
        return;
    
    [self deleteControlRow];
    [PostControllerUtils askFollowPlace:post.placeId placeName:post.placeName  viewController:self];            
}

- (void)clickUserAvatarButton:(id)sender atIndexPath:(NSIndexPath *)indexPath
{
    
    Post* post = [self postByIndexPath:indexPath];
    if (post == nil)
        return;

    [self deleteControlRow];
    [PrivateMessageControllerUtils showPrivateMessageController:post.userId 
                                                   userNickName:post.userNickName
                                                     userAvatar:post.userAvatar
                                                 viewController:self.superController];      
}

-(void)clickPostImageButton:(id)sender atIndexPath:(NSIndexPath *)indexPath
{
    Post *post = [self postByIndexPath:indexPath];
    if (post == nil) {
        return;
    }
    [self deleteControlRow];
    NSString *imageURL = [post imageURL];
    if ([imageURL length] > 0) {
        [ImageController showImageController:self.superController imageURL:imageURL];
    }
}

- (void)clickLikeButton:(id)sender atIndexPath:(NSIndexPath*)indexPath
{
    self.selectedIndexPath = indexPath;
    Post* post = [self postByIndexPath:indexPath];
    if (post == nil)
        return;
    
    [self deleteControlRow];

    PostService* postService = GlobalGetPostService();
    [postService actionOnPost:post.postId
                   actionName:POST_ACTION_LIKE
                      placeId:MAKE_FRIEND_PLACEID
               viewController:self];
}

- (void)actionOnPostFinish:(int)result count:(long)count
{
    Post* post = [self postByIndexPath:self.selectedIndexPath];
    post.totalRelated = [NSNumber numberWithLong:count];
    PostTableViewCell *cell = (PostTableViewCell *)[self.dataTableView cellForRowAtIndexPath:self.selectedIndexPath];
    cell.totalReplyLabel.text = [NSString stringWithFormat:@"%i人感兴趣", count];
}

- (void)clickMessageButton:(id)sender atIndexPath:(NSIndexPath*)indexPath
{
    Post* post = [self postByIndexPath:indexPath];
    if (post == nil)
        return;

    [self deleteControlRow];

    if (self.privateMssageController == nil){
        self.privateMssageController = [PrivateMessageControllerUtils showPrivateMessageController:post.userId 
                                                                                      userNickName:post.userNickName
                                                                                        userAvatar:post.userAvatar
                                                                                    viewController:self];      
    }
    else{
        [self.navigationController pushViewController:self.privateMssageController animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isMoreRowIndexPath:indexPath]){
        [self.moreLoadingView startAnimating];
        if ([self respondsToSelector:@selector(didSelectMoreRow)]){
            [self performSelector:@selector(didSelectMoreRow)];
        }
        return;
    }
}

- (void)didSelectMoreRow
{
    [self requestPostListFromServer:NO];
}

#pragma Pull Refresh Delegate

- (void) reloadTableViewDataSource
{
    [self deleteControlRow];    
    [self requestPostListFromServer:YES];
}

@end
