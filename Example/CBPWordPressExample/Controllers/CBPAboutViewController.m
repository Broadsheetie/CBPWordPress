//
//  CBPAboutViewController.m
//  CBPWordPressExample
//
//  Created by Karl Monaghan on 24/06/2014.
//  Copyright (c) 2014 Crayons and Brown Paper. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "Appirater.h"
#import "Converser.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GPPShareActivity.h"
#import "SSCWhatsAppActivity.h"

#import "CBPAboutViewController.h"
#import "CBPSubmitTipViewController.h"
#import "CBPSettingsViewController.h"

#define kAppId  @"413093424"

@interface CBPAboutViewController () <MFMailComposeViewControllerDelegate, VGConverserDelegate, VGCustomFeedbackViewControllerDelegate>
@property (nonatomic) VGConversationEngine *converser;
@end

@implementation CBPAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [Appirater setAppId:kAppId];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(done)];
    
    self.navigationItem.title = NSLocalizedString(@"About", nil);
    
    self.converser = [[VGConversationEngine alloc] initWithHostName:BSConverserAPI
                                                             andKey:BSConverserKey];
    if (self.converser) {
        [self startConverser];
    }
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                       value:@"About Screen"];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.converser.delegate = nil;
}

- (void)dealloc
{
    _converser.delegate = nil;
}

- (BOOL)shouldAutorotate {
    return ![[NSUserDefaults standardUserDefaults] boolForKey:CBPLockRotation];
}

- (NSUInteger)supportedInterfaceOrientations{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:CBPLockRotation]) {
        return UIInterfaceOrientationPortrait;
    }
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark -
- (void)converserFeedback
{
    NSArray *fieldsArray = @[
                             @{@"Type": @"HeaderText", @"Label" : @"YOUR FEEDBACK"},
                             @{@"Type": @"DescriptionText", @"Label" : @"Your feedback is important to us, please fill in the box below with your query and we'll get right back to you."},
                             @{@"Type": @"Name", @"Label" : @"Your name (optional)"},
                             @{@"Type": @"Email", @"Label" : @"Your email address (optional)"},
                             @{@"Type": @"TextArea", @"Label" : @"Enter your text here"},
                             ];
    NSDictionary *hiddenData = @{@"Source": @"BroadsheetApp"};

    ConverserNavigationController *vc = [self.converser feedbackControllerWithFields:fieldsArray context:hiddenData delegate:self];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)done
{
    [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)shareAction
{
    NSArray* activityItems = @[[NSString stringWithFormat:@"Loving the %@ app", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]],
                               [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/ie/app/id%@?mt=8", kAppId]]];
    
    UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                         applicationActivities:@[[SSCWhatsAppActivity new],
                                                                                                                 [GPPShareActivity new]]];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact, UIActivityTypeAirDrop, UIActivityTypePostToTencentWeibo, UIActivityTypePrint ];
    
    [self presentViewController:activityViewController animated:YES completion:NULL];
}

- (void) startConverser {
    NSString *userIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [self.converser startWithIdentity:userIdentifier delegate:self];
    

}

#pragma mark - VGConverserDelegate
-(void) converserHasMessages:(NSNumber *)countMessages error:(NSError *)error
{
    
}

#pragma mark - VGCustomFeedbackViewControllerDelegate
-(void) customFeedbackController:(VGCustomFeedbackViewController *)controller
             didFinishWithResult:(VGCustomFeedbackResultType)result
                           error:(NSError *)error
{
    if (error) {

    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDAtaSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
        default:
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = nil;
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"Rate this App", nil);
                    break;
                case 1:
                    cell.textLabel.text = NSLocalizedString(@"Share this App", nil);
                    break;
                case 2:
                    cell.textLabel.text = NSLocalizedString(@"Contact Us", nil);
                    break;
                case 3:
                    cell.textLabel.text = NSLocalizedString(@"Feedback about the app", nil);
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"More Apps", nil);
                    break;
                case 1:
                    cell.textLabel.text = NSLocalizedString(@"About the Developer", nil);
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"Settings", nil);
                    break;
                default:
                    break;
            }
        }
            break;
        case 3:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.textLabel.text = NSLocalizedString(@"Version", nil);
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"]];
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
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                    [Appirater rateApp];
                    
                    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                                                        action:@"button_tap"
                                                                                                         label:@"rate_app"
                                                                                                         value:nil] build]];
                    break;
                case 1: {
                    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                                                        action:@"button_tap"
                                                                                                         label:@"share_app"
                                                                                                         value:nil] build]];
                    
                    [self shareAction];
                }
                    break;
                case 2:
                {
                    CBPSubmitTipViewController *vc = [[CBPSubmitTipViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    
                    CBPNavigationController *navController = [[CBPNavigationController alloc] initWithRootViewController:vc];
                    
                    [self.navigationController presentViewController:navController
                                                            animated:YES
                                                          completion:nil];
                }
                    break;
                case 3:{
                    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                                                                        action:@"button_tap"
                                                                                                         label:@"send_email"
                                                                                                         value:nil] build]];
                    
                    [self performSelector:@selector(converserFeedback) withObject:nil afterDelay:0.0];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewArtist?id=427412037"]];
                }
                    break;
                case 1:
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://karlmonaghan.com/about"]];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
            switch (indexPath.row)
        {
            case 0:
            {
                CBPSettingsViewController *settings = [CBPSettingsViewController new];
                
                [self.navigationController pushViewController:settings animated:YES];
            }
                break;
                
            default:
                break;
        }
        default:
            break;
    }
}

- (void)sendEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        [mailer setSubject:[NSString stringWithFormat:@"Feedback for %@", [infoDictionary objectForKey:@"CFBundleName"]]];
        
        NSString *body = [NSString stringWithFormat:@"\n\n\nApp version: %@ (%@)\niOS Version: %@\niOS Device: %@", [infoDictionary objectForKey:@"CFBundleShortVersionString"], [infoDictionary objectForKey:@"CFBundleVersion"], [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model]];
        [mailer setMessageBody:body isHTML:NO];
        
        [mailer setToRecipients:@[@"feedback@crayonsandbrownpaper.com"]];
        
        [self.navigationController presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No email settings"
                                                        message:@"You can't send emails from this device"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //DLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            //DLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            //DLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            //DLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            //DLog(@"Mail not sent.");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
