//
//  SelectPostPhotoController.m
//  Dipan
//
//  Created by qqn_pipi on 11-6-27.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SelectPostPhotoController.h"
#import "PostService.h"
#import "UIImageUtil.h"
#import "NetworkRequestResultCode.h"
#import "DipanAppDelegate.h"

@implementation SelectPostPhotoController
@synthesize selectPhotoLabel;
@synthesize imageBackgroundButton;
@synthesize submitButton;
@synthesize photoImageView;

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
    [selectPhotoLabel release];
    [photoImageView release];
    [submitButton release];
    [imageBackgroundButton release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)updateButtonStatus
{
    PostService* postService = GlobalGetPostService();    
    if (postService.postImage == nil){
        submitButton.enabled = NO;
    }
    else{
        submitButton.enabled = YES;
    }
}

- (void)updatePhotoImageView
{
    PostService* postService = GlobalGetPostService();    
    
    //CGRect origRect = initImageRect;
    //CGRect retRect = [UIImage shrinkFromOrigRect:origRect imageSize:postService.postImage.size];
    
    //photoImageView.frame = retRect;
    photoImageView.image = postService.postImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self setNavigationLeftButton:NSLS(@"Prev") action:@selector(clickBack:)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStyleDone target:self action:@selector(submit)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [rightItem release];
    self.navigationItem.title = @"选择照片";//NSLS(@"kSetPhoto");
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // Do any additional setup after loading the view from its nib.
    //initImageRect = photoImageView.frame;
    //[self updateButtonStatus];
    //[self updatePhotoImageView];
}

- (void)viewDidUnload
{
    [self setSelectPhotoLabel:nil];
    [self setPhotoImageView:nil];
    [self setSubmitButton:nil];
    [self setImageBackgroundButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

+ (SelectPostPhotoController*)showSelectPostPhotoController:(UIViewController*)viewController
{
    SelectPostPhotoController* controller = [[SelectPostPhotoController alloc] init];
    [viewController.navigationController pushViewController:controller animated:YES];
    [controller release];    
    return controller;
}

- (void)createPostFinish:(int)result
{
    [self dismissModalViewControllerAnimated:YES];
    if (result == ERROR_SUCCESS){
        [self popupHappyMessage:NSLS(@"kNewPostSuccess") title:nil];
    }
    else{
//        [self popupHappyMessage:NSLS(@"kNewPostSuccess") title:nil];
    }
}

- (void)submit
{
    PostService* postService = GlobalGetPostService();        
    [postService setPlaceId:MAKE_FRIEND_PLACEID];
    [postService setPlaceName:NSLS(@"kMakeFriendPlaceName")];
    [postService createPost:self];    
}

- (IBAction)selectPhoto:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] &&
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [self presentModalViewController:picker animated:YES]; 
        [picker release];
    }
}

- (IBAction)tackPhoto:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }
}

- (IBAction)clickSubmitButton:(id)sender
{
    // send post
    PostService* postService = GlobalGetPostService();        
    [postService setPlaceId:MAKE_FRIEND_PLACEID];
    [postService setPlaceName:NSLS(@"kMakeFriendPlaceName")];
    [postService createPost:self];
}

- (IBAction)clickImageButton:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLS(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kSelectPhoto"), NSLS(@"kTakePhoto"), nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image != nil){
        
        // TODO compress image if it's too huge

        // save image
        PostService* postService = GlobalGetPostService();
        [postService setPostImage:image];
    
        // update UI
        photoImageView.image = image;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        //[self updatePhotoImageView];
        //[self updateButtonStatus];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)clickSelectPhoto:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] &&
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [self presentModalViewController:picker animated:YES]; 
        [picker release];
    }
    
}

- (IBAction)clickTakePhoto:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }
    
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(int)buttonIndex
{
    enum{
        SELECT_PHOTO,
        SELECT_TAKE_PHOT,
        SELECT_CANCEL
    };
    
    switch (buttonIndex) {
        case SELECT_PHOTO:
            [self clickSelectPhoto:nil];
            break;
            
        case SELECT_TAKE_PHOT:
            [self clickTakePhoto:nil];
            break;
            
        default:
            break;
    }
}

@end
