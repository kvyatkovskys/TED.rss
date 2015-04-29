//
//  ViewController.m
//  TED
//
//  Created by Kviatkovskii on 27.04.15.
//  Copyright (c) 2015 Kviatkovskii. All rights reserved.
//

#import "KSViewController.h"
#import "KSAppDelegate.h"
#import "KSTalkDetailViewController.h"

@interface KSViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

{
    NSInteger offset;
    NSMutableArray *nameTalk;
    NSMutableArray *publishedTalk;
    NSMutableArray *descriptionTalk;
    NSMutableArray *idTalk;
    UIActivityIndicatorView *activityIndicator;
}

@property (strong, nonatomic) NSMutableDictionary *talksTed;
@property (strong, nonatomic) NSDictionary *talkTed;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *addDataTalkTED;

@end

static id ID;

@implementation KSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationTitle];
    [self showPreviewTalkTED];
    [self setupActivityIndicator];
    
    nameTalk = [[NSMutableArray alloc] init];
    publishedTalk = [[NSMutableArray alloc] init];
    idTalk = [[NSMutableArray alloc] init];
    descriptionTalk = [[NSMutableArray alloc] init];
    
    [activityIndicator setCenter:[self.view center]];
    [self.tableView addSubview:activityIndicator];
    NSString *URLString = [NSString stringWithFormat:@"https://api.ted.com/v1/talks.json?external=true&podcasts=true&api-key=%@&order=created_at:desc&limit=100",ApiKey];
    NSURL *url = [NSURL URLWithString:URLString];
    [KSAppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
        if (data != nil) {
            NSError * error;
            NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (error != nil) {
                NSLog (@"%@", [error localizedDescription]);
            }
            else {
                self.talksTed = returnedDict[@"talks"];
                for (NSDictionary *curDict in self.talksTed) {
                    self.talkTed = [curDict objectForKey:@"talk"];
                    NSString *name = self.talkTed[@"name"];
                    if (name != nil) {
                        [nameTalk addObject:name];
                        [self.tableView reloadData];
                        //NSLog(@"%@",self.talkTed);
                    }
                    NSString *published = self.talkTed[@"published_at"];
                    if (published != nil) {
                        [publishedTalk addObject:published];
                    }
                    NSString *description = self.talkTed[@"description"];
                    if (description != nil) {
                        [descriptionTalk addObject:description];
                    }
                    NSString *idStr = self.talkTed[@"id"];
                    if (idStr != nil) {
                        [idTalk addObject:idStr];
                    }
                }
            }
        }
    }];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44;
    self.addDataTalkTED.hidden = YES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return nameTalk.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [nameTalk objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [publishedTalk objectAtIndex:indexPath.row];
    
    //[cell setSelectedBackgroundView:[self setupBackgroudViewCell]];
    [activityIndicator stopAnimating];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate{
    self.tableView.tableFooterView = self.addDataTalkTED;
    self.addDataTalkTED.hidden = NO;
}

- (IBAction)addDataTableTalkTED:(id)sender {
    
    offset = nameTalk.count;
    offset ++;
    //NSLog(@"%ld", (long)offset);
    
    self.addDataTalkTED.hidden = YES;
    activityIndicator.color = [UIColor redColor];
    [activityIndicator startAnimating];
    [activityIndicator setCenter:[self.addDataTalkTED center]];

    NSString *URLString = [NSString stringWithFormat:@"https://api.ted.com/v1/talks.json?external=true&podcasts=true&api-key=%@&order=created_at:desc&limit=100&offset=%ld",ApiKey, (long)offset];
    NSURL *url = [NSURL URLWithString:URLString];
    [KSAppDelegate downloadDataFromURL:url withCompletionHandler:^(NSData *data) {
        if (data != nil) {
            NSError * error;
            NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if (error != nil) {
                NSLog (@"%@", [error localizedDescription]);
            }
            else {
                self.talksTed = returnedDict[@"talks"];
                for (NSDictionary *curDict in self.talksTed) {
                    self.talkTed = [curDict objectForKey:@"talk"];
                    NSString *name = self.talkTed[@"name"];
                    if (name != nil) {
                        [nameTalk addObject:name];
                        [self.tableView reloadData];
                        //NSLog(@"%@",self.talkTed);
                    }
                    NSString *published = self.talkTed[@"published_at"];
                    if (published != nil) {
                        [publishedTalk addObject:published];
                    }
                    NSString *description = self.talkTed[@"description"];
                    if (description != nil) {
                        [descriptionTalk addObject:description];
                    }
                    NSString *idStr = self.talkTed[@"id"];
                    if (idStr != nil) {
                        [idTalk addObject:idStr];
                    }
                }
            }
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"nameTalkTed"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        KSTalkDetailViewController *destViewController = segue.destinationViewController;
        destViewController.nameTalkTED = [nameTalk objectAtIndex:indexPath.row];
        destViewController.idTalkTED = [idTalk objectAtIndex:indexPath.row];
    }
}

- (void)setupNavigationTitle {
    UILabel *labelTitleView = [[UILabel alloc] init];
    labelTitleView.frame = CGRectMake(0, 0, 100, 34);
    [labelTitleView setText:@"TED.rss"];
    labelTitleView.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25];
    labelTitleView.textAlignment = NSTextAlignmentCenter;
    [labelTitleView setTextColor:[UIColor redColor]];
    self.navigationItem.titleView = labelTitleView;
}

- (void)showPreviewTalkTED {
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapShowPreview:)];
    longTap.minimumPressDuration = 1;
    [self.tableView addGestureRecognizer:longTap];
}

- (void)longTapShowPreview:(UILongPressGestureRecognizer* ) longGestureRecognize {
    
    CGPoint point = [longGestureRecognize locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if (longGestureRecognize.state == UIGestureRecognizerStateBegan) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[nameTalk objectAtIndex:indexPath.row]
                                                            message:[descriptionTalk objectAtIndex:indexPath.row]
                                                           delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)setupActivityIndicator {
    activityIndicator = [[UIActivityIndicatorView alloc] init];
    activityIndicator.color = [UIColor redColor];
    [activityIndicator startAnimating];
}

- (UIView *)setupBackgroudViewCell {
    UIView *backgroundColorView = [[UIView alloc] init];
    backgroundColorView.backgroundColor = [UIColor redColor];
    backgroundColorView.layer.cornerRadius = 5;
    backgroundColorView.layer.masksToBounds = YES;
    UIBlurEffect *blurLight = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurLight];
    [blurView setFrame:self.tableView.bounds];
    [backgroundColorView addSubview:blurView];
    return backgroundColorView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
