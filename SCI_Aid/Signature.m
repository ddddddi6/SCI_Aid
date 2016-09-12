//
//  Signature.m
//  SCI_Aid
//
//  Created by Dee on 17/08/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Signature.h"

#import <CommonCrypto/CommonHMAC.h>


@implementation Signature

- (NSURL*) generateURLWithDevIDAndKey:(NSString*)urlPath {
    
    NSString *hardcodedURL = @"http://timetableapi.ptv.vic.gov.au";
    NSString *hardcodedDevID = @"1000836";
    NSString *hardcodedkey = @"3d7ffa10-6445-11e6-a0ce-06f54b901f07";
    
    /*    urlPath = @" http://timetableapi.ptv.vic.gov.au/v2/mode/2/line/787/stops-for-line";
     */
    NSRange deleteRange ={0,[hardcodedURL length]};
    NSMutableString *urlString = [[NSMutableString alloc]initWithString:urlPath];
    [urlString deleteCharactersInRange:deleteRange];
    if( [urlString containsString:@"?"])
        [urlString appendString:@"&"];
    else
        [urlString appendString:@"?"];
    
    [urlString appendFormat:@"devid=%@",hardcodedDevID];
    
    
    const char *cKey  = [hardcodedkey cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [urlString cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSString *hash;
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    
    NSString* signature = [hash uppercaseString];
    NSString *urlSuffix = [NSString stringWithFormat:@"devid=%@&signature=%@", hardcodedDevID,signature];
    
    NSURL *url = [NSURL URLWithString:urlPath];
    NSString *urlQuery = [url query];
    if(urlQuery != nil && [urlQuery length] > 0){
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&%@",urlPath,urlSuffix]];
    }else{
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",urlPath,urlSuffix]];
    }
    
    return url;
}

@end

