//
//  KSTalkDetailViewController.m
//  TED
//
//  Created by Kviatkovskii on 28.04.15.
//  Copyright (c) 2015 Kviatkovskii. All rights reserved.
//

#import "KSTalkDetailViewController.h"
#import "KSAppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

@interface KSTalkDetailViewController ()

{
    UIActivityIndicatorView *activityIndicator;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UIImageView *imageTalkTED;
@property (weak, nonatomic) IBOutlet UIImageView *imageBackgroundTalkTED;
@property (weak, nonatomic) IBOutlet UILabel *viewsTalkTED;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTalkTED;
@property (weak, nonatomic) IBOutlet UILabel *publishedTalkTED;
@property (weak, nonatomic) IBOutlet UIButton *playButonTalkTED;

@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) NSDictionary *talkTedDetail;
@property (strong, nonatomic) NSDictionary *themesTedDetail;
@property (strong, nonatomic) NSDictionary *themeTedDetail;
@property (strong, nonatomic) NSDictionary *mediaTedDetail;
@property (strong, nonatomic) NSDictionary *internalTedDetail;
@property (strong, nonatomic) NSDictionary *urlTedDetail;
@property (strong, nonatomic) NSDictionary *imagesTedDetail;
@property (strong, nonatomic) NSDictionary *imageTedDetail;

@end

static NSString *stringUrlVideo;
static NSString *stringUrlImage;
static NSString *stringTitle;

@implementation KSTalkDetailViewController

@synthesize nameTalkTED, idTalkTED;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBackground];
    [self setupPlayButton];
    [self setupActivityIndicator];
    
    self.titleLable.hidden = YES;
    self.playButonTalkTED.hidden = YES;

    NSString *URLString = [NSString stringWithFormat:@"https://api.ted.com/v1/talks/%@.json?external=true&podcasts=true&api-key=%@",idTalkTED ,ApiKey];
    NSURL *url = [NSURL URLWithString:URLString];
    [KSAppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
        if (data != nil) {
            NSError * error;
            NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data
                                                                                options:kNilOptions
                                                                                  error:&error];
            if (error != nil) {
                NSLog (@"%@", [error localizedDescription]);
            }
            else {
                self.talkTedDetail = returnedDict[@"talk"];
                //NSLog(@"%@",self.talkTedDetail);
                self.themesTedDetail = self.talkTedDetail[@"themes"];
                for (NSDictionary *curThemes in self.themesTedDetail) {
                    self.themeTedDetail = [curThemes objectForKey:@"theme"];
                }
                stringTitle = self.themeTedDetail[@"name"];
                
                self.mediaTedDetail = self.talkTedDetail[@"media"];
                self.internalTedDetail = self.mediaTedDetail[@"internal"];
                self.urlTedDetail = self.internalTedDetail[@"950k"];
                stringUrlVideo = self.urlTedDetail[@"uri"];
                
                self.imagesTedDetail = self.talkTedDetail[@"images"];
                for (NSDictionary *curThemes in self.imagesTedDetail) {
                    self.imageTedDetail = [curThemes objectForKey:@"image"];
                }
                stringUrlImage = self.imageTedDetail[@"url"];
                [self loadImageView];
                [self finishLoad];
                
                NSString *description = self.talkTedDetail[@"description"];
                if (description != nil) {
                    self.descriptionTalkTED.text = description;
                }
                NSString *views = self.talkTedDetail[@"viewed_count"];
                if (views != nil) {
                    self.viewsTalkTED.text = [NSString stringWithFormat:@"Views: %@",views];
                }
                NSString *published = self.talkTedDetail[@"published_at"];
                if (published != nil) {
                    self.publishedTalkTED.text = published;
                }
            }
        }
    }];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (IBAction)playUrlTalkTED:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:stringUrlVideo];
    self.moviePlayer =  [[MPMoviePlayerController alloc] initWithContentURL:url];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:)
                                                               name:MPMoviePlayerPlaybackDidFinishNotification
                                                             object:self.moviePlayer];
    
    [self.moviePlayer.view setFrame:CGRectMake(self.imageTalkTED.frame.origin.x, self.imageTalkTED.frame.origin.y, self.imageTalkTED.frame.size.width, self.imageTalkTED.frame.size.height)];
    self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
    self.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    self.moviePlayer.shouldAutoplay = YES;
    [self.view addSubview:self.moviePlayer.view];
    [self.moviePlayer setFullscreen:NO animated:YES];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:player];
    
    if ([player respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player stop];
        [player.view removeFromSuperview];
    }
}

-(void)deviceOrientationDidChange {
    [self setupBackground];
    [self.moviePlayer.view setFrame:CGRectMake(self.imageTalkTED.frame.origin.x, self.imageTalkTED.frame.origin.y, self.imageTalkTED.frame.size.width, self.imageTalkTED.frame.size.height)];
}

- (void)loadImageView {
    NSURL *url = [NSURL URLWithString:stringUrlImage];
    self.imageTalkTED.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    self.imageBackgroundTalkTED.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
}

- (void)setupNavigationTitle {
    UILabel *labelTitleView = [[UILabel alloc] init];
    labelTitleView.frame = CGRectMake(0, 0, 100, 34);
    [labelTitleView setText:stringTitle];
    labelTitleView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    labelTitleView.textAlignment = NSTextAlignmentCenter;
    [labelTitleView setTextColor:[UIColor redColor]];
    self.navigationItem.titleView = labelTitleView;
}

- (void)finishLoad {
    [self setupNavigationTitle];
    self.titleLable.text = nameTalkTED;
    self.titleLable.hidden = NO;
    self.playButonTalkTED.hidden = NO;
    [activityIndicator stopAnimating];
    self.titleLable.layer.cornerRadius = 5;
    self.titleLable.layer.masksToBounds = YES;
}

- (void)setupBackground {
    UIBlurEffect *blurLight = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurLight];
    [blurView setFrame:self.view.bounds];
    [self.imageBackgroundTalkTED addSubview:blurView];
}

- (void)setupPlayButton {
    self.playButonTalkTED.layer.cornerRadius = self.playButonTalkTED.frame.size.height/2;
    self.playButonTalkTED.layer.masksToBounds = YES;
    self.playButonTalkTED.layer.borderWidth = 2;
    self.playButonTalkTED.layer.borderColor = [[UIColor whiteColor]CGColor];
}

- (void)setupActivityIndicator {
    activityIndicator = [[UIActivityIndicatorView alloc] init];
    [activityIndicator setCenter:[self.view center]];
    [self.imageTalkTED addSubview:activityIndicator];
    activityIndicator.color = [UIColor redColor];
    [activityIndicator startAnimating];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
