/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  LSCTableView.h
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

#import <UIKit/UIKit.h>
#import "LSCTableViewCell.h"

@class LSCTableView;

@protocol LSCTableViewDelegate <NSObject, UIScrollViewDelegate>

@optional
- (CGFloat)tableView:(LSCTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; // default value is 42

- (CGFloat)tableView:(LSCTableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (UIView *)tableView:(LSCTableView *)tableView viewForHeaderInSection:(NSInteger)section;

- (CGFloat)tableView:(LSCTableView *)tableView heightForFooterInSection:(NSInteger)section;
- (UIView *)tableView:(LSCTableView *)tableView viewForFooterInSection:(NSInteger)section;

@end

@protocol LSCTableViewDataSource <NSObject>

@required
- (NSInteger)tableView:(LSCTableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (LSCTableViewCell *)tableView:(LSCTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)numberOfSectionsInTableView:(LSCTableView *)tableView; // default value is 1

@end

typedef NS_ENUM(NSInteger, LSCTableViewScrollPosition) {
  LSCTableViewScrollPositionNone,
  LSCTableViewScrollPositionTop,
  LSCTableViewScrollPositionMiddle,
  LSCTableViewScrollPositionBottom
}; // works the same as UITableViewScrollPosition

@interface LSCTableView : UIScrollView

@property(nonatomic, weak) id<LSCTableViewDelegate>   delegate;
@property(nonatomic, weak) id<LSCTableViewDataSource> dataSource;

- (LSCTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)reuseIdentifier;
- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(LSCTableViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void)reloadData;

@end
