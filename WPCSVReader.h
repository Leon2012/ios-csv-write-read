//
//  ITCSVReader.h
//
//
//  Created by Peng Leon on 12/9/7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WPCSVParser;
@interface WPCSVReader : NSObject{
    NSInputStream       *_reader;
    BOOL                _hasNext;
    WPCSVParser         *_parser;
    int                 _skipLines;
    BOOL                _linesSkiped;
}

-(id)initWithStream:(NSInputStream *)aReader;
-(id)initWithStream:(NSInputStream *)aReader parser:(WPCSVParser *)aParser;
-(id)initWithStream:(NSInputStream *)aReader parser:(WPCSVParser *)aParser skipLines:(int)aSkipLines;
-(NSMutableArray *)readAll;
-(NSArray *)readNext;
@end
