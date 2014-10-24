//
//  ITCSVWriter.m
//
//
//  Created by Peng Leon on 12/9/7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WPCSVWriter.h"
#import "NSStream+Util.h"

#define NO_QUOTE_CHARACTER  @"\\u0000" //unicode 16 进制 转 NSString 需要 \\u
#define NO_ESCAPE_CHARACTER @"\\u0000"
#define DEFAULT_LINE_END    @"\n"

@interface WPCSVWriter(Private) 
-(BOOL)stringContainsSpecialCharacters:(NSString *)line;
-(NSMutableString *)processLine:(NSString *)nextElement;
@end


@implementation WPCSVWriter

-(void)dealloc{
    _R(_separator);
    _R(_quotechar);
    _R(_escapechar);
    _R(_lineEnd);
    _R(_writer);
    [super dealloc];
}

-(id)initWithStream:(NSOutputStream *)writer{
    NSString *aSeparator  = @",";
    NSString *aQuotechar  = @"\"";
    NSString *aEscapechar = @"\\";
    id csvWriter = [self initWithStream:writer separator:aSeparator quotechar:aQuotechar escapechar:aEscapechar];
    return csvWriter;
}


-(id)initWithStream:(NSOutputStream *)aWriter separator:(NSString *)aSeparator quotechar:(NSString *)aQuotechar escapechar:(NSString *)aEscapechar{
    self = [super init];
    if (self) {
        _writer = [aWriter retain];
        _separator = aSeparator;
        _quotechar = aQuotechar;
        _escapechar = aEscapechar;
        _lineEnd = @"\r";
    }
    return self;
}

-(void)writeNext:(NSArray *)nextLine applyQuotesToAll:(BOOL)applyQuotesToAll{
    if (nextLine == nil) {
        return;
    }
    NSMutableString *stringBuffer = [NSMutableString string];
    for (int i=0; i<[nextLine count]; i++) {
        if (i != 0) {
            [stringBuffer appendString:_separator];
        }
        NSString *nextElement = [nextLine objectAtIndex:i];
        BOOL stringContainsSpecialCharacters = [self stringContainsSpecialCharacters:nextElement];
        if ((applyQuotesToAll || stringContainsSpecialCharacters) && ![_quotechar isEqualToString:NO_QUOTE_CHARACTER]) {
            [stringBuffer appendString:_quotechar];
        }
        if (stringContainsSpecialCharacters) {
            [stringBuffer appendString:[NSString stringWithString:[self processLine:nextElement]]];
        }else{
            [stringBuffer appendString:nextElement];
        }
        
        if ((applyQuotesToAll || stringContainsSpecialCharacters) && ![_quotechar isEqualToString:NO_QUOTE_CHARACTER]) {
            [stringBuffer appendString:_quotechar];
        }
    }
    [_writer writeLine:[NSString stringWithString:stringBuffer]];
}

-(void)writeNext:(NSArray *)nextLine{
    [self writeNext:nextLine applyQuotesToAll:YES];
}

-(BOOL)stringContainsSpecialCharacters:(NSString *)line{
    return ([line rangeOfString:_quotechar].length > 0 ) || ([line rangeOfString:_escapechar].length > 0) || ([line rangeOfString:@"\n"].length > 0) || ([line rangeOfString:@"\r"].length > 0);
}

-(NSMutableString *)processLine:(NSString *)nextElement{
    NSMutableString *sb = [NSMutableString string];
    for (int j=0; j<[nextElement length]; j++) {
        NSRange range = NSMakeRange(j, 1);
        NSString *nextChar = [nextElement substringWithRange:range];
        if (![_escapechar isEqualToString:NO_ESCAPE_CHARACTER] && [nextChar isEqualToString:_quotechar]) {
            [sb appendString:_escapechar];
            [sb appendString:nextChar];
        }else if (![_escapechar isEqualToString:NO_ESCAPE_CHARACTER] && [nextChar isEqualToString:_escapechar]){
            [sb appendString:_escapechar];
            [sb appendString:nextChar];
        }else{
            [sb appendString:nextChar];
        }
    }
    return sb;
}


@end
