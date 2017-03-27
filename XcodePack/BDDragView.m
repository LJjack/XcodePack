//
//  BDDragView.m
//  MacTest
//
//  Created by 刘俊杰 on 2017/2/9.
//  Copyright © 2017年 天翼. All rights reserved.
//

#import "BDDragView.h"
#import "NSAlert+LJAdd.h"

@implementation BDDragView {
    BOOL highlight; //highlight the drop zone
    BOOL smoothSizes; // use blurry fractional sizes for smooth animation during live resize
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

//Destination Operations
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    highlight = YES;
    [self setNeedsDisplay:YES];
    return NSDragOperationCopy;
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag {
    return NSDragOperationCopy; //send data as copy operation
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    highlight = NO; //remove highlight of the drop zone
    [self setNeedsDisplay:YES];
}

- (void)viewWillStartLiveResize {
    smoothSizes = YES;
    [super viewWillStartLiveResize];
}

- (void)drawRect:(NSRect)rect {
    if (NSAppKitVersionNumber < NSAppKitVersionNumber10_10) {
        [[NSColor windowBackgroundColor] setFill];
    } else {
        [[NSColor clearColor] set];
    }
    NSRectFillUsingOperation(rect, NSCompositingOperationSourceOver);
    
    NSColor *gray = [NSColor colorWithDeviceWhite:0 alpha:highlight ? 1.0/4.0 : 1.0/8.0];
    [gray set];
    [gray setFill];
    
    NSRect bounds = [self bounds];
    CGFloat size = MIN(bounds.size.width/4.0, bounds.size.height/1.5);
    CGFloat width = MAX(2.0, size/32.0);
    NSRect frame = NSMakeRect((bounds.size.width-size)/2.0, (bounds.size.height-size)/2.0, size, size);
    
    if (!smoothSizes) {
        width = round(width);
        size = ceil(size);
        frame = NSMakeRect(round(frame.origin.x)+((int)width&1)/2.0, round(frame.origin.y)+((int)width&1)/2.0, round(frame.size.width), round(frame.size.height));
    }
    
    [NSBezierPath setDefaultLineWidth:width];
    
    NSBezierPath *p = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:size/14.0 yRadius:size/14.0];
    const CGFloat dash[2] = {size/10.0, size/16.0};
    [p setLineDash:dash count:2 phase:2];
    [p stroke];
    
    NSBezierPath *r = [NSBezierPath bezierPath];
    CGFloat baseWidth=size/8.0, baseHeight = size/8.0, arrowWidth=baseWidth*2, pointHeight=baseHeight*3.0, offset=-size/8.0;
    [r moveToPoint:NSMakePoint(bounds.size.width/2.0 - baseWidth, bounds.size.height/2.0 + baseHeight - offset)];
    [r lineToPoint:NSMakePoint(bounds.size.width/2.0 + baseWidth, bounds.size.height/2.0 + baseHeight - offset)];
    [r lineToPoint:NSMakePoint(bounds.size.width/2.0 + baseWidth, bounds.size.height/2.0 - baseHeight - offset)];
    [r lineToPoint:NSMakePoint(bounds.size.width/2.0 + arrowWidth, bounds.size.height/2.0 - baseHeight - offset)];
    [r lineToPoint:NSMakePoint(bounds.size.width/2.0, bounds.size.height/2.0 - pointHeight - offset)];
    [r lineToPoint:NSMakePoint(bounds.size.width/2.0 - arrowWidth, bounds.size.height/2.0 - baseHeight - offset)];
    [r lineToPoint:NSMakePoint(bounds.size.width/2.0 - baseWidth, bounds.size.height/2.0 - baseHeight - offset)];
    [r fill];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    highlight = NO; //finished with the drag so remove any highlighting
    [self setNeedsDisplay:YES];
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    if ([sender draggingSource] != self) {
        NSArray* filePaths = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
        
        NSString *fileName = filePaths.firstObject;
        if (![fileName hasSuffix:@".xcodeproj"] && ![fileName hasSuffix:@".xcworkspace"]) {
            [NSAlert lj_alertWithMessage:@"警告" infoText:@"文件不是.xcodeproj或.xcworkspace"];
            return YES;
        }
        self.hidden = YES;
        if (self.didFinishPath) {
            self.didFinishPath(fileName);
        }
    }
    
    return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES; //so source doesn't have to be the active window
}

@end
