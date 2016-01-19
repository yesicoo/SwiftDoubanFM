//
//  DouBanFM.swift
//  QingMusic
//
//  Created by XuQing on 16/1/15.
//  Copyright © 2016年 xuqing. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol DoubanFMProtocol{
    func didPlayNextSong(type:Int,result:JSON);
    func didReceiveChannelList(channelData:JSON);
}


class DoubanFMController{
    var LoginUrl="http://www.douban.com/j/app/login";
     var ChannelListUrl="http://www.douban.com/j/app/radio/channels";
    var SongUrl="http://www.douban.com/j/app/radio/people";
    var token:String="";
    var expire:String="";
    var user_name:String="";
    var user_id:String="";
    var email:String="";
    var ChannelID:String="-3";
    var PlaySong:JSON=[];
    var LastSong:JSON=[];
    var NextSong:JSON=[];
    
    var delegate:DoubanFMProtocol!;
    func LoginDouBan(userName:String,userPwd:String){
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters = [
            "app_name": "radio_android",
            "version":"100",
            "email":userName,
            "password":userPwd
        ]
        Alamofire.request(.POST, LoginUrl, parameters: parameters,headers: headers).responseJSON { response in
            let Json=JSON(response.result.value!);
            
            self.token=Json["token"].stringValue;
            self.expire=Json["expire"].stringValue;
            self.user_name=Json["user_name"].stringValue;
            self.user_id=Json["user_id"].stringValue;
            self.email=Json["email"].stringValue;
            self.GetNextSong();
            self.GetChannelList();
        }
        
    }
    func GetNextSong(){
        let CacheCount=self.NextSong.count;
        if (CacheCount>0){
            self.delegate.didPlayNextSong(1,result: self.NextSong);
        }else{
            
            let parameters = [
                "app_name": "radio_android",
                "version":"100",
                "user_id":self.user_id,
                "expire":self.expire,
                "token":self.token,
                "channel":self.ChannelID,
                "type":"n"
            ]
            Alamofire.request(.GET, SongUrl, parameters: parameters).responseJSON { response in
                let resultJson=JSON(response.result.value!);
                self.LastSong=self.PlaySong;
                self.PlaySong=resultJson;
                self.delegate.didPlayNextSong(1,result: resultJson);
            }
        }
        
    }

    func GetLastSong(){
        let CacheCount=self.LastSong.count;
        if (CacheCount>0){
          self.delegate.didPlayNextSong(0,result: self.LastSong);
        }else{
        
        let parameters = [
            "app_name": "radio_android",
            "version":"100",
            "user_id":self.user_id,
            "expire":self.expire,
            "token":self.token,
            "channel":self.ChannelID,
            "type":"n"
        ]
        Alamofire.request(.GET, SongUrl, parameters: parameters).responseJSON { response in
            let resultJson=JSON(response.result.value!);
            self.LastSong=self.PlaySong;
            self.PlaySong=resultJson;
            self.delegate.didPlayNextSong(0,result: resultJson);
            }
        }
        
    }
    func CacheNextSong(){
        self.NextSong=[];
        let parameters = [
            "app_name": "radio_android",
            "version":"100",
            "user_id":self.user_id,
            "expire":self.expire,
            "token":self.token,
            "channel":self.ChannelID,
            "type":"n"
        ]
        Alamofire.request(.GET, SongUrl, parameters: parameters).responseJSON { response in
            let resultJson=JSON(response.result.value!);
            self.NextSong=resultJson;
        }
    }

    func SetChannelID(channelID:String){
        ChannelID=channelID;
        self.NextSong=[];
    }
    func SetLikeSong(sid:String){
        
    }
    
    
    func GetChannelList(){
        let result = Alamofire.request(.GET, ChannelListUrl);
        result.responseJSON(completionHandler: {response in
            let resultJson=JSON(response.result.value!);
            self.delegate.didReceiveChannelList(resultJson);
        })
    }
}