//
//  FFmpegManager.h
//  CocoaAsyncSocket_FFmpeg_Player
//
//  Created by Jiaxiang Li on 16/8/22.
//  Copyright © 2016年 Jiaxiang Li. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FFmpegManager : NSObject

@property (nonatomic,strong) NSNumber *outputWidht;
@property (nonatomic,strong) NSNumber *outputHeight;

+(FFmpegManager *) sharedManager;

-(UIImage *) acceptFramData:(NSData *) frameData;



@end
