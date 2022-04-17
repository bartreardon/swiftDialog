//
//  TrackProgress.swift
//  file watch test
//
//  Created by Bart Reardon on 13/1/2022.
//
// concept and execution apropriated from depNotify

import Foundation
import SwiftUI

enum StatusState {
    case start
    case done
}

class DialogUpdatableContent : ObservableObject {
    
    // set up some defaults
    
    var path: String
    @Published var titleText: String
    @Published var messageText: String
    @Published var statusText: String
    @Published var progressValue: Double
    @Published var progressTotal: Double
    @Published var button1Value: String
    @Published var button1Disabled: Bool
    @Published var button2Value: String
    @Published var infoButtonValue: String
    @Published var iconImage: String
    @Published var iconSize: CGFloat
    @Published var iconPresent: Bool
    @Published var centreIconPresent: Bool
    //@Published var image: String
    @Published var imagePresent: Bool
    @Published var imageCaptionPresent: Bool
    
    @Published var listItemsArray : [ListItems]
    @Published var listItemUpdateRow: Int
    @Published var listItemPresent: Bool
    
    @Published var requiredTextfieldHighlight: [Color] = Array(repeating: Color.clear, count: textFields.count)
    
    @Published var windowWidth: CGFloat
    @Published var windowHeight: CGFloat
    
    var status: StatusState
    
    let task = Process()
    let fm = FileManager()
    var fwDownloadsStarted = false
    var filesets = Set<String>()
    
    // init
    
    init() {
        
        if dialogargs.statusLogFile.present {
            path = dialogargs.statusLogFile.value
        } else {
            path = "/var/tmp/dialog.log"
        }
        
        // initialise all our observed variables
        // for the most part we pull from whatever was passed in save for some tracking variables
        
        button1Disabled = dialogargs.button1Disabled.present
        if dialogargs.timerBar.present && !dialogargs.hideTimerBar.present {
            //self._button1disabled = State(initialValue: true)
            button1Disabled = true
        }
                
        titleText = dialogargs.titleOption.value
        messageText = dialogargs.messageOption.value
        statusText = dialogargs.progressText.value
        progressValue = 0
        progressTotal = 0
        button1Value = dialogargs.button1TextOption.value
        button2Value = dialogargs.button2TextOption.value
        infoButtonValue = dialogargs.infoButtonOption.value
        listItemUpdateRow = 0
        
        //requiredTextfieldHighlight = Color.clear
        
        iconImage = dialogargs.iconOption.value
        iconSize = string2float(string: dialogargs.iconSize.value)
        iconPresent = !appvars.iconIsHidden
        centreIconPresent = dialogargs.centreIcon.present
        
        //image = dialogargs.mainImage.value
        appvars.imageArray = CLOptionMultiOptions(optionName: dialogargs.mainImage.long)
        appvars.imageCaptionArray = CLOptionMultiOptions(optionName: dialogargs.mainImageCaption.long)
        imagePresent = dialogargs.mainImage.present
        imageCaptionPresent = dialogargs.mainImageCaption.present
        
        listItemsArray = appvars.listItems
        listItemPresent = dialogargs.listItem.present
        
        windowWidth = appvars.windowWidth
        windowHeight = appvars.windowHeight

        // start the background process to monotor the command file
        status = .start
        task.launchPath = "/usr/bin/tail"
        task.arguments = ["-f", path]
        
        // delete if it already exists
        self.killCommandFile()
        self.run()
        
    }
    
    // watch for updates and post them
    
    func run() {
        
        // check to make sure the file exists
        
        if !fm.fileExists(atPath: path) {
            // need to make the file
            fm.createFile(atPath: path, contents: nil, attributes: nil)
        }
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        let outputHandle = pipe.fileHandleForReading
        outputHandle.waitForDataInBackgroundAndNotify()
        
        var dataAvailable : NSObjectProtocol!
        dataAvailable = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
        object: outputHandle, queue: nil) {  notification -> Void in
            let data = pipe.fileHandleForReading.availableData
            if data.count > 0 {
                if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    //print("Task sent some data: \(str)")
                    self.processCommands(commands: str as String)
                }
                outputHandle.waitForDataInBackgroundAndNotify()
            } else {
                NotificationCenter.default.removeObserver(dataAvailable as Any)
            }
        }
        
        var dataReady : NSObjectProtocol!
        dataReady = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification,
        object: pipe.fileHandleForReading, queue: nil) { notification -> Void in
            NSLog("Task terminated!")
            NotificationCenter.default.removeObserver(dataReady as Any)
        }
        
        task.launch()
    }
    
    func end() {
        task.terminate()
    }
    
    func processCommands(commands: String) {
        
        let allCommands = commands.components(separatedBy: "\n")
        
        for line in allCommands {
            
            let command = line.components(separatedBy: " ").first!.lowercased()
                        
            switch command {
            /*
            case "width:" :
                windowWidth = NumberFormatter().number(from: line.replacingOccurrences(of: "width: ", with: "")) as! CGFloat
                appvars.windowWidth = NumberFormatter().number(from: line.replacingOccurrences(of: "width: ", with: "")) as! CGFloat
                
            case "height:" :
                windowHeight = NumberFormatter().number(from: line.replacingOccurrences(of: "height: ", with: "")) as! CGFloat
                appvars.windowHeight = NumberFormatter().number(from: line.replacingOccurrences(of: "height: ", with: "")) as! CGFloat
            */
            // Title
            case "\(dialogargs.titleOption.long):" :
                titleText = line.replacingOccurrences(of: "\(dialogargs.titleOption.long): ", with: "")
            
            // Message
            case "\(dialogargs.messageOption.long):" :
                messageText = line.replacingOccurrences(of: "\(dialogargs.messageOption.long): ", with: "").replacingOccurrences(of: "\\n", with: "\n")
                imagePresent = false
                imageCaptionPresent = false
                //listItemPresent = false
                
            //Progress Bar
            case "\(dialogargs.progressBar.long):" :
                let incrementValue = line.replacingOccurrences(of: "\(dialogargs.progressBar.long): ", with: "")
                switch incrementValue {
                case "increment" :
                    if progressTotal == 0 {
                        progressTotal = Double(dialogargs.progressBar.value) ?? 100
                    }
                    progressValue = progressValue + 1
                case "reset" :
                    progressValue = 0
                case "complete" :
                    progressValue = Double(dialogargs.progressBar.value) ?? 1000
                //case "indeterminate" :
                //    progressTotal = 0
                //    progressValue = 0
                //case "determinate" :
                //    progressValue = 0
                default :
                    if progressTotal == 0 {
                        progressTotal = Double(dialogargs.progressBar.value) ?? 100
                    }
                    progressValue = Double(incrementValue) ?? 0
                }
                
            //Progress Bar Label
            case "\(dialogargs.progressBar.long)text:" :
                statusText = line.replacingOccurrences(of: "\(dialogargs.progressBar.long)text: ", with: "")
                
            //Progress Bar Label (typo version with capital T)
            case "\(dialogargs.progressBar.long)Text:" :
                statusText = line.replacingOccurrences(of: "\(dialogargs.progressBar.long)Text: ", with: "")
            
            // Button 1 label
            case "\(dialogargs.button1TextOption.long):" :
                button1Value = line.replacingOccurrences(of: "\(dialogargs.button1TextOption.long): ", with: "")
                
            // Button 1 status
            case "button1:" :
                let buttonCMD = line.replacingOccurrences(of: "button1: ", with: "")
                switch buttonCMD {
                case "disable" :
                    button1Disabled = true
                case "enable" :
                    button1Disabled = false
                default :
                    button1Disabled = button1Disabled
                }

            // Button 2 label
            case "\(dialogargs.button2TextOption.long):" :
                button2Value = line.replacingOccurrences(of: "\(dialogargs.button2TextOption.long): ", with: "")
            
            // Info Button label
            case "\(dialogargs.infoButtonOption.long):" :
                infoButtonValue = line.replacingOccurrences(of: "\(dialogargs.infoButtonOption.long): ", with: "")
                
            // icon image
            case "\(dialogargs.iconOption.long):" :
                //iconPresent = true
                let iconState = line.replacingOccurrences(of: "\(dialogargs.iconOption.long): ", with: "")
                
                if iconState.components(separatedBy: ": ").first == "size" {
                    //print(iconState)
                    //if let readIconSize = iconState.replacingOccurrences(of: "size: ", with: "") {
                    if iconState.replacingOccurrences(of: "size:", with: "").trimmingCharacters(in: .whitespaces) != "" {
                        iconSize = string2float(string: iconState.replacingOccurrences(of: "size: ", with: ""))
                    } else {
                        iconSize = appvars.iconWidth
                    }
                } else {
                    switch iconState {
                    case "centre", "center" :
                        centreIconPresent = true
                    case "left", "default" :
                        centreIconPresent = false
                    case "none" :
                        iconPresent = false
                        iconImage = iconState
                    default:
                        //centreIconPresent = false
                        iconPresent = true
                        iconImage = iconState
                    }
                }
                //print("centre icon is \(centreIconPresent)")
                //iconImage = line.replacingOccurrences(of: "\(dialogargs.iconOption.long): ", with: "")
                
            // image
            case "\(dialogargs.mainImage.long):" :
                appvars.imageArray = [line.replacingOccurrences(of: "\(dialogargs.mainImage.long): ", with: "")]
                imagePresent = true
                
            // image Caption
            case "\(dialogargs.mainImageCaption.long):" :
                appvars.imageCaptionArray = [line.replacingOccurrences(of: "\(dialogargs.mainImageCaption.long): ", with: "")]
                imageCaptionPresent = true
                
            // list items
            case "list:" :
                if line.replacingOccurrences(of: "list: ", with: "") == "clear" {
                    // clean everything out and remove the listview from display
                    listItemPresent = false
                    listItemsArray = [ListItems]()
                    
                } else {
                    var listItems = line.replacingOccurrences(of: "list: ", with: "").components(separatedBy: ",")
                    listItems = listItems.map { $0.trimmingCharacters(in: .whitespaces) } // trim out any whitespace from the values if there were spaces before after the comma

                    listItemsArray = [ListItems]()
                    for itemTitle in listItems {
                        listItemsArray.append(ListItems(title: itemTitle))
                    }
                    listItemPresent = true
                }
                
            // list item status
            case "\(dialogargs.listItem.long):" :
                var title           : String = ""
                var icon            : String = ""
                var statusText      : String = ""
                var statusIcon      : String = ""
                let statusTypeArray = ["wait","success","fail","error","pending"]

                let listCommand = line.replacingOccurrences(of: "\(dialogargs.listItem.long): ", with: "")
                
                // Check for the origional way of doign things
                let listItemStateArray = listCommand.components(separatedBy: ": ")
                if listItemStateArray.count > 0 {
                    title = listItemStateArray.first!
                    statusIcon = listItemStateArray.last!
                    // if using the new method, these will not be set as the title value won't match the ItemValue
                    if let row = listItemsArray.firstIndex(where: {$0.title == title}) {
                        if statusTypeArray.contains(statusIcon) {
                            listItemsArray[row].statusIcon = statusIcon
                            listItemsArray[row].statusText = ""
                        } else {
                            listItemsArray[row].statusIcon = ""
                            listItemsArray[row].statusText = statusIcon
                        }
                        listItemUpdateRow = row
                        break
                    }
                }
                
                // And now for the new way
                let commands = listCommand.components(separatedBy: ",")
                
                if commands.count > 0 {
                    for command in commands {
                        let action = command.components(separatedBy: ":")
                        switch action[0].lowercased().trimmingCharacters(in: .whitespaces) {
                            case "index":
                                if let i = Int(action[1].trimmingCharacters(in: .whitespaces)) {
                                    if i >= 0 && i < listItemsArray.count {
                                        title = listItemsArray[i].title
                                    }
                                }
                            case "title":
                                title = action[1].trimmingCharacters(in: .whitespaces)
                            case "icon":
                                icon = action[1].trimmingCharacters(in: .whitespaces)
                            case "statustext":
                                statusText = action[1].trimmingCharacters(in: .whitespaces)
                            case "status":
                                statusIcon = action[1].trimmingCharacters(in: .whitespaces)
                            default:
                                break
                            }
                    }
                    
                    // update the list items array
                    if let row = listItemsArray.firstIndex(where: {$0.title == title}) {
                        listItemsArray[row].icon = icon
                        listItemsArray[row].statusIcon = statusIcon
                        listItemsArray[row].statusText = statusText
                        listItemUpdateRow = row
                    }
                    
                }
                
            // quit
            case "quit:" :
                quitDialog(exitCode: appvars.exit5.code)

            default:

                break
            }
        }
    }
    
    func killCommandFile() {
        // delete the command file
        
        let fs = FileManager.init()
        
        if fs.isDeletableFile(atPath: path) {
            do {
                try fs.removeItem(atPath: path)
                //NSLog("Deleted Dialog command file")
            } catch {
                NSLog("Unable to delete command file")
            }
        }
    }
}
