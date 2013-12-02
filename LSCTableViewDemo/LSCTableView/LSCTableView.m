/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  LSCTableView.m
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

#import "LSCTableView.h"
#import "LSCTableViewModels.h"

#define kLSCTableViewDefaultRowHeight 42.f

#define RANGES_INTERSECT(location1, length1, location2, length2) ((location1 + length1 >= location2) && (location2 + length2 >= location1))

@interface LSCTableView ()

@property(nonatomic) NSArray *tableData; // each object = LSCTableViewSection.
                                         // available after the first time layoutSubviews or reloadData is called.

@property(nonatomic) NSMutableArray *visibleCells;
@property(nonatomic) NSUInteger      visibleCellsGlobalIndexOffset;
@property(nonatomic) NSMutableSet   *reusePool;

- (NSArray *)captureTableStructure;
- (void)layoutTableForYOffset:(CGFloat)yOffset height:(CGFloat)height;
- (void)enqueueReusableCell:(LSCTableViewCell *)cell withIdentifier:(NSString *)reuseIdentifier;
- (void)willDisplayCell:(LSCTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;     // default implementation does nothing

@end

@implementation LSCTableView

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.visibleCells  = [NSMutableArray array];
        self.reusePool    = [NSMutableSet set];
    }
    return self;
}

- (LSCTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)reuseIdentifier
{
    __block LSCTableViewCell *poolCell = nil;
    
    [self.reusePool enumerateObjectsUsingBlock:^(LSCTableViewCell *cell, BOOL *stop) {
        if([cell.reuseIdentifier isEqualToString:reuseIdentifier])
        {
            poolCell = cell;
            *stop = YES;
        }
    }];
    
    if(poolCell)
    {
        [self.reusePool removeObject:poolCell];
        [poolCell prepareForReuse];
    }
    
    return poolCell;
}

- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LSCTableViewSection *section = [self.tableData objectAtIndex:indexPath.section];
    
    CGFloat precedingRowsYOffset = 0.f;
    for(NSInteger i = 0; i < indexPath.row; i++)
    {
        precedingRowsYOffset += section.rowHeights[i];
    }
    
    CGFloat rowYOffset = section.yOffset + section.headerHeight + precedingRowsYOffset;
    CGFloat rowHeight  = section.rowHeights[indexPath.row];
    
    return CGRectMake(0.f, rowYOffset, self.frame.size.width, rowHeight);
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(LSCTableViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    CGRect rowRect = [self rectForRowAtIndexPath:indexPath];
    
    switch (scrollPosition) {
        case LSCTableViewScrollPositionNone:
            break;
            
        case LSCTableViewScrollPositionTop:
            rowRect.size.height = self.bounds.size.height;
            break;
            
        case LSCTableViewScrollPositionMiddle:
            rowRect.origin.y -= (self.bounds.size.height / 2.f) - rowRect.size.height;
            rowRect.size.height = self.bounds.size.height;
            break;
            
        case LSCTableViewScrollPositionBottom:
            rowRect.origin.y -= self.bounds.size.height - rowRect.size.height;
            rowRect.size.height = self.bounds.size.height;
            break;
    }
    
    [self scrollRectToVisible:rowRect animated:animated];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(self.tableData == nil) [self reloadData];
    
    [self layoutTableForYOffset:CGRectGetMinY(self.bounds) height:CGRectGetHeight(self.bounds)];
    
}

- (void)reloadData
{
    self.tableData = [self captureTableStructure];
    
    LSCTableViewSection *lastSection = [self.tableData lastObject];
    
    self.contentSize = CGSizeMake(self.bounds.size.width, lastSection.yOffset + lastSection.totalHeight);
}

#pragma mark - Private Methods

- (void)enqueueReusableCell:(LSCTableViewCell *)cell withIdentifier:(NSString *)reuseIdentifier
{
    cell.reuseIdentifier = reuseIdentifier;
    [self.reusePool addObject:cell];
}

- (NSArray *)captureTableStructure
{
    NSMutableArray *structure = [NSMutableArray array];
    
    NSInteger numberOfSections = [self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)] ?
    [self.dataSource numberOfSectionsInTableView:self] : 1;
    
    NSUInteger globalRowIndex = 0;
    CGFloat totalHeight = 0.f;
    CGFloat yOffset = 0.f;
    
    for(NSInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++)
    {
        // Section
        LSCTableViewSection *section = [LSCTableViewSection new];
        
        section.globalIndexOfFirstRow = globalRowIndex;
        globalRowIndex++;
        
        section.yOffset = yOffset;
        
        // Header
        if([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)])
        {
            CGFloat headerHeight = [self.delegate tableView:self heightForHeaderInSection:sectionIndex];
            
            section.headerHeight = headerHeight;
            totalHeight += headerHeight;
        }
        
        // Rows
        NSInteger numberOfRows = [self.dataSource tableView:self numberOfRowsInSection:sectionIndex];
        CGFloat *rowHeights = calloc(1, sizeof(CGFloat) * numberOfRows);
        
        if([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
        {
            for(NSInteger rowIndex = 0; rowIndex < numberOfRows; rowIndex++)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
                CGFloat rowHeight = [self.delegate tableView:self heightForRowAtIndexPath:indexPath];
                
                rowHeights[rowIndex] = rowHeight;
                totalHeight += rowHeight;
                globalRowIndex++;
            }
        }
        else
        {
            for(NSInteger rowIndex = 0; rowIndex < numberOfRows; rowIndex++)
            {
                rowHeights[rowIndex] = kLSCTableViewDefaultRowHeight;
                totalHeight += kLSCTableViewDefaultRowHeight;
                globalRowIndex++;
            }
        }
        
        [section setRowHeights:rowHeights count:numberOfRows];
        free(rowHeights);
        
        // Footer
        if([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)])
        {
            CGFloat footerHeight = [self.delegate tableView:self heightForFooterInSection:sectionIndex];
            
            section.footerHeight = footerHeight;
            totalHeight += footerHeight;
        }
        
        section.totalHeight = totalHeight;
        
        [structure addObject:section];
        
        totalHeight = 0.f;
        yOffset += totalHeight;
    }
    
    return structure;
}

#pragma mark Layout Methods

- (void)layoutTableForYOffset:(CGFloat)yOffset height:(CGFloat)height
{
    // Remove
    NSMutableArray *newVisibleCells = [NSMutableArray array];
    __block NSUInteger newVisibleCellsGlobalIndexOffset = self.visibleCellsGlobalIndexOffset;
    
    [self.visibleCells enumerateObjectsUsingBlock:^(LSCTableViewCell *cell, NSUInteger idx, BOOL *stop) {
        CGFloat cellYOffset = CGRectGetMinY(cell.frame);
        CGFloat cellHeight  = CGRectGetHeight(cell.frame);
        
        if(RANGES_INTERSECT(yOffset, height, cellYOffset, cellHeight))
        {
            if(newVisibleCells.count == 0)
            {
                newVisibleCellsGlobalIndexOffset = self.visibleCellsGlobalIndexOffset + idx;
            }
            
            [newVisibleCells addObject:cell];
        }
    }];
    
    [self.visibleCells removeObjectsInArray:newVisibleCells];
    
    [self.visibleCells enumerateObjectsUsingBlock:^(LSCTableViewCell *cell, NSUInteger idx, BOOL *stop) {
        [self enqueueReusableCell:cell withIdentifier:cell.reuseIdentifier];
        [cell removeFromSuperview];
    }];
    
    self.visibleCells = newVisibleCells;
    self.visibleCellsGlobalIndexOffset = newVisibleCellsGlobalIndexOffset;
    
    // Add
    NSIndexSet *sectionIndexesThatShouldBeVisible = [self.tableData indexesOfObjectsPassingTest:^BOOL(LSCTableViewSection *section, NSUInteger idx, BOOL *stop) {
        if(RANGES_INTERSECT(yOffset, height, section.yOffset, section.totalHeight)) { return YES; }
        else if(section.yOffset > yOffset + height) { *stop = YES; return NO; }
        else { return NO; }
    }];
    
    NSIndexSet *visibleCellGlobalRowIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.visibleCellsGlobalIndexOffset, self.visibleCells.count)];
    
    NSMutableArray *cellsToAdd = [NSMutableArray array];
    __block NSUInteger cellsToAddGlobalIndexOffset = 0;
    
    [self.tableData enumerateObjectsAtIndexes:sectionIndexesThatShouldBeVisible
                                      options:0
                                   usingBlock:^(LSCTableViewSection *section, NSUInteger idx, BOOL *stop) {
                                       NSRange sectionGlobalRowIndexRange = NSMakeRange(section.globalIndexOfFirstRow, section.numberOfRows);
                                       
                                       if(![visibleCellGlobalRowIndexSet containsIndexesInRange:sectionGlobalRowIndexRange])
                                       {
                                           CGFloat precedingRowsYOffset = 0.f;
                                           for(NSInteger i = 0; i < section.numberOfRows; i++)
                                           {
                                               NSUInteger globalRowIndex = section.globalIndexOfFirstRow + i;
                                               CGFloat rowYOffset = section.yOffset + section.headerHeight + precedingRowsYOffset;
                                               CGFloat rowHeight  = section.rowHeights[i];
                                               
                                               if(![visibleCellGlobalRowIndexSet containsIndex:globalRowIndex] && RANGES_INTERSECT(yOffset, height, rowYOffset, rowHeight))
                                               {
                                                   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:idx];
                                                   
                                                   LSCTableViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
                                                   cell.frame = CGRectMake(0.f, rowYOffset, self.frame.size.width, rowHeight);
                                                   [self willDisplayCell:cell forRowAtIndexPath:indexPath];
                                                   [self addSubview:cell];
                                                   
                                                   if(cellsToAdd.count == 0)
                                                   {
                                                       cellsToAddGlobalIndexOffset = globalRowIndex;
                                                   }
                                                   [cellsToAdd addObject:cell];
                                               }
                                               
                                               precedingRowsYOffset += rowHeight;
                                           }
                                       }
                                   }];
    
    if(cellsToAdd.count > 0)
    {
        if(cellsToAddGlobalIndexOffset > self.visibleCellsGlobalIndexOffset)
        {
            [self.visibleCells addObjectsFromArray:cellsToAdd];
        }
        else
        {
            self.visibleCellsGlobalIndexOffset = cellsToAddGlobalIndexOffset;
            [self.visibleCells insertObjects:cellsToAdd atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, cellsToAdd.count)]];
        }
    }
}

- (void)willDisplayCell:(LSCTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // do nothing
}

@end
