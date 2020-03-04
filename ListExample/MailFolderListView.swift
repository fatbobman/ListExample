//
//  MailFolderListView.swift
//  ListExample
//
//  Created by Yang Xu on 2020/3/3.
//  Copyright © 2020 Yang Xu. All rights reserved.
//

import SwiftUI

struct MailFolderListView: View {
    @EnvironmentObject var store:Store
    
    //编辑状态
    @State var editMode = EditMode.inactive
    @State var editing:Bool = false
    
    //sheet的开关
    @State var addMailFolder:Bool = false
    @State var addMail:Bool = false
    @State var editFolder:Bool = false
    
    //navigationlink
    @State var linkId:UUID? = nil
    @State var folderTitle:String = ""
    @State var active:Bool = false
    
    init(){
        //        取消List的横线
        //        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        NavigationView{
            ZStack(alignment:.topLeading){
                
                VStack{
                    List(selection: self.$store.folderSelection){
                        ForEach(store.fixedFolders){ folder in
                            if self.editing || (!self.editing&&folder.show) {
                                HStack{
                                    Image(systemName: folder.image)
                                        .font(.system(size: 22,weight:Font.Weight.regular))
                                        .frame(width:22)
                                        .foregroundColor(.blue)
                                        .padding(.trailing,4)
                                    Text(folder.title)
                                    Spacer()
                                    HStack{
                                        //SwiftUI在这里会再度犯病.如果再增加点条件判断,会编译超时 :(
                                        Text(folder.unReadMailNumber > 0 ? String(folder.unReadMailNumber) : "")
                                            .foregroundColor(.secondary)
                                        Image(systemName:"chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    
                                }
                                .tag(folder.id.uuidString)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if !self.editing {
                                        self.folderTitle = folder.title
                                        self.active = true
                                    }
                                }
                                
                                /*
                                 本来更喜欢这种用法,不过在这个程序会出现编译超时.
                                 .background(
                                 NavigationLink(destination: MailSubjectListView(folderName: folder.tilte), tag: folder.id, selection: self.$linkId)
                                 {
                                 EmptyView()
                                 }
                                 )
                                 */
                                
                            }
                        }
                        .onMove(perform: self.moveFolder)
                        
                        if self.editMode.isEditing{
                            HStack{
                                Rectangle().fill(Color.clear).frame(width:65)
                                Text("添加邮箱...")
                                    .foregroundColor(.blue)
                                    .onTapGesture{
                                        self.addMailFolder.toggle()
                                }
                            }
                            .sheet(isPresented: self.$addMailFolder){Text("添加邮箱")}
                        }
                        
                        ForEach(store.dynFolders){ folder in
                            HStack{
                                Image(systemName: folder.image)
                                    .font(.system(size: 22,weight:Font.Weight.regular))
                                    .frame(width:22)
                                    .foregroundColor(.blue)
                                    .padding(.trailing,4)
                                Text(folder.title)
                                Spacer()
                                Image(systemName:"chevron.right")
                                    .foregroundColor(.secondary)
                                    .opacity(self.editing ? 0 : 1)
                                    .offset(x: self.editing ? 100 : 0)
                            }
                            .contentShape(Rectangle())
                                
                            .sheet(isPresented:self.$editFolder){Text("编辑邮箱")}
                            .onTapGesture {
                                if !self.editing {
                                    self.folderTitle = folder.title
                                    self.active = true
                                }
                                else {
                                    self.editFolder.toggle()
                                }
                            }
                            
                        }
                    }
                    .listStyle(GroupedListStyle())
                        //                     设定行高
                        //                    .environment(\.defaultMinListRowHeight, 40)
                        .environment(\.editMode, self.$editMode)
                    
                    NavigationLink(destination: MailSubjectListView(folderName: self.folderTitle),isActive: self.$active){
                        EmptyView()
                    }
                    
                }
                
                //下方状态栏
                VStack{
                    Spacer()
                    ZStack{
                        Color.clear
                        ZStack(alignment:.top){
                            if self.editing {
                                HStack{
                                    Spacer()
                                    Button(action:{self.addMailFolder.toggle()})
                                    {
                                        Text("新建邮箱")
                                            .padding(.trailing,16)
                                    }
                                }
                                .padding(.bottom,20)
                                
                            }
                            else {
                                HStack{
                                    Text("刚刚更新").font(.caption)
                                }
                                .padding(.bottom,20)
                                HStack{
                                    Spacer()
                                    Button(action:{self.addMail.toggle()})
                                    {
                                        Image(systemName:"square.and.pencil")
                                            .font(.system(size: 22,weight:Font.Weight.regular))
                                            .foregroundColor(.blue)
                                            .padding(.trailing,16)
                                    }
                                }
                                .padding(.bottom,20)
                            }
                        }
                    }
                    .blurBackground(style: .systemChromeMaterial)
                    .frame(height:83)
                    .sheet(isPresented: self.$addMail){Text("添加邮件")}
                }
                
                
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle("邮箱")
            .navigationBarItems(trailing: myEditButton())
        }
    }
    
    func moveFolder(from:IndexSet,to:Int){
        self.store.fixedFolders.move(fromOffsets: from, toOffset: to)
    }
    
    func myEditButton()->some View{
        Button(self.editMode.isEditing ? "完成" : "编辑"){
            switch self.editMode {
            case .active:
                //防止GCD死锁 目前SwiftUI中比较v容易出现莫名其妙的GCD死锁意外.
                let tmpSelection = self.store.folderSelection
                _ = self.store.fixedFolders.map{
                    $0.show = tmpSelection.contains($0.id.uuidString)
                }
                
                //防止GCD死锁
                DispatchQueue.main.async {
                    self.editing = false
                }
                withAnimation(.easeInOut){
                    self.editMode = .inactive
                }
                
            case .inactive:
                DispatchQueue.main.async {
                    self.editing = true
                }
                withAnimation(.easeInOut){
                    self.editMode = .active
                }
            default:
                break
            }
        }
    }
    
    
}

//Fake Mails View
struct MailSubjectListView: View {
    var folderName:String
    var body: some View {
        Text("Mail Inbox")
            .navigationBarTitle(folderName)
    }
}





struct MailFolderListView_Previews: PreviewProvider {
    static var previews: some View {
        MailFolderListView()
            .environmentObject(Store())
    }
}
