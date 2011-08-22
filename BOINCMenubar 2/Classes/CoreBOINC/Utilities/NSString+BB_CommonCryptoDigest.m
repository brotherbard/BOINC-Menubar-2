//
//  NSString+BB_CommonCryptoDigest.m
//
//  Created by BrotherBard on 4/12/09.
//  Copyright 2009 BrotherBard <nkinsinger at brotherbard dot com>. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright notice, this
//       list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright notice,
//       this list of conditions and the following disclaimer in the documentation 
//       and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSString+BB_CommonCryptoDigest.h"
#import "CommonCrypto/CommonDigest.h"


@implementation NSString (BB_CommonCryptoDigest)

// private
- (NSString *)bbHashFromDigest:(unsigned char*)digest length:(NSUInteger)length
{
    NSMutableString *hash = [NSMutableString string];
    for (NSUInteger i = 0; i < length; i++)
        [hash appendFormat:@"%02x", digest[i]];
    
    return [[hash copy] autorelease];
}


- (NSString *)bbMD2Hash
{
	NSUInteger digestLength = CC_MD2_DIGEST_LENGTH;
    unsigned char digest[digestLength];
    CC_MD2([self UTF8String], (CC_LONG)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    
    return [self bbHashFromDigest:digest length:digestLength];
}


- (NSString *)bbMD4Hash
{
	NSUInteger digestLength = CC_MD4_DIGEST_LENGTH;
    unsigned char digest[digestLength];
    CC_MD4([self UTF8String], (CC_LONG)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    
    return [self bbHashFromDigest:digest length:digestLength];
}


- (NSString *)bbMD5Hash
{
	NSUInteger digestLength = CC_MD5_DIGEST_LENGTH;
    unsigned char digest[digestLength];
    CC_MD5([self UTF8String], (CC_LONG)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    
    return [self bbHashFromDigest:digest length:digestLength];
}


- (NSString *)bbSHA1Hash
{
	NSUInteger digestLength = CC_SHA1_DIGEST_LENGTH;
    unsigned char digest[digestLength];
    CC_SHA1([self UTF8String], (CC_LONG)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    
    return [self bbHashFromDigest:digest length:digestLength];
}


- (NSString *)bbSHA224Hash
{
	NSUInteger digestLength = CC_SHA224_DIGEST_LENGTH;
    unsigned char digest[digestLength];
    CC_SHA224([self UTF8String], (CC_LONG)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    
    return [self bbHashFromDigest:digest length:digestLength];
}


- (NSString *)bbSHA256Hash
{
	NSUInteger digestLength = CC_SHA256_DIGEST_LENGTH;
    unsigned char digest[digestLength];
    CC_SHA256([self UTF8String], (CC_LONG)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    
    return [self bbHashFromDigest:digest length:digestLength];
}


- (NSString *)bbSHA384Hash
{
	NSUInteger digestLength = CC_SHA384_DIGEST_LENGTH;
    unsigned char digest[digestLength];
    CC_SHA384([self UTF8String], (CC_LONG)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    
    return [self bbHashFromDigest:digest length:digestLength];
}


- (NSString *)bbSHA512Hash
{
	NSUInteger digestLength = CC_SHA512_DIGEST_LENGTH;
    unsigned char digest[digestLength];
    CC_SHA512([self UTF8String], (CC_LONG)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    
    return [self bbHashFromDigest:digest length:digestLength];
}


@end
