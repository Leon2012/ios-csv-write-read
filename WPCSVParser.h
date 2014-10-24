//
//  ITCSVParser.h
//
//
//  Created by Peng Leon on 12/9/7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WPCSVParser : NSObject{
    NSString        *_separator;
    NSString        *_quotechar;
    NSString        *_escape;
    BOOL            _strictQuotes;
    NSString        *_pending;
    BOOL            _inField;
    BOOL            _ignoreLeadingWhiteSpace;
    BOOL            _ignoreQuotations;
}

-(WPCSVParser *)initWithDefault;
-(id)initWithSeparator:(NSString *)aSeparator quotechar:(NSString *)aQuotechar escape:(NSString *)aEscape strictQuotes:(BOOL)aStrictQuotes ignoreLeadingWhiteSpace:(BOOL)aIgnoreLeadingWhiteSpace ignoreQuotations:(BOOL)aIgnoreQuotations;
-(BOOL)isPending;
-(NSArray *)parseLine:(NSString *)nextLine multi:(BOOL)multi;
-(NSArray *)parseLine:(NSString *)nextLine;
-(NSArray *)parseLineMulti:(NSString *)nextLine;
@end
