//
//  Model.swift
//  SwiftUIListExample-1
//
//  Created by Yang Xu on 2020/3/3.
//  Copyright © 2020 Yang Xu. All rights reserved.
//

import Foundation
import SwiftUI

class FixedFolder:Identifiable,Hashable{
    var id:UUID
    var title:String
    var image:String
    var unReadMailNumber:Int
    var show:Bool
    var hidden:Bool = false
    
    init(title:String,image:String,show:Bool,hidden:Bool = false){
        self.id = UUID()
        self.title = title
        self.image = image
        self.unReadMailNumber = Int.random(in: 0...5)
        self.show = show
        self.hidden = hidden
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
    static func == (lhs: FixedFolder, rhs: FixedFolder) -> Bool {
        return lhs.id == rhs.id
    }
}

class DynFolder:Identifiable,Hashable{
    var id:UUID
    var title:String
    var image:String
    var unReadMailNumber:Int
    init(title:String,image:String){
        self.id = UUID()
        self.title = title
        self.image = image
        self.unReadMailNumber = Int.random(in: 0...5)
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
    static func == (lhs: DynFolder, rhs: DynFolder) -> Bool {
        return lhs.id == rhs.id
    }
}

class Store:ObservableObject{
    var fixedFolders:[FixedFolder] = []
    var dynFolders:[DynFolder] = []
    var folderSelection:Set<String> = []
    var mailSelection:Set<UUID> = []
    var editMode = EditMode.inactive
    
    init(){
        loadFixedFolders()
        loadDynFolders()
        //初始化邮箱显示选择数据
        folderSelection = Set(self.fixedFolders.filter{
            $0.show
        }.map{
            $0.id.uuidString
        })
    }
    
    func loadFixedFolders(){
        let folders = [
             FixedFolder(title: "收件箱", image: "tray", show: true),
             FixedFolder(title: "VIP", image: "star", show: true),
             FixedFolder(title: "有旗标", image: "flag", show: true),
             FixedFolder(title: "未读", image: "envelope.badge", show: true),
             FixedFolder(title: "收件人抄送", image: "person", show: false),
             FixedFolder(title: "附件", image: "paperclip", show: true),
             FixedFolder(title: "邮件主题通知", image: "bell", show: false),
             FixedFolder(title: "今天", image: "calendar", show: true)
        ]
        self.fixedFolders = folders
    }
    
    func loadDynFolders(){
        let folders = [
        DynFolder(title: "草稿箱", image: "doc"),
        DynFolder(title: "已发送", image: "paperplane"),
        DynFolder(title: "垃圾邮件", image: "bin.xmark"),
        DynFolder(title: "废纸篓", image: "trash"),
        DynFolder(title: "归档", image: "archivebox"),
        DynFolder(title: "测试", image: "folder"),
        DynFolder(title: "邮件列表", image: "folder")
        ]
        self.dynFolders = folders
    }
}
