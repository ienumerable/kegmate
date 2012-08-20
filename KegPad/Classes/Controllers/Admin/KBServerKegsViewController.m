//
//  KBServerKegsViewController.m
//  KegPad
//
//  Created by Ely Lerner on 8/19/12.
//  Copyright 2012 All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "KBServerKegsViewController.h"
#import "KBDataStore.h"
#import "KBKeg.h"
#import "KBBeer.h"
#import "KBApplication.h"

#import <YAJLiOS/YAJL.h>


@implementation KBServerKegsViewController
@synthesize serverKegs;
// For data recieved from the server nsurlconnection
NSMutableData *receivedData;

#define kServerPurchasedURL @"http://192.168.100.203/~meatmanek/kegbot/Kegs/purchased"

- (id)init {
  if ((self = [super init])) { 
    self.title = @"Server Kegs";
    self.serverKegs = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)loadPurchasedKegsFromServer {
  NSURL *url = [NSURL URLWithString:kServerPurchasedURL];
  
  NSURLRequest *request=[NSURLRequest requestWithURL:url
                                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                     timeoutInterval:60.0];
  NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
  if (connection) {
    receivedData = [[NSMutableData data] retain];
    //TODO(elerner): show an activity indicator here until we have all the data
    
    //DEBUG
    //add some fake kegs for now
    NSError *error = nil;
    KBBeer *beer = [[KBApplication dataStore] addOrUpdateBeerWithId:@"FakeBeer" name:@"FakeBeer" info:@"infoz" type:@"IPA" country:@"US" imageName:@"" abv:6.6 error:&error];
    KBKeg *keg = [[KBApplication dataStore] addOrUpdateKegWithId:@"FakeKeg" beer:beer volumeAdjusted:1.0 volumeTotal:1.0 error:&error];
    [self.serverKegs addObject:keg];
    //END DEBUG
  } else {
    //TODO(elerner): inform the user of the failure to create connection
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [self loadPurchasedKegsFromServer];
  
  [super viewWillAppear:animated];
}


#pragma mark NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  NSDictionary *arrayFromData = [receivedData yajl_JSON];
  
}

#pragma mark -

#pragma mark KBKegEditViewControllerDelegate

- (void)kegEditViewController:(KBKegEditViewController *)kegEditViewController didSaveKeg:(KBKeg *)keg {
  [self.navigationController popToViewController:self animated:YES];
}

#pragma mark -

#pragma mark UITableViewDataSource
- (UITableViewCell *)cell:(UITableViewCell *)cell forKeg:(KBKeg *)keg {
  cell.textLabel.text = [NSString stringWithFormat:@"Keg: %@", [[keg beer] name]];
  cell.accessoryType = UITableViewCellAccessoryCheckmark;
  return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
  return [self.serverKegs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"KBServerKegsViewController";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell)
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
  
  cell.accessoryType = UITableViewCellAccessoryNone;
  KBKeg *keg = (KBKeg*)[self.serverKegs objectAtIndex:indexPath.row];
  return [self cell:cell forKeg:keg];
}

#pragma mark

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
  KBKeg *keg = (KBKeg *)[self.serverKegs objectAtIndex:indexPath.row];
  
  KBKegEditViewController *kegEditViewController = [[KBKegEditViewController alloc] initWithTitle:@"Keg" useEnabled:YES];
  kegEditViewController.delegate = self;
  [kegEditViewController setKeg:keg];
  [self.navigationController pushViewController:kegEditViewController animated:YES];
  [kegEditViewController release];
}
@end
