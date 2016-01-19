//
//  ChannelListController.swift
//  QingMusic
//
//  Created by XuQing on 16/1/17.
//  Copyright © 2016年 xuqing. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ChannelProtocol{
    func ChangeChannel(channelID:String);
}

class ChannelListController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    @IBOutlet weak var TableView: UITableView!
    
    var ChannelData:JSON=[];
    @IBOutlet weak var BgImageView: UIImageView!
    var BgImage:UIImage?;
    
     var delegate:ChannelProtocol!;
    override func viewDidLoad() {
        self.BgImageView.image=BgImage;
        TableView.backgroundColor=UIColor.clearColor();
    }
    override func viewDidAppear(animated: Bool) {
  
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let index=indexPath.row;
        var channelID="-3";
        if(index != 0){
            channelID=ChannelData["channels"][index-1]["channel_id"].stringValue;
        }
        self.delegate.ChangeChannel(channelID);
        self.dismissViewControllerAnimated(true, completion: nil);
        
    }
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ChannelData["channels"].count+1;
    }
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell=UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "douban")
        if(indexPath.row == 0){
            cell.textLabel?.text="红心兆赫";
        }else{
        
        cell.textLabel?.text =  ChannelData["channels"][indexPath.row-1]["name"].stringValue;
        }
        cell.backgroundColor=UIColor.clearColor();
        cell.textLabel?.textColor=UIColor.whiteColor();
        cell.textLabel?.shadowColor=UIColor(red: 254, green: 223, blue: 248, alpha: 0.9);
        return cell;
    }
    
    
}
