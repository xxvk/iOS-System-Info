//
//  Device.swift
//  iOS-Example
//
//  Created by 樊半缠 on 16/8/4.
//  Copyright © 2016年 reformation.tech. All rights reserved.
//

import UIKit
import Apple_System_Info

class Device: UITableViewController {
    @IBOutlet var Name: UILabel!

    @IBOutlet var OSVersion: UILabel!
    
    @IBOutlet var Model: UILabel!
    
    @IBOutlet var IsJailbreak: UILabel!
    
    @IBOutlet var IDFA: UILabel!
    
    @IBOutlet var IDFV: UILabel!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
        
        self.Name.text = Apple_System_Info.DeviceInfo.name
        self.OSVersion.text = Apple_System_Info.DeviceInfo.OSVersion
        self.Model.text = Apple_System_Info.DeviceInfo.model
        self.IsJailbreak.text = Apple_System_Info.DeviceInfo.isJailbreak.description
        
        self.IDFA.text = Apple_System_Info.DeviceInfo.IDFA
        self.IDFV.text = Apple_System_Info.DeviceInfo.IDFV
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            
            let menu = ActionMenu.init(actions: self.actions, point: CGPointZero, inView: cell!.contentView)
            
            menu.show(animated: true, handler: { () in
                
            })
        }
    }
    
}

extension Device: ActionableProtocol {
    
    var actions: [UIMenuItem] {
        get{
            let copyItem = UIMenuItem.init(title: "Copy",
                                           action: #selector(self.coptText))
            let replyItem = UIMenuItem.init(title: "回复",
                                            action:#selector(self.reply))
            let reportItem = UIMenuItem.init(title: "举报",
                                             action: #selector(self.warn))
            let foo = [copyItem, replyItem, reportItem]
            return foo
        }
    }
    
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        for item in self.actions {
            if action.description == item.action.description{
                return true
            }
        }
        return false
    }

    func coptText() -> Void {
        
    }
    func reply() -> Void {
        
    }
    func warn() -> Void {
        
    }
}

class HardwareContainer: UIViewController {
    private var timer: NSTimer?
    /// timer间隔时间,默认2.0秒
    var timeInterval: NSTimeInterval = 1.0 {
        didSet{
            
        }
    }
    
    @IBOutlet var cpu_Dashboard: Dashboard!
    
    @IBOutlet var ram_Dashboard: Dashboard!
    @IBOutlet var diskSpace_Label: UILabel!
    
    @IBOutlet var diskSpace_Container: UIView!
    @IBOutlet var diskSpace_Progress: NSLayoutConstraint!
    //  MARK:  life cycle:
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        cpu_Dashboard.title = "CPU"
        ram_Dashboard.title = "RAM"
        self.cpu_Dashboard.setupDefaultValue()
        self.ram_Dashboard.setupDefaultValue()
        
        
        self.diskSpace_Label.text = DeviceInfoFormatter.diskSpace_statu_Description
        self.reloadData()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue()) {
            self.diskSpace_Progress.constant = self.diskSpace_Container.bounds.width * DeviceInfoFormatter.diskSpace_free_Percent
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.startTimer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
    }
}
extension HardwareContainer{
    //  MARK:  timer:
    private func startTimer() -> Void
    {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
        timer = WeakTimer.timerWith(timeInterval, target: self){ [unowned self] _ in
            self.reloadData()
        }
    }
    private func stopTimer() -> Void
    {
        timer?.invalidate()
        timer = nil
    }
    private func reloadData() -> Void
    {
        self.cpu_Dashboard.change(DeviceInfoFormatter.cpu_usage_Value,
                                  total: 100.0,
                                  suffix: "%")
        self.ram_Dashboard.change(DeviceInfoFormatter.ram_used_Value ,
                                  total: DeviceInfoFormatter.ram_total_Value,
                                  suffix: "MB")
    }
}
//  MARK: - DeviceInfoFormatter : 把 Apple_System_Info 转换成这里需要的格式
private class DeviceInfoFormatter {
    
    private class var diskSpace_statu_Description : String{
        get{
            return "存储空间:\(Apple_System_Info.DeviceInfo.totalDiskSpace_Description())  已用:\(Apple_System_Info.DeviceInfo.usedDiskSpace_Description())  空闲:\(Apple_System_Info.DeviceInfo.freeDiskSpace_Description())"
        }
    }
    private class var diskSpace_used_Description : String{
        get{
            return "已用:\(Apple_System_Info.DeviceInfo.usedDiskSpace_Description())"
        }
    }
    private class var diskSpace_free_Description : String{
        get{
            return "空闲:\(Apple_System_Info.DeviceInfo.freeDiskSpace_Description())"
        }
    }
    private class var diskSpace_total_Description : String{
        get{
            return "存储空间:\(Apple_System_Info.DeviceInfo.totalDiskSpace_Description())"
        }
    }
    private class var diskSpace_free_Percent : CGFloat{
        get{
            return (CGFloat.init(Apple_System_Info.DeviceInfo.freeDiskSpaceInBytes)  / CGFloat.init(Apple_System_Info.DeviceInfo.totalDiskSpaceInBytes))
        }
    }
    private class var ram_used_Value : CGFloat{
        get{
            return CGFloat.init(Apple_System_Info.DeviceInfo.totalMemory() - Apple_System_Info.DeviceInfo.freeMemory())
        }
    }
    private class var ram_total_Value : CGFloat{
        get{
            return CGFloat.init(Apple_System_Info.DeviceInfo.totalMemory())
        }
    }
    //  MARK: CPU:中央处理器
    class var cpu_usage_Description : String {
        get{
            return "\(Int.init(Apple_System_Info.DeviceInfo.cpuUsage))%"
        }
    }
    //MARK: cpuUsage raw value
    private class var cpu_usage_Value:CGFloat{
        get{
            return CGFloat.init(Apple_System_Info.DeviceInfo.cpuUsage)
        }
    }
    //  MARK:  :
    private class var device_model_Value : String{
        get{
            return Apple_System_Info.DeviceInfo.model
        }
    }
    private class var device_name_Value : String{
        get{
            return Apple_System_Info.DeviceInfo.name
        }
    }
    private class var OS_version_Value : String{
        get{
            return Apple_System_Info.DeviceInfo.OSVersion
        }
    }
    private class var isJailbreak_Description : String{
        get{
            return Apple_System_Info.DeviceInfo.isJailbreak.description
        }
    }
}
