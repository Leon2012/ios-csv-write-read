//
//  ITCSVReader.m
//
//
//  Created by Peng Leon on 12/9/7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WPCSVReader.h"
#import "WPCSVParser.h"
#import "NSStream+Util.h"

#define DEFAULT_SKIP_LINES 0

@interface WPCSVReader(Private)
-(NSString *)getNextLine;
@end

@implementation WPCSVReader

-(void)dealloc{
    _R(_reader);
    _R(_parser);
    [super dealloc];
}

-(id)initWithStream:(NSInputStream *)aReader{
    WPCSVParser *parser = [[[WPCSVParser alloc] initWithDefault] autorelease];
    return [self initWithStream:aReader parser:parser];
}

-(id)initWithStream:(NSInputStream *)aReader parser:(WPCSVParser *)aParser{
    return [self initWithStream:aReader parser:aParser skipLines:DEFAULT_SKIP_LINES];
}

-(id)initWithStream:(NSInputStream *)aReader parser:(WPCSVParser *)aParser skipLines:(int)aSkipLines{
    self = [super init];
    if (self) {
        _reader = [aReader retain];
        _parser = [aParser retain];
        _hasNext = YES;
        _skipLines = aSkipLines;
        _linesSkiped = NO;
    }
    return self;
}

-(NSMutableArray *)readAll{
    NSMutableArray *result = [NSMutableArray array];
    while (_hasNext) {
        NSArray *nextLineAsTokens = [self readNext];
        if (nextLineAsTokens != nil) {
            [result addObject:nextLineAsTokens];
        }
    }
    return result;
}

-(NSArray *)readNext{
    NSArray *result = nil;
    do {
        NSString *nextLine = [self getNextLine];
        if (!_hasNext) {
            return result;
        }
        NSArray *r = [_parser parseLineMulti:nextLine];
        if ([r count] > 0) {
            if (result == nil) {
                result = r;
            }else{
                NSMutableArray *t = [NSMutableArray arrayWithCapacity:([result count] + ([r count]))];
                [t addObjectsFromArray:result];
                [t addObjectsFromArray:r];
                result = [NSArray arrayWithArray:t];
            }
        }
    } while ([_parser isPending]);
    return result;
}

-(NSString *)getNextLine{
    _hasNext = YES;
    if (!_linesSkiped) {
        for (int i=0; i < _skipLines; i++) {
            [_reader readLine];
        }
        _linesSkiped = YES;
    }
    NSString *nextLine = [_reader readLine];
    if (nextLine == nil) {
        _hasNext = NO;
    }
    return nextLine;
}



@end
