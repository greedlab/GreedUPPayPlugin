//
//  AppDelegate.m
//  UPPayDemo
//
//  Created by zhangyi on 15/11/19.
//  Copyright © 2015年 UnionPay. All rights reserved.
//

#import "AppDelegate.h"
#import "UPPaymentControl.h"
#import "ViewController.h"
#import "RSA.h"
#import <CommonCrypto/CommonDigest.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
    // Override point for customization after application launch.
    
    ViewController* root = [[ViewController alloc] init];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:root];
 
    
    self.viewController = nav;

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSString *) readPublicKey:(NSString *) keyName
{
    if (keyName == nil || [keyName isEqualToString:@""]) return nil;
    
    NSMutableArray *filenameChunks = [[keyName componentsSeparatedByString:@"."] mutableCopy];
    NSString *extension = filenameChunks[[filenameChunks count] - 1];
    [filenameChunks removeLastObject]; // remove the extension
    NSString *filename = [filenameChunks componentsJoinedByString:@"."]; // reconstruct the filename with no extension
    
    NSString *keyPath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    
    NSString *keyStr = [NSString stringWithContentsOfFile:keyPath encoding:NSUTF8StringEncoding error:nil];
    
    return keyStr;
}

-(BOOL) verify:(NSString *) resultStr {
    
    //从NSString转化为NSDictionary
    NSData *resultData = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:resultData options:0 error:nil];

    //获取生成签名的数据
    NSString *sign = data[@"sign"];
    NSString *signElements = data[@"data"];
    //NSString *pay_result = signElements[@"pay_result"];
    //NSString *tn = signElements[@"tn"];
    //转换服务器签名数据
    NSData *nsdataFromBase64String = [[NSData alloc]
                                      initWithBase64EncodedString:sign options:0];
    //生成本地签名数据，并生成摘要
//    NSString *mySignBlock = [NSString stringWithFormat:@"pay_result=%@tn=%@",pay_result,tn];
    NSData *dataOriginal = [[self sha1:signElements] dataUsingEncoding:NSUTF8StringEncoding];
    //验证签名
    //TODO：此处如果是正式环境需要换成public_product.key
    NSString *pubkey =[self readPublicKey:@"public_test.key"];
    OSStatus result=[RSA verifyData:dataOriginal sig:nsdataFromBase64String publicKey:pubkey];
    
    
    
    //签名验证成功，商户app做后续处理
    if(result == 0) {
        //支付成功且验签成功，展示支付成功提示
        return YES;
    }
    else {
        //验签失败，交易结果数据被篡改，商户app后台查询交易结果
        return NO;
    }
    
    return NO;
}


- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    

    [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
        
        //结果code为成功时，先校验签名，校验成功后做后续处理
        if([code isEqualToString:@"success"]) {
            
            //判断签名数据是否存在
            if(data == nil){
                //如果没有签名数据，建议商户app后台查询交易结果
                return;
            }
            
            //数据从NSDictionary转换为NSString
            NSData *signData = [NSJSONSerialization dataWithJSONObject:data
                                                               options:0
                                                                 error:nil];
            NSString *sign = [[NSString alloc] initWithData:signData encoding:NSUTF8StringEncoding];
            

            
            //验签证书同后台验签证书
            //此处的verify，商户需送去商户后台做验签
            if([self verify:sign]) {
                //支付成功且验签成功，展示支付成功提示
            }
            else {
                //验签失败，交易结果数据被篡改，商户app后台查询交易结果
            }
        }
        else if([code isEqualToString:@"fail"]) {
            //交易失败
        }
        else if([code isEqualToString:@"cancel"]) {
            //交易取消
        }
    }];
    
    return YES;
}

- (NSString*)sha1:(NSString *)string
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_CTX context;
    NSString *description;
    
    CC_SHA1_Init(&context);
    
    memset(digest, 0, sizeof(digest));
    
    description = @"";
    
    
    if (string == nil)
    {
        return nil;
    }
    
    // Convert the given 'NSString *' to 'const char *'.
    const char *str = [string cStringUsingEncoding:NSUTF8StringEncoding];
    
    // Check if the conversion has succeeded.
    if (str == NULL)
    {
        return nil;
    }
    
    // Get the length of the C-string.
    int len = (int)strlen(str);
    
    if (len == 0)
    {
        return nil;
    }
    
    
    if (str == NULL)
    {
        return nil;
    }
    
    CC_SHA1_Update(&context, str, len);
    
    CC_SHA1_Final(digest, &context);
    
    description = [NSString stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[ 0], digest[ 1], digest[ 2], digest[ 3],
                   digest[ 4], digest[ 5], digest[ 6], digest[ 7],
                   digest[ 8], digest[ 9], digest[10], digest[11],
                   digest[12], digest[13], digest[14], digest[15],
                   digest[16], digest[17], digest[18], digest[19]];
    
    return description;
}

@end
