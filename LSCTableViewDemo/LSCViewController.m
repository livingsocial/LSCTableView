/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  LSCViewController.m
 *
 *  Created by Josh Avant
 *  Copyright (c) 2013 LivingSocial
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a
 *  copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *  DEALINGS IN THE SOFTWARE.
 *
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#import "LSCViewController.h"
#import "LSCTableView.h"

@interface LSCViewController () <LSCTableViewDelegate, LSCTableViewDataSource>

@property(nonatomic) LSCTableView *tableView;

@end

@implementation LSCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[LSCTableView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:self.tableView];
    
}

- (LSCTableViewCell *)tableView:(LSCTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"LSCTableViewDemo";
    
    LSCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (cell == nil) {
        cell = [[LSCTableViewCell alloc] initWithReuseIdentifier:reuseIdentifier];
        
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Row %i: LivingSocial ipsum dolor sit amet", indexPath.row];

    return cell;
}

- (NSInteger)tableView:(LSCTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1000;
}

- (void)viewWillLayoutSubviews
{
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    self.tableView.frame = CGRectMake(0.f,
                                      statusBarHeight,
                                      CGRectGetWidth(self.view.bounds),
                                      CGRectGetHeight(self.view.bounds) - statusBarHeight);
}

- (CGFloat)tableView:(LSCTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 42.f;
}

@end
