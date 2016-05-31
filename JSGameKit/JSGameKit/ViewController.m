//
//  ViewController.m
//  JSGameKit
//
//  Created by  江苏 on 16/5/31.
//  Copyright © 2016年 jiangsu. All rights reserved.
//

#import "ViewController.h"
#import <GameKit/GameKit.h>

@interface ViewController ()<GKPeerPickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,GKSessionDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *showImageV;

@property(nonatomic,strong)GKPeerPickerController* peerPickerController;

@property(nonatomic,strong)GKSession *session;

@end

@implementation ViewController



/*连接蓝牙控制器*/
-(GKPeerPickerController *)peerPickerController
{
    if (_peerPickerController==nil) {
        _peerPickerController=[[GKPeerPickerController alloc]init];
        _peerPickerController.delegate=self;
        //设置连接模式
        _peerPickerController.connectionTypesMask=GKPeerPickerConnectionTypeNearby;
    }
    return _peerPickerController;
}


/*发送数据会话*/
-(GKSession *)session
{
    if (_session==nil) {
        _session=[[GKSession alloc]initWithSessionID:@"text" displayName:nil sessionMode:GKSessionModePeer];
        _session.delegate=self;
    }
    return _session;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)connectDevice:(UIButton *)sender {
    
    //显示匹配的的蓝牙列表
    [self.peerPickerController show];
    
}
- (IBAction)chooseImage:(id)sender {
    
    UIImagePickerController* imagePic=[[UIImagePickerController alloc]init];
    
    //如果相薄可用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        imagePic.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePic.delegate=self;
        [self presentViewController:imagePic animated:YES completion:nil];
    }
    
}

- (IBAction)postImage:(id)sender {
    
    if (!self.showImageV.image) {
        return;
    }
    
    NSData* imageData=UIImagePNGRepresentation(self.showImageV.image);
    
    /**
     *  发送数据给所有匹配上的用户
     *
     *  @param GKSendDataMode 数据发送的模式：（安全/不安全模式）
     *         GKSendDataUnreliable : 不安全模式：
     *         GKSendDataReliable：安全模式，每一个都得发送成功，才再发下一个（常用）
     */
    [self.session sendDataToAllPeers:imageData withDataMode:GKSendDataUnreliable error:nil];
}

#pragma mark--GKPeerPickerControllerDelegate

- (void)peerPickerController:(GKPeerPickerController *)picker didSelectConnectionType:(GKPeerPickerConnectionType)type {
    NSLog(@"%s %d",__func__,__LINE__);
}


- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
    return self.session;
}

/**
 *  链接成功
 *
 *  @param picker  蓝牙控制器
 *  @param peerID  连接蓝牙的设备id
 *  @param session 连接蓝牙的会话（通讯） 传输数据使用session
 */
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
    self.session=session;
    
    // 监听传递过来的数据
    /**
     *  setDataReceiveHandler: 由哪个对象来监听数据的接受
     *  withContext ： 监听需要传递的参数
     */
    [session setDataReceiveHandler:self withContext:nil];
    
    [self.peerPickerController dismiss];
    
}

/**
 *  实现接收数据的回调方法
 *
 *  @param data    接收到的数据
 *  @param peer    传递数据的设备ID
 *  @param session 当前回话
 *  @param context 注册监听传递过来的数据
 */
- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    // 因为传递过来的是图片，所以我们直接使用UIImage来接受
    UIImage *image = [UIImage imageWithData:data];
    // 设置图片
    self.showImageV.image = image;
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
    
}


#pragma mark--UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    self.showImageV.image=info[UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

@end
