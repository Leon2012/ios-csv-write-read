//
//  ITCSVParser.m
//
//
//  Created by Peng Leon on 12/9/7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#define DEFAULT_SEPARATOR                   @","
#define INITIAL_READ_SIZE                   128
#define DEFAULT_QUOTE_CHARACTER             @"\""
#define DEFAULT_ESCAPE_CHARACTER            @"\\"
#define DEFAULT_STRICT_QUOTES               NO
#define DEFAULT_IGNORE_LEADING_WHITESPACE   YES
#define DEFAULT_IGNORE_QUOTATIONS           NO
#define NULL_CHARACTER                      @"\0"

#import "WPCSVParser.h"
#import "WPException.h"

@interface WPCSVParser(Private)
-(BOOL)isSame:(NSString *)c1 andString:(NSString *)c2;
-(BOOL)anyCharactersAreTheSame:(NSString *)aSeparator quotechar:(NSString *)aQuotechar escape:(NSString *)aEscape;
-(BOOL)isNextCharacterEscapable:(NSString *)nextLine inQuotes:(BOOL)inQuotes index:(int)index;
-(BOOL)isNextCharacterEscapedQuote:(NSString *)nextLine inQuotes:(BOOL)inQuotes index:(int)index; 
-(BOOL)isAllWhiteSpace:(NSMutableString *)sb;
@end

@implementation WPCSVParser

-(void)dealloc{
    _R(_separator);
    _R(_quotechar);
    _R(_escape);
    _R(_pending);
    [super dealloc];
}

-(WPCSVParser *)initWithDefault{
    return [self initWithSeparator:DEFAULT_SEPARATOR quotechar:DEFAULT_QUOTE_CHARACTER escape:DEFAULT_ESCAPE_CHARACTER strictQuotes:DEFAULT_STRICT_QUOTES ignoreLeadingWhiteSpace:DEFAULT_IGNORE_LEADING_WHITESPACE ignoreQuotations:DEFAULT_IGNORE_QUOTATIONS];
}

-(id)initWithSeparator:(NSString *)aSeparator quotechar:(NSString *)aQuotechar escape:(NSString *)aEscape strictQuotes:(BOOL)aStrictQuotes ignoreLeadingWhiteSpace:(BOOL)aIgnoreLeadingWhiteSpace ignoreQuotations:(BOOL)aIgnoreQuotations{
    self = [super init];
    if (self) {
        if ([self anyCharactersAreTheSame:aSeparator quotechar:aQuotechar escape:aEscape]) {
            @throw [WPException exceptionWithObject:self reason:@"The separator, quote, and escape characters must be different!"];
        }
        if ([aSeparator isEqualToString:NULL_CHARACTER]) {
            @throw [WPException exceptionWithObject:self reason:@"The separator character must be defined!"];
        }
        _separator = aSeparator;
        _quotechar = aQuotechar;
        _escape = aEscape;
        _strictQuotes = aStrictQuotes;
        _ignoreLeadingWhiteSpace = aIgnoreLeadingWhiteSpace;
        _ignoreQuotations = aIgnoreQuotations;
    }
    return self;
}

-(BOOL)isSame:(NSString *)c1 andString:(NSString *)c2{
    return ![c1 isEqualToString:NULL_CHARACTER] && [c1 isEqualToString:c2];
}

-(BOOL)anyCharactersAreTheSame:(NSString *)aSeparator quotechar:(NSString *)aQuotechar escape:(NSString *)aEscape{
    return [self isSame:aSeparator andString:aQuotechar] || [self isSame:aSeparator andString:aEscape] || [self isSame:aQuotechar andString:aEscape];
}

-(BOOL)isNextCharacterEscapable:(NSString *)nextLine inQuotes:(BOOL)inQuotes index:(int)index{
    if ([nextLine length] <= (index + 1)) {
        return NO;
    }
    NSRange range = NSMakeRange(index+1, 1);
    NSString *nextChar = [nextLine substringWithRange:range];
    return inQuotes && ([nextChar isEqualToString:_quotechar] || [nextChar isEqualToString:_escape]);
}

-(BOOL)isNextCharacterEscapedQuote:(NSString *)nextLine inQuotes:(BOOL)inQuotes index:(int)index{
    if ([nextLine length] <= (index + 1)) {
        return NO;
    }
    NSRange range = NSMakeRange(index+1, 1);
    NSString *nextChar = [nextLine substringWithRange:range];
    return inQuotes && ([nextChar isEqualToString:_quotechar]);
}

-(BOOL)isAllWhiteSpace:(NSMutableString *)sb{
    BOOL result = YES;
    for (int i=0; i<[sb length]; i++) {
        NSString *c = [sb substringWithRange:NSMakeRange(i, 1)];
        if (![@" " isEqualToString:c]) {
            return NO;
        }
    }
    return result;
}

-(BOOL)isPending{
    return _pending != nil;
}

-(NSArray *)parseLineMulti:(NSString *)nextLine{
    return [self parseLine:nextLine multi:YES];
}

-(NSArray *)parseLine:(NSString *)nextLine{
    return [self parseLine:nextLine multi:NO];
}

-(NSArray *)parseLine:(NSString *)nextLine multi:(BOOL)multi{
    if (!multi && _pending != nil) {
        _pending = nil;
    }
    if (nextLine == nil) {
        if (_pending != nil) {
            NSString *s = _pending;
            _pending = nil;
            return [NSArray arrayWithObject:s];
        }else{
            return nil;
        }
    }
    NSMutableArray *tokensOnThisLine = [NSMutableArray array];
    NSMutableString *sb = [NSMutableString string];
    BOOL inQuotes = NO;
    if (_pending != nil) {
        [sb appendString:_pending];
        _pending = nil;
        inQuotes = !_ignoreQuotations;
    }
    
    for (int i=0; i<[nextLine length]; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *c = [nextLine substringWithRange:range];
        if ([c isEqualToString:_escape]) {
            if ([self isNextCharacterEscapable:nextLine inQuotes:((inQuotes && !_ignoreQuotations) || _inField) index:i]) {
                [sb appendString:[nextLine substringWithRange:NSMakeRange(i+1, 1)]];
                i++;
            }
        
        }else if ([c isEqualToString:_quotechar]){
            if ([self isNextCharacterEscapedQuote:nextLine inQuotes:((inQuotes && !_ignoreQuotations) || _inField) index:i]) {
                [sb appendString:[nextLine substringWithRange:NSMakeRange(i+1, 1)]];
                i++;
            }else{
                inQuotes = !inQuotes;
                if (!_strictQuotes) {
                    if (i > 2 && ![_separator isEqualToString:[nextLine substringWithRange:NSMakeRange(i-1, 1)]] && ([nextLine length] > (i+1)) && ![_separator isEqualToString:[nextLine substringWithRange:NSMakeRange(i+1, 1)]]) {
                        
                        if (_ignoreLeadingWhiteSpace && ([sb length] > 0) && [self isAllWhiteSpace:sb]) {
                            sb = [NSMutableString stringWithCapacity:INITIAL_READ_SIZE];
                        }else{
                            [sb appendString:c];
                        }
                        
                    }
                }
            }
            _inField = !_inField;
        
        }else if ([c isEqualToString:_separator] && !(inQuotes && !_ignoreQuotations)){
            [tokensOnThisLine addObject:[NSString stringWithString:sb]];
            sb = [NSMutableString stringWithCapacity:INITIAL_READ_SIZE];
            _inField = NO;
            
        }else {
            if (!_strictQuotes || (inQuotes && !_ignoreQuotations)) {
                [sb appendString:c];
                _inField = YES;
            }
        }
    }
    
    if (sb != nil) {
        [tokensOnThisLine addObject:[NSString stringWithString:sb]];
    }
    return [NSArray arrayWithArray:tokensOnThisLine];
}











@end
