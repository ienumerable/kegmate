//
//  KBServerKegsViewController.h
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

#import "KBKegEditViewController.h"

@interface KBServerKegsViewController : UITableViewController <UITableViewDataSource,
                                                              KBKegEditViewControllerDelegate,
                                                              NSURLConnectionDelegate> {
  NSMutableArray *serverKegs;
}

@property (assign, nonatomic) NSMutableArray *serverKegs;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

@end
