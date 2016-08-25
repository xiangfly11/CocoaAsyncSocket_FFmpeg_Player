//
//  SocketManager.h
//  CocoaAsyncSocket_FFmpeg_Player
//
//  Created by Jiaxiang Li on 16/8/22.
//  Copyright © 2016年 Jiaxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

typedef enum : NSUInteger {
    tagOne = 1,
    tagTwo,
    tagThree,
} myTag;

@protocol SocketManagerDelegate;

@interface SocketManager : NSObject

@property (nonatomic,strong) NSString *hostName;
@property (nonatomic,assign) NSNumber *portNum;
@property (nonatomic,assign) NSTimeInterval timeOut;

@property (nonatomic,weak) id<SocketManagerDelegate> delegate;

+(SocketManager *) sharedManager;
-(void) socketConnectToHost;
-(void) readData;
-(void) readDataWithLength:(NSNumber *) length;

@end

@protocol SocketManagerDelegate <NSObject>

@required

-(void) sendResponseData:(NSData *) responseData;

@end
