/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  LSCTableViewModels.h
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

#import <Foundation/Foundation.h>

@interface LSCTableViewSection : NSObject

@property(nonatomic, readwrite) NSUInteger globalIndexOfFirstRow;
@property(nonatomic, readwrite) CGFloat    totalHeight;
@property(nonatomic, readwrite) CGFloat    yOffset;
@property(nonatomic, readonly)  NSInteger  numberOfRows;
@property(nonatomic, readonly)  CGFloat    *rowHeights; // C array pointer. uses custom setter.
@property(nonatomic, readwrite) CGFloat    headerHeight;
@property(nonatomic, readwrite) CGFloat    footerHeight;

// Assigns both `self.rowHeights` and `self.numberOfRows` properties.
// `rowHeights` should be a pointer to a CGFloat array that contains `numberOfRows` number of CGFloats.
- (void)setRowHeights:(CGFloat *)rowHeights count:(NSUInteger)numberOfRows;

- (NSUInteger)globalIndexOfLastRow;

@end