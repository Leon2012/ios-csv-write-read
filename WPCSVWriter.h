//
//  ITCSVWriter.h
//
//
//  Created by Peng Leon on 12/9/7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPCSVWriter : NSObject{
    NSString            *_separator;
    NSString            *_quotechar;
    NSString            *_escapechar;
    NSString            *_lineEnd;
    NSOutputStream      *_writer;
}

-(id)initWithStream:(NSOutputStream *)aWriter;
-(id)initWithStream:(NSOutputStream *)aWriter separator:(NSString *)aSeparator quotechar:(NSString *)aQuotechar escapechar:(NSString *)aEscapechar;
-(void)writeNext:(NSArray *)nextLine applyQuotesToAll:(BOOL)applyQuotesToAll;
-(void)writeNext:(NSArray *)nextLine;
@end
