//
//  ViewController.swift
//  QingMusic
//
//  Created by XuQing on 16/1/12.
//  Copyright © 2016年 xuqing. All rights reserved.
//

import UIKit
import FontAwesome_swift
import MediaPlayer
import SwiftyJSON
import AVKit


class ViewController: UIViewController,UIActionSheetDelegate,DoubanFMProtocol,ChannelProtocol,UIViewControllerTransitioningDelegate{
    
    @IBOutlet weak var BgImage: UIImageView!
    @IBOutlet weak var CenterImage: UIImageView!
    @IBOutlet weak var BtnPlay: UIButton!
    @IBOutlet weak var BtnNext: UIButton!
    @IBOutlet weak var BtnLast: UIButton!
    @IBOutlet weak var BtnRefresh: UIButton!
    @IBOutlet weak var BtnHeart: UIButton!
    @IBOutlet weak var BtnDownload: UIButton!
    @IBOutlet weak var BtnList: UIButton!
    @IBOutlet weak var BtnCyclical: UIButton!
    @IBOutlet weak var TxtTitle: UILabel!
    @IBOutlet weak var TxtArtist: UILabel!
    @IBOutlet weak var ProgressView: UIProgressView!
    @IBOutlet weak var TxtPlayTime: UILabel!
    @IBOutlet weak var TxtAllTime: UILabel!
    
    var timer:NSTimer?;
    var angle:Float=0.00;
    var PlayState:Int=0;
    var cplayTime=0.00;
    var ChannelData:JSON=[];
    var doubanController:DoubanFMController=DoubanFMController();
    var audioPlayer:MPMoviePlayerController=MPMoviePlayerController();
    let transition = FadeAnimator()
    
    @IBAction func ToChannelList(sender: AnyObject) {
        let viewController = storyboard!.instantiateViewControllerWithIdentifier("ChannelListView") as! ChannelListController
        viewController.transitioningDelegate = self
        viewController.delegate=self;
        viewController.ChannelData=self.ChannelData;
        viewController.BgImage=self.BgImage.image;
        
        presentViewController(viewController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let audioSession = AVAudioSession.sharedInstance()
        //设置录音类型
        try! audioSession.setCategory(AVAudioSessionCategoryPlayback)
        //设置支持后台
        try! audioSession.setActive(true)
        
        
        
        
        
        
        doubanController.delegate=self;
        
        // Do any additional setup after loading the view, typically from a nib.
        
        BtnPlay.titleLabel?.font = UIFont.fontAwesomeOfSize(80)
        BtnNext.titleLabel?.font = UIFont.fontAwesomeOfSize(40)
        BtnLast.titleLabel?.font = UIFont.fontAwesomeOfSize(40)
        BtnRefresh.titleLabel?.font = UIFont.fontAwesomeOfSize(25)
        BtnHeart.titleLabel?.font = UIFont.fontAwesomeOfSize(25)
        BtnDownload.titleLabel?.font = UIFont.fontAwesomeOfSize(25)
        BtnList.titleLabel?.font = UIFont.fontAwesomeOfSize(25)
        BtnCyclical.titleLabel?.font = UIFont.fontAwesomeOfSize(25)
        
        BtnPlay.setTitle(String.fontAwesomeIconWithName(.PlayCircleO), forState: .Normal)
        BtnNext.setTitle(String.fontAwesomeIconWithName(.Forward), forState: .Normal)
        BtnLast.setTitle(String.fontAwesomeIconWithName(.Backward), forState: .Normal)
        BtnRefresh.setTitle(String.fontAwesomeIconWithName(.Refresh), forState: .Normal)
        BtnHeart.setTitle(String.fontAwesomeIconWithName(.Heart), forState: .Normal)
        BtnDownload.setTitle(String.fontAwesomeIconWithName(.Download), forState: .Normal)
        BtnList.setTitle(String.fontAwesomeIconWithName(.ListOL), forState: .Normal)
        BtnCyclical.setTitle(String.fontAwesomeIconWithName(.User), forState: .Normal)
        
        
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        swipeUpGesture.direction = UISwipeGestureRecognizerDirection.Up;
        self.view.addGestureRecognizer(swipeUpGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        swipeDownGesture.direction = UISwipeGestureRecognizerDirection.Down;
        self.view.addGestureRecognizer(swipeDownGesture)
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.Left;
        self.view.addGestureRecognizer(swipeLeftGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: "handleSwipeGesture:")
        swipeRightGesture.direction = UISwipeGestureRecognizerDirection.Right;
        self.view.addGestureRecognizer(swipeRightGesture)
        
        BtnNext.addTarget(self,action:Selector("ChangToNextSong"),forControlEvents:UIControlEvents.TouchUpInside);
        BtnLast.addTarget(self,action:Selector("ChangToLastSong"),forControlEvents:UIControlEvents.TouchUpInside);
        BtnPlay.addTarget(self,action:Selector("PlayOrPause"),forControlEvents:UIControlEvents.TouchUpInside);
        
        self.CenterImage.layer.cornerRadius = self.CenterImage.frame.size.width / 2
        self.CenterImage.clipsToBounds = true;
        self.CenterImage.layer.borderWidth=10;
        self.CenterImage.layer.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.6).CGColor;
        let uiImage=UIImage(named: "Logo")!;
        self.BgImage.image=uiImage.CropToScreen(Int(self.view.frame.size.width),screenHeight: Int(self.view.frame.size.height)).GaussianBlur(0.2);
        self.CenterImage.image=uiImage.cropToSquare();
        doubanController.LoginDouBan("yesicoo@163.com", userPwd: "834173209xqxq");
        
        
        
    }
    
    
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return transition
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    override func  viewDidDisappear(animated: Bool) {
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    func configNowPlayingInfoCenter(songPic:UIImage,songTitle:String,songArtist:String){
        if (NSClassFromString("MPNowPlayingInfoCenter") != nil) {
            //锁屏界面图片的存储方式
            let mArt:MPMediaItemArtwork = MPMediaItemArtwork(image: songPic)
            //锁屏界面信息字典
            var dic:[String : AnyObject] = [
                MPMediaItemPropertyTitle : songTitle,
                MPMediaItemPropertyArtist : songArtist,
                MPMediaItemPropertyArtwork : mArt
            ]
            
            //获取当前播放的时间和歌曲总时长
            //            let time = self.audioPlayer.currentPlaybackTime
            //            let duration = self.musicPlayer.currentItem!.asset.duration
            //
            //            //把信息传递给锁屏界面
            //            dic.updateValue(NSNumber(double: CMTimeGetSeconds(time)), forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime )
            //            dic.updateValue(NSNumber(double: CMTimeGetSeconds(duration)), forKey: MPMediaItemPropertyPlaybackDuration)
            dic.updateValue(NSNumber(float: 1.0), forKey: MPNowPlayingInfoPropertyPlaybackRate)
            
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = dic
        }
    }
    
    
    func onUpdate(){
        angle+=0.002;
        if (angle > 6.28) {//大于 M_PI*2(360度) 角度再次从0开始
            angle = 0;
        }
        self.CenterImage.layer.transform = CATransform3DMakeRotation(CGFloat(angle),0,0,1);
        cplayTime=self.audioPlayer.currentPlaybackTime;
        
        if cplayTime>0{
            let t=audioPlayer.duration;
            let p:CFloat=CFloat(cplayTime/t);
            ProgressView.setProgress(p, animated: true)
            var showTime:String="";
            let allTime=Int(cplayTime);
            let m=allTime%60;
            let f=Int(allTime/60);
            if f<10{
                showTime="0\(f)";
            }else{
                showTime="\(f)";
            }
            if m<10{
                showTime+=":0\(m)";
            }else{
                showTime+=":\(m)";
            }
            TxtPlayTime.text=showTime;
            if(p == 1){
                timer?.invalidate();
                doubanController.GetNextSong();
            }
        }
        if(TxtAllTime.text=="00:00"){
            var showTime:String="";
            let allTime=Int(audioPlayer.duration);
            let m=allTime%60;
            let f=Int(allTime/60);
            if f<10{
                showTime="0\(f)";
            }else{
                showTime="\(f)";
            }
            if m<10{
                showTime+=":0\(m)";
            }else{
                showTime+=":\(m)";
            }
            TxtAllTime.text=showTime;
        }
        
        
    }
    func handleSwipeGesture(sender: UISwipeGestureRecognizer){
        let direction = sender.direction
        //判断是上下左右
        switch (direction){
        case UISwipeGestureRecognizerDirection.Left:
            print("Left")
            break
        case UISwipeGestureRecognizerDirection.Right:
            print("Right")
            break
        case UISwipeGestureRecognizerDirection.Up:
            doubanController.GetLastSong();
            break
        case UISwipeGestureRecognizerDirection.Down:
            doubanController.GetNextSong();
            break
        default:
            break;
        }
    }
    
    func ChangToLastSong(){
        doubanController.GetLastSong();
        
    }
    func ChangToNextSong(){
        doubanController.GetNextSong();
    }
    func PlayOrPause(){
        if PlayState==1{
            timer?.invalidate();
            BtnPlay.setTitle(String.fontAwesomeIconWithName(.PauseCircleO), forState: .Normal)
            self.audioPlayer.pause();
            PlayState=0;
        }else{
            BtnPlay.setTitle(String.fontAwesomeIconWithName(.PlayCircleO), forState: .Normal)
            self.audioPlayer.play();
            PlayState=1;
            self.timer=NSTimer.scheduledTimerWithTimeInterval(0.03, target:self,selector: "onUpdate",userInfo: nil, repeats: true);
        }
    }
    
    func PlayMusic(audioUrl:String){
        BtnPlay.setTitle(String.fontAwesomeIconWithName(.PlayCircleO), forState: .Normal)
        TxtAllTime.text="00:00"
        TxtPlayTime.text="00:00";
        ProgressView.setProgress(0.00, animated: true)
        
        //后台播放
        var bgTask:UIBackgroundTaskIdentifier = 0
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Background {
            self.audioPlayer.stop();
            self.audioPlayer.contentURL=NSURL(string:audioUrl);
            self.audioPlayer.play();
            
            let app:UIApplication = UIApplication.sharedApplication()
            let newTask:UIBackgroundTaskIdentifier = app.beginBackgroundTaskWithExpirationHandler(nil)
            if newTask != UIBackgroundTaskInvalid {
                app.endBackgroundTask(bgTask)
            }
            bgTask = newTask
        }else{
            self.audioPlayer.stop();
            self.audioPlayer.contentURL=NSURL(string:audioUrl);
            self.audioPlayer.play();
        }
        
        
        
        PlayState=1;
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func didPlayNextSong(type:Int, result results:JSON){
        if(results != nil){
            let title=results["song"][0]["title"].stringValue;
            let albumtitle=results["song"][0]["albumtitle"].stringValue;
            let artist=results["song"][0]["artist"].stringValue;
            let picture=results["song"][0]["picture"].stringValue;
            
            let image = UIImage(data:NSData(contentsOfURL:NSURL(string:picture)!)!, scale: 1.0)
            ImageAnimate(type,uiImage: image!);
            
            TxtTitle.text=title;
            TxtArtist.text="\(albumtitle) - \(artist)";
            let audioUrl=results["song"][0]["url"].stringValue;
            let like=results["song"][0]["like"].stringValue;
            if(like=="0"){
                BtnHeart.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.7), forState: .Normal);
            }else{
                BtnHeart.setTitleColor(UIColor.redColor().colorWithAlphaComponent(0.7), forState: .Normal);
            }
            PlayMusic(audioUrl);
            self.configNowPlayingInfoCenter(image!,songTitle: title,songArtist: TxtArtist.text!);
        }
    }
    func  didReceiveChannelList(channelData:JSON){
        self.ChannelData=channelData;
    }
    
    
    func ImageAnimate(type:Int,uiImage:UIImage){
        timer?.invalidate();
        let originalCenter = self.CenterImage.center
        var ChangeNum:CGFloat=0.00;
        if type==1{
            ChangeNum = 80.0;
        }else{
            ChangeNum = -80.0;
        }
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0, options: .TransitionNone, animations: { () -> Void in
            self.BgImage.alpha = 0.3;
            
            }) { (Bool) -> Void in
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0, options: .TransitionNone, animations: { () -> Void in
                    self.BgImage.image=uiImage.CropToScreen(Int(self.view.frame.size.width),screenHeight: Int(self.view.frame.size.height)).GaussianBlur(0.2);
                    self.CenterImage.image=uiImage.cropToSquare();
                    self.BgImage.alpha = 1;
                    }) { (Bool) -> Void in
                        self.timer=NSTimer.scheduledTimerWithTimeInterval(0.03, target:self,selector: "onUpdate",userInfo: nil, repeats: true);
                }
        }
        
        UIView.animateKeyframesWithDuration(1.2, delay: 0.0, options: .OverrideInheritedOptions, animations: {
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: {
                self.CenterImage.center.y += ChangeNum;
                self.CenterImage.alpha = 0.0;
                
            })
            UIView.addKeyframeWithRelativeStartTime(0.51, relativeDuration: 0.01) {
                self.CenterImage.center.y -= ChangeNum*2;
                
            }
            UIView.addKeyframeWithRelativeStartTime(0.55, relativeDuration: 0.45) {
                self.CenterImage.alpha = 1.0;
                self.CenterImage.center = originalCenter;
                
            }
            UIView.addKeyframeWithRelativeStartTime(0.1, relativeDuration: 0.5) {
                self.CenterImage.transform = CGAffineTransformMakeRotation(CGFloat(0));
                
                
            }
            }, completion:{(Bool) -> Void in
                
                self.doubanController.CacheNextSong();
            }
        )
        angle = 0;
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event!.type == UIEventType.RemoteControl {
            if event!.subtype == UIEventSubtype.RemoteControlNextTrack {
                doubanController.GetNextSong();
                
            }else if event!.subtype == UIEventSubtype.RemoteControlPause || event!.subtype == UIEventSubtype.RemoteControlPlay{
                PlayOrPause()
                
            }else if event!.subtype == UIEventSubtype.RemoteControlPreviousTrack{
                doubanController.GetLastSong();
            }
        }
        
    }
    
    func ChangeChannel(channelID:String){
        doubanController.SetChannelID(channelID);
        doubanController.GetNextSong();
        
    }
    
}

