//
//  FFmpegManager.m
//  CocoaAsyncSocket_FFmpeg_Player
//
//  Created by Jiaxiang Li on 16/8/22.
//  Copyright © 2016年 Jiaxiang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFmpegManager.h"
#import "libavcodec/avcodec.h"
#import "libswscale/swscale.h"
#import "Utilities.h"

static const int defaultOutputWidth = 320;
static const int defaultOutputHeight = 240;

@interface FFmpegManager () {
    AVPacket packet;
    AVCodec *codec;
    AVCodecContext *codecCtx;
    AVFrame *frame;
    AVPicture picture;
    struct SwsContext *img_convert_ctx;
    
    int picNum;
}

@end

@implementation FFmpegManager

-(NSNumber *) outputWidht {
    if (_outputWidht == nil) {
        _outputWidht = [NSNumber numberWithInt:defaultOutputWidth];
    }
    
    return _outputWidht;
}

-(NSNumber *) outputHeight {
    if (_outputHeight == nil) {
        _outputHeight = [NSNumber numberWithInt:defaultOutputHeight];
    }
    
    return _outputHeight;
}


+(FFmpegManager *) sharedManager {
    static FFmpegManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return  instance;
}

-(instancetype) init {
    self = [super init];
    
    if (self) {
        avcodec_register_all();
        frame = av_frame_alloc();
        codec = avcodec_find_decoder(AV_CODEC_ID_H264);
        codecCtx = avcodec_alloc_context3(codec);
        picNum = 0;
        
        int ret = avcodec_open2(codecCtx, codec, nil);
        if (ret != 0) {
            NSLog(@"Open codec failed :%d",ret);
        }
    }
    
    return self;
}


-(UIImage *) acceptFramData:(NSData *)frameData {
    av_new_packet(&packet, (int)frameData.length);
    memcpy(packet.data,frameData.bytes,(int) frameData.length);
    
    int ret, got_picture;
    ret = avcodec_decode_video2(codecCtx,frame,&got_picture,&packet);
    av_free_packet(&packet);
    
    if(ret < 0) {
        NSLog(@"Decode Error!");
        return nil;
    }
    
    if(!got_picture) {
        NSLog(@"Can't get picture!");
        return nil;
    }
    
    if (!frame->data[0]) {
        NSLog(@"Frame Error!");
        return nil;
    }
    
    picNum ++;
    
    [self savePicture:picture width:[_outputWidht intValue] height:[_outputHeight intValue] index:picNum data:frameData];
    [self convertFrameToRGB];
    return [self imageFromAVPicture:picture width:[_outputWidht intValue] height:[_outputHeight intValue]];
}

-(void) savePicture:(AVPicture)pict width:(int)width height:(int)height index:(int)iFrame data:(NSData *)data {
    FILE *pFile;
    NSString *fileName;
    
    fileName = [Utilities documentsPath:[NSString stringWithFormat:@"image%04d.bmp",iFrame]];
    
    pFile = fopen([fileName cStringUsingEncoding:NSASCIIStringEncoding], "wb");
    if (pFile == NULL) {
        return;
    }
    
    fwrite(&pict.data, data.length, 1, pFile);
    
    fclose(pFile);
    
    avpicture_free(&picture);
    sws_freeContext(img_convert_ctx);
    
    avpicture_alloc(&picture,AV_PIX_FMT_RGB32,[_outputWidht intValue],[_outputHeight intValue]);
    
    static int sws_flags = SWS_FAST_BILINEAR;
    img_convert_ctx = sws_getContext(codecCtx->width, codecCtx->height, codecCtx->pix_fmt, [_outputWidht intValue], [_outputHeight intValue], AV_PIX_FMT_RGB32, sws_flags, NULL, NULL, NULL);
}


-(void)convertFrameToRGB {
    sws_scale (img_convert_ctx, frame->data, frame->linesize,
               0, codecCtx->height,
               picture.data, picture.linesize);
}

-(UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height {
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pict.data[0], pict.linesize[0]*height,kCFAllocatorNull);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       8,
                                       24,
                                       pict.linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
    return image;
}

@end
