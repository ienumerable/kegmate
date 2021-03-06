//
//  FFStreamUtils.m
//  PBR
//
//  Created by Gabriel Handford on 11/18/10.
//  Copyright 2010 Yelp. All rights reserved.
//

#import "FFStreamUtils.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/ioctl.h>
#import <net/if.h>
#import <netdb.h>


// TODO(gabe): NSHost is private
@class NSHost;
@interface NSHost
+ (NSHost *)currentHost;
- (NSArray *)addresses;
@end



@implementation FFStreamUtils

/*
+ (NSData *)addressInfoForHost:(NSString *)host port:(int)port {
  struct addrinfo hints, *res, *res0;
  
  memset(&hints, 0, sizeof(hints));
  hints.ai_family   = PF_UNSPEC;
  hints.ai_socktype = SOCK_DGRAM;
  hints.ai_protocol = IPPROTO_UDP;
  // No passive flag on a send or connect
  
  NSString *portStr = [NSString stringWithFormat:@"%hu", port];
  
  int error = getaddrinfo([host UTF8String], [portStr UTF8String], &hints, &res0);
  NSAssert1(!error, @"Error getaddrinfo: %d", error);
  
  NSData *address = nil;
  for(res = res0; res; res = res->ai_next) {
    if (res->ai_family == AF_INET) {
      address = [NSData dataWithBytes:res->ai_addr length:res->ai_addrlen];
    }
  }
  freeaddrinfo(res0); 
  return address;
}
 */

+ (NSData *)dataForIPAddress:(NSString *)address {
  struct addrinfo hints;
  struct addrinfo *result = NULL;
  memset(&hints, 0, sizeof(hints));
  hints.ai_flags = AI_NUMERICHOST;
  hints.ai_family = PF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  hints.ai_protocol = 0;
  int errorStatus = getaddrinfo([address cStringUsingEncoding:NSASCIIStringEncoding], NULL, &hints, &result);
  if (errorStatus != 0) return nil;
  CFDataRef addressRef = CFDataCreate(NULL, (UInt8 *)result->ai_addr, result->ai_addrlen);
  if (addressRef == nil) return nil;
  freeaddrinfo(result);
  return [(NSData *)addressRef autorelease];
}

+ (NSArray *)currentAddresses {
  NSHost *currentHost = [NSHost currentHost];
  //FFDebug(@"Our addresses: %@", [currentHost addresses]);
  return [currentHost addresses];
}

+ (BOOL)containsCurrentAddress:(NSSet *)addresses {
  // TODO(gabe): NSHost is private
  NSHost *currentHost = [NSHost currentHost];
  //FFDebug(@"Our addresses: %@", [currentHost addresses]);
  for (NSString *address in [currentHost addresses]) {
    if ([addresses containsObject:address]) {
      return YES;
    }
  }
  return NO;
}

+ (NSString *)addressFromData:(NSData *)data {
  char addressBuffer[100];    
  struct sockaddr_in *socketAddress = (struct sockaddr_in *)[data bytes];    
  int sockFamily = socketAddress->sin_family;    
  if (sockFamily == AF_INET || sockFamily == AF_INET6) {      
    const char *addressStr = inet_ntop(sockFamily, &(socketAddress->sin_addr), addressBuffer, sizeof(addressBuffer));      
    //int port = ntohs(socketAddress->sin_port);      
    return [NSString stringWithUTF8String:addressStr];
  }
  return nil;
}

+ (NSSet *)addressStringsFromNetService:(NSNetService *)netService {
  NSMutableSet *addresses = [[NSMutableSet alloc] init];
  for (NSData *data in [netService addresses]) {
    NSString *address = [self addressFromData:data];
    if (address) {
      [addresses addObject:address];
    }
  }
  return addresses;
}

@end
