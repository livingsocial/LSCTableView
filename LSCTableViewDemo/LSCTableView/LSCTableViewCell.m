/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  LSCTableViewCell.m
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

#import "LSCTableViewCell.h"

#define kLSCTableViewCellSidePadding 10.f

@interface LSCTableViewCell ()

@property(nonatomic, readwrite) UILabel *textLabel;

@end

@implementation LSCTableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithFrame:CGRectZero])
    {
        self.reuseIdentifier = reuseIdentifier;
    }
    return self;
}

- (void)prepareForReuse
{
    // default implementation does nothing
}

- (UILabel *)textLabel
{
    if(_textLabel == nil)
    {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        [self addSubview:_textLabel];
    }
    
    return _textLabel;
}

- (void)layoutSubviews
{
    if(_textLabel)
    {
        _textLabel.frame = self.bounds;
    }
}

@end
