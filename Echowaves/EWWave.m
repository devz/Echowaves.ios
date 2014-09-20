//
//  EWWave.m
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "EWWave.h"

@implementation EWWave

+ (NSURLProtectionSpace*) echowavesProtectionSpace {
    NSURL *url = [NSURL URLWithString:EWHost];
    NSURLProtectionSpace *protSpace = [[NSURLProtectionSpace alloc] initWithHost:url.host
                                                                            port:[url.port integerValue]
                                                                        protocol:url.scheme
                                                                           realm:nil
                                                            authenticationMethod:nil];
    return protSpace;
}


+ (void) storeCredentialForWaveName:(NSString *)waveName withPassword:(NSString *)wavePassword {
//    NSLog(@"storing credentials %@ : %@", waveName, wavePassword);
    NSDictionary *credentials;
    credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:EWWave.echowavesProtectionSpace];
    
    NSURLCredential *credential;
//    NSLog(@"there are %d credentials", credentials.count);
    //remove all credentials
    for(NSString* credentialKey in credentials) {
        credential = [credentials objectForKey:credentialKey];
        [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:credential forProtectionSpace:EWWave.echowavesProtectionSpace];
    }
    //store new credential
    credential = [NSURLCredential credentialWithUser:waveName password:wavePassword persistence:NSURLCredentialPersistencePermanent];
    [[NSURLCredentialStorage sharedCredentialStorage] setCredential:credential forProtectionSpace:EWWave.echowavesProtectionSpace];
    
    
//    APP_DELEGATE.currentWaveName = waveName;

}

+(NSURLCredential*) getStoredCredential {
    //check if credentials are already stored, then show it in the tune in fields
    NSURLCredential *credential;
    NSDictionary *credentials;
    
    credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:EWWave.echowavesProtectionSpace];
    credential = [credentials.objectEnumerator nextObject];
    return credential;
}



+(void) createWaveWithName:(NSString *)waveName
                  password:(NSString*)wavePassword
           confirmPassword:(NSString*)confirmPassword
                   success:(void (^)(NSString *waveName))success
                   failure:(void (^)(NSString *errorMessage))failure
{
    //wipe out cookies first
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* cookies = [ cookieStorage cookiesForURL:[NSURL URLWithString:EWHost]];
    for (NSHTTPCookie* cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
    
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    NSDictionary *parameters = @{@"name": waveName,
                                 @"pass": wavePassword,
                                 @"pass1": confirmPassword};
    
    [manager POST:[NSString stringWithFormat:@"%@/register.json", EWHost] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"+++wave created");
        NSLog(@"wave name %@ ", waveName);
        
        [EWWave storeCredentialForWaveName:waveName withPassword:wavePassword];
        success(waveName);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"Response: %@", [operation.responseObject objectForKey:@"error"]);
        failure([NSString stringWithFormat:@"Unable to createWave: %@", [operation.responseObject objectForKey:@"error"]]);
        
    }];
   
}

+(void) createChildWaveWithName:(NSString *)waveName
                        success:(void (^)(NSString *waveName))success
                        failure:(void (^)(NSString *errorMessage))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
    
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"name": waveName};
    
    [manager POST:[NSString stringWithFormat:@"%@/create-child-wave.json", EWHost]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              success(waveName);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              NSLog(@"Response: %@", [operation.responseObject objectForKey:@"error"]);
              failure([NSString stringWithFormat:@"Unable to createChildWave: %@", [operation.responseObject objectForKey:@"error"]]);
          }];    
}


+(void) makeWaveActive:(NSString *)waveName
                active:(BOOL)active
               success:(void (^)(NSString *waveName))success
               failure:(void (^)(NSString *errorMessage))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
    
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"wave_name": waveName,
                                 @"active": active?@YES:@NO};
    
    [manager POST:[NSString stringWithFormat:@"%@/make-wave-active.json", EWHost]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              success(waveName);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              NSLog(@"Response: %@", [operation.responseObject objectForKey:@"error"]);
              failure([NSString stringWithFormat:@"Unable to make wave active/inactive: %@", [operation.responseObject objectForKey:@"error"]]);
          }];
}

+(void) deleteChildWave:(NSString *)waveName
                success:(void (^)(NSString *waveName))success
                failure:(void (^)(NSString *errorMessage))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
    
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"wave_name": waveName,};
    
    [manager POST:[NSString stringWithFormat:@"%@/delete-child-wave.json", EWHost]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              success(waveName);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              NSLog(@"Response: %@", [operation.responseObject objectForKey:@"error"]);
              failure([NSString stringWithFormat:@"Unable to delete wave: %@", [operation.responseObject objectForKey:@"error"]]);
          }];
}


+(void) getWaveDetails:(NSString *)waveName
               success:(void (^)(NSDictionary *waveDetails))success
               failure:(void (^)(NSString *errorMessage))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // perform authentication, wave/password non blank and exist in the server side, and enter a sending loop
    
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"wave_name": waveName};
    
    [manager GET:[NSString stringWithFormat:@"%@/wave-details.json", EWHost]
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              success((NSDictionary*)responseObject);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              NSLog(@"Response: %@", [operation.responseObject objectForKey:@"error"]);
              failure([NSString stringWithFormat:@"Unable to get wave details: %@", [operation.responseObject objectForKey:@"error"]]);
          }];
    
}


+ (void) getAllMyWaves:(void (^)(NSArray *waves))success
               failure:(void (^)(NSError *error))failure {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    
    [manager GET:[NSString stringWithFormat:@"%@/all-my-waves.json", EWHost]
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success((NSArray*)responseObject);
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             failure(error);
         }];
}


+(void) storeIosTokenForWave:(NSString *)waveName
                       token:(NSString*)token
                     success:(void (^)(NSString *waveName))success
                     failure:(void (^)(NSString *errorMessage))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"name": waveName,
                                 @"token": token};
    
    [manager POST:[NSString stringWithFormat:@"%@/register-ios-token.json", EWHost] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"+++token stored");
        NSLog(@"wave name %@ token %@", waveName, token);
        
        success(waveName);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"Response: %@", [operation.responseObject objectForKey:@"error"]);
        failure([NSString stringWithFormat:@"Unable to createWave: %@", [operation.responseObject objectForKey:@"error"]]);
    }];
}

+(void) sendPushNotifyForWave:(NSString *)waveName
                        badge:(NSInteger) numberOfImages
                      success:(void (^)())success
                      failure:(void (^)(NSError *error))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"badge": [NSString stringWithFormat: @"%ld", (long)numberOfImages],
                                 @"wave_name": waveName};
    
    [manager POST:[NSString stringWithFormat:@"%@/send-push-notify.json", EWHost] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"+++notification pushed");
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        NSLog(@"Response: %@", [operation.responseObject objectForKey:@"error"]);
        failure(error);
    }];
    
}


+(void) tuneInWithName:(NSString *)waveName
           andPassword:(NSString*)wavePassword
               success:(void (^)(NSString *waveName))success
               failure:(void (^)(NSString *errorMessage))failure
{
    //wipe out cookies first
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* cookies = [ cookieStorage cookiesForURL:[NSURL URLWithString:EWHost]];
    for (NSHTTPCookie* cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSDictionary *parameters = @{@"name": waveName,
                                 @"pass": wavePassword};
    
    [manager POST:[NSString stringWithFormat:@"%@/login.json", EWHost] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"response: %@", responseObject);
        NSLog(@"user name/password found");
        NSLog(@"wave name %@ ", waveName);
        
        [EWWave storeCredentialForWaveName:waveName withPassword:wavePassword];
        
        success(waveName);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
		id err =[operation.responseObject objectForKey:@"error"];
		if(!err) {
			err = [error localizedDescription];
		}
        failure([NSString stringWithFormat:@"Unable to tuneIn: %@", err]);
    }];

}

+(void) tuneOut {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //ideally not going to need the following line, if making a request to json service
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    APP_DELEGATE.currentWaveName = nil;
    [manager POST:[NSString stringWithFormat:@"%@/logout.json", EWHost] parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"+++TunedOut");
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"+++Error tuninOut");
          }];
    

}


@end
