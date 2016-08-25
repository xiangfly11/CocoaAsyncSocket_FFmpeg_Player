//
//  SocketManager.m
//  CocoaAsyncSocket_FFmpeg_Player
//
//  Created by Jiaxiang Li on 16/8/22.
//  Copyright © 2016年 Jiaxiang Li. All rights reserved.
//

#import "SocketManager.h"
#import <netinet/in.h>
#import <netinet/tcp.h>
#import <arpa/inet.h>

static NSString *const host = @"192.168.0.1";
static const NSInteger port = 4000;


@interface SocketManager ()<AsyncSocketDelegate>

@property (nonatomic,strong) AsyncSocket *socket;
@end

@implementation SocketManager

-(NSString *) hostName {
    if (_hostName == nil) {
        _hostName = host;
    }
    
    return _hostName;
}

-(NSNumber *) portNum {
    if (_portNum == nil) {
        _portNum = [NSNumber numberWithInteger:port];
    }
    
    return _portNum;
}


+(SocketManager *) sharedManager {
    static SocketManager *instance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[SocketManager alloc] init];
    });
    
    return instance;
    
}

-(instancetype) init {
    self = [super init];
    
    if (self) {
        _socket = [[AsyncSocket alloc] initWithDelegate:self];
    }
    
    return self;
}

-(void) socketConnectToHost {
    NSError *error;
    
    [_socket connectToHost:_hostName onPort:[_portNum intValue] error:&error];
    
    if (error) {
        NSLog(@"Socket Connection Failed:%@",error.localizedDescription);
    }
    
}

-(void) readDataWithLength:(NSNumber *)length {
    if (length == nil) {
        [self readData];
    }
    
    [_socket readDataToLength:[length integerValue] withTimeout: _timeOut tag:tagOne];
}

-(void) readData {
    
    [_socket readDataWithTimeout: _timeOut tag:tagThree];
    
}

#pragma  mark -- AsyncSocketDelegate

-(void) onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Socket Connection Success!");
}


-(void) onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (tag == tagThree) {
        [_delegate sendResponseData:data];
    }else if (tag == tagOne) {
        int i;
        [data getBytes:&i length:sizeof(i)];
        
        [_socket readDataToLength:i withTimeout:_timeOut tag:tagTwo];
    }else if (tag == tagTwo) {
        [_delegate sendResponseData:data];
    }
}



@end
