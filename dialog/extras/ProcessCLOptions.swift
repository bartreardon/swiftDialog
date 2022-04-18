//
//  ProcessCLOptions.swift
//  dialog
//
//  Created by Bart Reardon on 29/8/21.
//

import Foundation
import SwiftUI
import SwiftyJSON

func processJSON(jsonFilePath: String) -> JSON {
    var json = JSON()
    // read in from file
    let jsonDataPath = NSURL(fileURLWithPath: jsonFilePath)
    var jsonData = Data()
      
    // wrap everything in a try block.IF the URL or filepath is unreadable then bail
    do {
        jsonData = try Data(contentsOf: jsonDataPath as URL)
    } catch {
        quitDialog(exitCode: appvars.exit202.code, exitMessage: "\(appvars.exit202.message) \(jsonFilePath)")
    }
    
    do {
        json = try JSON(data: jsonData)
    } catch {
        quitDialog(exitCode: appvars.exit202.code, exitMessage: "JSON import failed")
    }
    return json
}

func processJSONString(jsonString: String) -> JSON {
    var json = JSON()
    let dataFromString = jsonString.replacingOccurrences(of: "\n", with: "\\n").data(using: .utf8)
    do {
        json = try JSON(data: dataFromString!)
    } catch {
        quitDialog(exitCode: appvars.exit202.code, exitMessage: "JSON import failed")
    }
    return json
}

func getJSON() -> JSON {
    var json = JSON()
    if CLOptionPresent(OptionName: dialogargs.jsonFile) {
        // read json in from file
        json = processJSON(jsonFilePath: CLOptionText(OptionName: dialogargs.jsonFile))
    }
    
    if CLOptionPresent(OptionName: dialogargs.jsonString) {
        // read json in from text string
        json = processJSONString(jsonString: CLOptionText(OptionName: dialogargs.jsonString))
    }
    return json
}

func processCLOptions(json : JSON = getJSON()) {
    
    //this method goes through the arguments that are present and performs any processing required before use
    
    //let json : JSON = getJSON()
    
    if dialogargs.dropdownValues.present {
        // checking for the pre 1.10 way of defining a select list
        if json[dialogargs.dropdownValues.long].exists() && !json["selectitems"].exists() {
            let selectValues = json[dialogargs.dropdownValues.long].stringValue.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            let selectTitle = json[dialogargs.dropdownTitle.long].stringValue
            let selectDefault = json[dialogargs.dropdownDefault.long].stringValue
            dropdownItems.append(DropDownItems(title: selectTitle, values: selectValues, defaultValue: selectDefault, selectedValue: selectDefault))
            print(dropdownItems)
        }
        
        if json["selectitems"].exists() {            
            for i in 0..<json["selectitems"].count {
                
                let selectTitle = json["selectitems"][i]["title"].stringValue
                let selectValues = (json["selectitems"][i]["values"].arrayValue.map {$0.stringValue}).map { $0.trimmingCharacters(in: .whitespaces) }
                let selectDefault = json["selectitems"][i]["default"].stringValue
                
                dropdownItems.append(DropDownItems(title: selectTitle, values: selectValues, defaultValue: selectDefault, selectedValue: selectDefault))
            }
            
        } else {
            let dropdownValues = CLOptionMultiOptions(optionName: dialogargs.dropdownValues.long)
            var selectValues = CLOptionMultiOptions(optionName: dialogargs.dropdownTitle.long)
            var dropdownDefaults = CLOptionMultiOptions(optionName: dialogargs.dropdownDefault.long)
            print(dropdownValues.count)
            print(selectValues.count)
            print(dropdownDefaults.count)
            
            // need to make sure the title and default value arrays are the same size
            for _ in selectValues.count..<dropdownValues.count {
                selectValues.append("")
            }
            for _ in dropdownDefaults.count..<dropdownValues.count {
                dropdownDefaults.append("")
            }
            
            for i in 0..<(dropdownValues.count) {
                dropdownItems.append(DropDownItems(title: selectValues[i], values: dropdownValues[i].components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }, defaultValue: dropdownDefaults[i], selectedValue: dropdownDefaults[i]))
            }
        }
    }
    
    if dialogargs.textField.present {
        if json[dialogargs.textField.long].exists() {
            for i in 0..<json[dialogargs.textField.long].arrayValue.count {
                if json[dialogargs.textField.long][i]["title"].stringValue == "" {
                    textFields.append(TextFieldState(title: String(json[dialogargs.textField.long][i].stringValue)))
                } else {
                    textFields.append(TextFieldState(title: String(json[dialogargs.textField.long][i]["title"].stringValue),
                                                 required: Bool(json[dialogargs.textField.long][i]["required"].boolValue),
                                                 secure: Bool(json[dialogargs.textField.long][i]["secure"].boolValue),
                                                 prompt: String(json[dialogargs.textField.long][i]["prompt"].stringValue))
                                )
                }
            }
        } else {
            for textFieldOption in CLOptionMultiOptions(optionName: dialogargs.textField.long) {
                let items = textFieldOption.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                var fieldTitle : String = ""
                var fieldPrompt : String = ""
                var fieldSecure : Bool = false
                var fieldRequire : Bool = false
                for item in items {
                    let itemName = item.components(separatedBy: "=").first!
                    let itemValue = item.components(separatedBy: "=").last!
                    switch itemName.lowercased() {
                    case "secure":
                        fieldSecure = true
                    case "required":
                        fieldRequire = true
                    case "prompt":
                        fieldPrompt = itemValue
                    default:
                        fieldTitle = itemName
                    }
                }
                textFields.append(TextFieldState(title: fieldTitle, required: fieldRequire, secure: fieldSecure, prompt: fieldPrompt))
            }
        }
        logger(logMessage: "textOptionsArray : \(textFields)")
    }
    
    if dialogargs.checkbox.present {
        if json[dialogargs.checkbox.long].exists() {
            appvars.checkboxOptionsArray = json[dialogargs.checkbox.long].arrayValue.map {$0["label"].stringValue}
            appvars.checkboxValue = json[dialogargs.checkbox.long].arrayValue.map {$0["checked"].boolValue}
            appvars.checkboxDisabled = json[dialogargs.checkbox.long].arrayValue.map {$0["disabled"].boolValue}
        } else {
            appvars.checkboxOptionsArray =  CLOptionMultiOptions(optionName: dialogargs.checkbox.long)
        }
        logger(logMessage: "checkboxOptionsArray : \(appvars.checkboxOptionsArray)")
    }
    
    if dialogargs.mainImage.present {
        if json[dialogargs.mainImage.long].exists() {
            if json[dialogargs.mainImage.long].array == nil {
                // not an array so pull the single value
                appvars.imageArray.append(json[dialogargs.mainImage.long].stringValue)
            } else {
                appvars.imageArray = json[dialogargs.mainImage.long].arrayValue.map {$0["imagename"].stringValue}
                appvars.imageCaptionArray = json[dialogargs.mainImage.long].arrayValue.map {$0["caption"].stringValue}
            }
        } else {
            appvars.imageArray = CLOptionMultiOptions(optionName: dialogargs.mainImage.long)
        }
        logger(logMessage: "imageArray : \(appvars.imageArray)")
    }
    
    if dialogargs.listItem.present {
        if json[dialogargs.listItem.long].exists() {
            
            for i in 0..<json[dialogargs.listItem.long].arrayValue.count {
                if json[dialogargs.listItem.long][i]["title"].stringValue == "" {
                    appvars.listItems.append(ListItems(title: String(json[dialogargs.listItem.long][i].stringValue)))
                } else {
                    appvars.listItems.append(ListItems(title: String(json[dialogargs.listItem.long][i]["title"].stringValue),
                                               icon: String(json[dialogargs.listItem.long][i]["icon"].stringValue),
                                               statusText: String(json[dialogargs.listItem.long][i]["statustext"].stringValue),
                                               statusIcon: String(json[dialogargs.listItem.long][i]["status"].stringValue))
                                )
                }
            }
            
        } else {
            
            for listItem in CLOptionMultiOptions(optionName: dialogargs.listItem.long) {
                let items = listItem.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                var title : String = ""
                var icon : String = ""
                var statusText : String = ""
                var statusIcon : String = ""
                for item in items {
                    let itemName = item.components(separatedBy: "=").first!
                    let itemValue = item.components(separatedBy: "=").last!
                    switch itemName.lowercased() {
                    case "title":
                        title = itemValue
                    case "icon":
                        icon = itemValue
                    case "statustext":
                        statusText = itemValue
                    case "status":
                        statusIcon = itemValue
                    default:
                        title = itemValue
                    }
                }
                appvars.listItems.append(ListItems(title: title, icon: icon, statusText: statusText, statusIcon: statusIcon))
            }
        }
    }
    
    
    if json[dialogargs.mainImageCaption.long].exists() || dialogargs.mainImageCaption.present {
        if json[dialogargs.mainImageCaption.long].exists() {
            appvars.imageCaptionArray.append(json[dialogargs.mainImageCaption.long].stringValue)
        } else {
            appvars.imageCaptionArray = CLOptionMultiOptions(optionName: dialogargs.mainImageCaption.long)
        }
        logger(logMessage: "imageCaptionArray : \(appvars.imageCaptionArray)")
    }
    
    if !json[dialogargs.autoPlay.long].exists() && !dialogargs.autoPlay.present {
        dialogargs.autoPlay.value = "0"
        logger(logMessage: "autoPlay.value : \(dialogargs.autoPlay.value)")
    }
    
    // process command line options that just display info and exit before we show the main window
    if (dialogargs.helpOption.present || CommandLine.arguments.count == 1) {
        print(helpText)
        quitDialog(exitCode: appvars.exitNow.code)
        //exit(0)
    }
    if dialogargs.getVersion.present {
        printVersionString()
        quitDialog(exitCode: appvars.exitNow.code)
        //exit(0)
    }
    if dialogargs.showLicense.present {
        print(licenseText)
        quitDialog(exitCode: appvars.exitNow.code)
        //exit(0)
    }
    if dialogargs.buyCoffee.present {
        //I'm a teapot
        print("If you like this app and want to buy me a coffee https://www.buymeacoffee.com/bartreardon")
        quitDialog(exitCode: appvars.exitNow.code)
        //exit(418)
    }
    if dialogargs.ignoreDND.present {
        appvars.willDisturb = true
    }
    
    if dialogargs.listFonts.present {
        //All font Families
        let fontfamilies = NSFontManager.shared.availableFontFamilies
        print("Available font families:")
        for familyname in fontfamilies.enumerated() {
            print("  \(familyname.element)")
        }
        
        // All font names
        let fonts = NSFontManager.shared.availableFonts
        print("Available font names:")
        for fontname in fonts.enumerated() {
            print("  \(fontname.element)")
        }
        quitDialog(exitCode: appvars.exit0.code)
    }
    
    //check for DND and exit if it's on
    if isDNDEnabled() && !appvars.willDisturb {
        quitDialog(exitCode: 20, exitMessage: "Do Not Disturb is enabled. Exiting")
    }
        
    if dialogargs.windowWidth.present {
        //appvars.windowWidth = CGFloat() //CLOptionText(OptionName: dialogargs.windowWidth)
        if dialogargs.windowWidth.value.last == "%" {
            appvars.windowWidth = appvars.screenWidth * string2float(string: String(dialogargs.windowWidth.value.dropLast()))/100
        } else {
            appvars.windowWidth = string2float(string: dialogargs.windowWidth.value)
        }
        logger(logMessage: "windowWidth : \(appvars.windowWidth)")
    }
    if dialogargs.windowHeight.present {
        //appvars.windowHeight = CGFloat() //CLOptionText(OptionName: dialogargs.windowHeight)
        if dialogargs.windowHeight.value.last == "%" {
            appvars.windowHeight = appvars.screenHeight * string2float(string: String(dialogargs.windowHeight.value.dropLast()))/100
        } else {
            appvars.windowHeight = string2float(string: dialogargs.windowHeight.value)
        }
        logger(logMessage: "windowHeight : \(appvars.windowHeight)")
    }
    
    if dialogargs.iconSize.present {
        //appvars.windowWidth = CGFloat() //CLOptionText(OptionName: dialogargs.windowWidth)
        appvars.iconWidth = string2float(string: dialogargs.iconSize.value)
        logger(logMessage: "iconWidth : \(appvars.iconWidth)")
    }
    /*
    if dialogargs.iconHeight.present {
        //appvars.windowHeight = CGFloat() //CLOptionText(OptionName: dialogargs.windowHeight)
        appvars.iconHeight = NumberFormatter().number(from: dialogargs.iconHeight.value) as! CGFloat
    }
    */
    // Correct feng shui so the app accepts keyboard input
    // from https://stackoverflow.com/questions/58872398/what-is-the-minimally-viable-gui-for-command-line-swift-scripts
    let app = NSApplication.shared
    //app.setActivationPolicy(.regular)
    app.setActivationPolicy(.accessory)
            
    if dialogargs.titleFont.present {
        logger(logMessage: "titleFont.value : \(dialogargs.titleFont.value)")
        let fontCLValues = dialogargs.titleFont.value
        var fontValues = [""]
        //split by ,
        fontValues = fontCLValues.components(separatedBy: ",")
        fontValues = fontValues.map { $0.trimmingCharacters(in: .whitespaces) } // trim out any whitespace from the values if there were spaces before after the comma
        for value in fontValues {
            // split by =
            let item = value.components(separatedBy: "=")
            if item[0] == "size" {
                appvars.titleFontSize = string2float(string: item[1], defaultValue: appvars.titleFontSize)
                logger(logMessage: "titleFontSize : \(appvars.titleFontSize)")
            }
            if item[0] == "weight" {
                appvars.titleFontWeight = textToFontWeight(item[1])
                logger(logMessage: "titleFontWeight : \(appvars.titleFontWeight)")
            }
            if item[0] == "colour" || item[0] == "color" {
                appvars.titleFontColour = stringToColour(item[1])
                logger(logMessage: "titleFontColour : \(appvars.titleFontColour)")
            }
            if item[0] == "name" {
                appvars.titleFontName = item[1]
                logger(logMessage: "titleFontName : \(appvars.titleFontName)")
            }
            
        }
    }
    
    if dialogargs.messageFont.present {
        logger(logMessage: "messageFont.value : \(dialogargs.messageFont.value)")
        let fontCLValues = dialogargs.messageFont.value
        var fontValues = [""]
        //split by ,
        fontValues = fontCLValues.components(separatedBy: ",")
        fontValues = fontValues.map { $0.trimmingCharacters(in: .whitespaces) } // trim out any whitespace from the values if there were spaces before after the comma
        for value in fontValues {
            // split by =
            let item = value.components(separatedBy: "=")
            if item[0] == "size" {
                appvars.messageFontSize = string2float(string: item[1], defaultValue: appvars.messageFontSize)
                logger(logMessage: "messageFontSize : \(appvars.messageFontSize)")
            }
            if item[0] == "weight" {
                appvars.messageFontWeight = textToFontWeight(item[1])
                logger(logMessage: "messageFontWeight : \(appvars.messageFontWeight)")
            }
            if item[0] == "colour" || item[0] == "color" {
                appvars.messageFontColour = stringToColour(item[1])
                logger(logMessage: "messageFontColour : \(appvars.messageFontColour)")
            }
            if item[0] == "name" {
                appvars.messageFontName = item[1]
                logger(logMessage: "messageFontName : \(appvars.messageFontName)")
            }
        }
    }
            
    if dialogargs.hideIcon.present || dialogargs.iconOption.value == "none" || dialogargs.bannerImage.present {
        appvars.iconIsHidden = true
        logger(logMessage: "iconIsHidden = true")
    }
    
    if dialogargs.centreIcon.present {
        appvars.iconIsCentred = true
        logger(logMessage: "iconIsCentred = true")
    }
    
    if dialogargs.lockWindow.present {
        appvars.windowIsMoveable = true
        logger(logMessage: "windowIsMoveable = true")
    }
    
    if dialogargs.forceOnTop.present {
        appvars.windowOnTop = true
        logger(logMessage: "windowOnTop = true")
    }
    
    if dialogargs.jsonOutPut.present {
        appvars.jsonOut = true
        logger(logMessage: "jsonOut = true")
    }
    
    // we define this stuff here as we will use the info to draw the window.
    if dialogargs.smallWindow.present {
        // scale everything down a notch
        appvars.smallWindow = true
        appvars.scaleFactor = 0.75
        logger(logMessage: "smallWindow.present")
    } else if dialogargs.bigWindow.present {
        // scale everything up a notch
        appvars.bigWindow = true
        appvars.scaleFactor = 1.25
        logger(logMessage: "bigWindow.present")
    }
}

func processCLOptionValues() {
    
    // this method reads in arguments from either json file or from the command line and loads them into the cloptions object
    // also records whether an argument is present or not
    
    let json : JSON = getJSON()
    
    dialogargs.titleOption.value             = json[dialogargs.titleOption.long].string ?? CLOptionText(OptionName: dialogargs.titleOption, DefaultValue: appvars.titleDefault)
    dialogargs.titleOption.present           = json[dialogargs.titleOption.long].exists() || CLOptionPresent(OptionName: dialogargs.titleOption)

    dialogargs.messageOption.value           = json[dialogargs.messageOption.long].string ?? CLOptionText(OptionName: dialogargs.messageOption, DefaultValue: appvars.messageDefault)
    dialogargs.messageOption.present         = json[dialogargs.titleOption.long].exists() || CLOptionPresent(OptionName: dialogargs.messageOption)
    
    dialogargs.messageAlignment.value        = json[dialogargs.messageAlignment.long].string ?? CLOptionText(OptionName: dialogargs.messageAlignment, DefaultValue: appvars.messageAlignmentTextRepresentation)
    dialogargs.messageAlignment.present      = json[dialogargs.messageAlignment.long].exists() || CLOptionPresent(OptionName: dialogargs.messageAlignment)
    
    if dialogargs.messageAlignment.present {
        switch dialogargs.messageAlignment.value {
        case "left":
            appvars.messageAlignment = .leading
        case "centre","center":
            appvars.messageAlignment = .center
        case "right":
            appvars.messageAlignment = .trailing
        default:
            appvars.messageAlignment = .leading
        }
    }
    
    // window location on screen
    if CLOptionPresent(OptionName: dialogargs.position) {
        switch CLOptionText(OptionName: dialogargs.position) {
        case "topleft":
            appvars.windowPositionVertical = NSWindow.Position.Vertical.top
            appvars.windowPositionHorozontal = NSWindow.Position.Horizontal.left
        case "topright":
            appvars.windowPositionVertical = NSWindow.Position.Vertical.top
            appvars.windowPositionHorozontal = NSWindow.Position.Horizontal.right
        case "bottomleft":
            appvars.windowPositionVertical = NSWindow.Position.Vertical.bottom
            appvars.windowPositionHorozontal = NSWindow.Position.Horizontal.left
        case "bottomright":
            appvars.windowPositionVertical = NSWindow.Position.Vertical.bottom
            appvars.windowPositionHorozontal = NSWindow.Position.Horizontal.right
        case "left":
            appvars.windowPositionVertical = NSWindow.Position.Vertical.center
            appvars.windowPositionHorozontal = NSWindow.Position.Horizontal.left
        case "right":
            appvars.windowPositionVertical = NSWindow.Position.Vertical.center
            appvars.windowPositionHorozontal = NSWindow.Position.Horizontal.right
        case "top":
            appvars.windowPositionVertical = NSWindow.Position.Vertical.top
            appvars.windowPositionHorozontal = NSWindow.Position.Horizontal.center
        case "bottom":
            appvars.windowPositionVertical = NSWindow.Position.Vertical.bottom
            appvars.windowPositionHorozontal = NSWindow.Position.Horizontal.center
        case "centre","center":
            appvars.windowPositionVertical = NSWindow.Position.Vertical.deadcenter
            appvars.windowPositionHorozontal = NSWindow.Position.Horizontal.center
        default:
            appvars.windowPositionVertical = NSWindow.Position.Vertical.center
            appvars.windowPositionHorozontal = NSWindow.Position.Horizontal.center
        }
    }

    dialogargs.iconOption.value              = json[dialogargs.iconOption.long].string ?? CLOptionText(OptionName: dialogargs.iconOption, DefaultValue: "default")
    dialogargs.iconOption.present            = json[dialogargs.iconOption.long].exists() || CLOptionPresent(OptionName: dialogargs.iconOption)
    
    dialogargs.iconSize.value                = json[dialogargs.iconSize.long].string ?? CLOptionText(OptionName: dialogargs.iconSize, DefaultValue: "\(appvars.iconWidth)")
    dialogargs.iconSize.present              = json[dialogargs.iconSize.long].exists() || CLOptionPresent(OptionName: dialogargs.iconSize)
    
    //dialogargs.iconHeight.value              = CLOptionText(OptionName: dialogargs.iconHeight)
    //dialogargs.iconHeight.present            = CLOptionPresent(OptionName: dialogargs.iconHeight)

    dialogargs.overlayIconOption.value       = json[dialogargs.overlayIconOption.long].string ?? CLOptionText(OptionName: dialogargs.overlayIconOption)
    dialogargs.overlayIconOption.present     = json[dialogargs.overlayIconOption.long].exists() || CLOptionPresent(OptionName: dialogargs.overlayIconOption)

    dialogargs.bannerImage.value             = json[dialogargs.bannerImage.long].string ?? CLOptionText(OptionName: dialogargs.bannerImage)
    dialogargs.bannerImage.present           = json[dialogargs.bannerImage.long].exists() || CLOptionPresent(OptionName: dialogargs.bannerImage)

    dialogargs.button1TextOption.value       = json[dialogargs.button1TextOption.long].string ?? CLOptionText(OptionName: dialogargs.button1TextOption, DefaultValue: appvars.button1Default)
    dialogargs.button1TextOption.present     = json[dialogargs.button1TextOption.long].exists() || CLOptionPresent(OptionName: dialogargs.button1TextOption)

    dialogargs.button1ActionOption.value     = json[dialogargs.button1ActionOption.long].string ?? CLOptionText(OptionName: dialogargs.button1ActionOption)
    dialogargs.button1ActionOption.present   = json[dialogargs.button1ActionOption.long].exists() || CLOptionPresent(OptionName: dialogargs.button1ActionOption)

    dialogargs.button1ShellActionOption.value = json[dialogargs.button1ShellActionOption.long].string ?? CLOptionText(OptionName: dialogargs.button1ShellActionOption)
    dialogargs.button1ShellActionOption.present = json[dialogargs.button1ShellActionOption.long].exists() || CLOptionPresent(OptionName: dialogargs.button1ShellActionOption)
    
    dialogargs.button1Disabled.present       = json[dialogargs.button1Disabled.long].exists() || CLOptionPresent(OptionName: dialogargs.button1Disabled)

    dialogargs.button2TextOption.value       = json[dialogargs.button2TextOption.long].string ?? CLOptionText(OptionName: dialogargs.button2TextOption, DefaultValue: appvars.button2Default)
    dialogargs.button2TextOption.present     = json[dialogargs.button2TextOption.long].exists() || CLOptionPresent(OptionName: dialogargs.button2TextOption)

    dialogargs.button2ActionOption.value     = json[dialogargs.button2ActionOption.long].string ?? CLOptionText(OptionName: dialogargs.button2ActionOption)
    dialogargs.button2ActionOption.present   = json[dialogargs.button2ActionOption.long].exists() || CLOptionPresent(OptionName: dialogargs.button2ActionOption)

    dialogargs.buttonInfoTextOption.value    = json[dialogargs.buttonInfoTextOption.long].string ?? CLOptionText(OptionName: dialogargs.buttonInfoTextOption, DefaultValue: appvars.buttonInfoDefault)
    dialogargs.buttonInfoTextOption.present  = json[dialogargs.buttonInfoTextOption.long].exists() || CLOptionPresent(OptionName: dialogargs.buttonInfoTextOption)

    dialogargs.buttonInfoActionOption.value  = json[dialogargs.buttonInfoActionOption.long].string ?? CLOptionText(OptionName: dialogargs.buttonInfoActionOption)
    dialogargs.buttonInfoActionOption.present = json[dialogargs.buttonInfoActionOption.long].exists() || CLOptionPresent(OptionName: dialogargs.buttonInfoActionOption)

    //dialogargs.dropdownTitle.value           = json[dialogargs.dropdownTitle.long].string ?? CLOptionText(OptionName: dialogargs.dropdownTitle)
    dialogargs.dropdownTitle.present         = json[dialogargs.dropdownTitle.long].exists() || CLOptionPresent(OptionName: dialogargs.dropdownTitle)

    //dialogargs.dropdownValues.value          = json[dialogargs.dropdownValues.long].string ?? CLOptionText(OptionName: dialogargs.dropdownValues)
    dialogargs.dropdownValues.present        = json["selectitems"].exists() || json[dialogargs.dropdownValues.long].exists() || CLOptionPresent(OptionName: dialogargs.dropdownValues)

    //dialogargs.dropdownDefault.value         = json[dialogargs.dropdownDefault.long].string ?? CLOptionText(OptionName: dialogargs.dropdownDefault)
    dialogargs.dropdownDefault.present       = json[dialogargs.dropdownDefault.long].exists() || CLOptionPresent(OptionName: dialogargs.dropdownDefault)

    dialogargs.titleFont.value               = json[dialogargs.titleFont.long].string ?? CLOptionText(OptionName: dialogargs.titleFont)
    dialogargs.titleFont.present             = json[dialogargs.titleFont.long].exists() || CLOptionPresent(OptionName: dialogargs.titleFont)
    
    dialogargs.messageFont.value             = json[dialogargs.messageFont.long].string ?? CLOptionText(OptionName: dialogargs.messageFont)
    dialogargs.messageFont.present           = json[dialogargs.messageFont.long].exists() || CLOptionPresent(OptionName: dialogargs.messageFont)

    //dialogargs.textField.value               = CLOptionText(OptionName: dialogargs.textField)
    dialogargs.textField.present             = json[dialogargs.textField.long].exists() || CLOptionPresent(OptionName: dialogargs.textField)
    
    dialogargs.checkbox.present             = json[dialogargs.checkbox.long].exists() || CLOptionPresent(OptionName: dialogargs.checkbox)

    dialogargs.timerBar.value                = json[dialogargs.timerBar.long].string ?? CLOptionText(OptionName: dialogargs.timerBar, DefaultValue: "\(appvars.timerDefaultSeconds)")
    dialogargs.timerBar.present              = json[dialogargs.timerBar.long].exists() || CLOptionPresent(OptionName: dialogargs.timerBar)
    
    dialogargs.progressBar.value             = json[dialogargs.progressBar.long].string ?? CLOptionText(OptionName: dialogargs.progressBar)
    dialogargs.progressBar.present           = json[dialogargs.progressBar.long].exists() || CLOptionPresent(OptionName: dialogargs.progressBar)
    
    dialogargs.progressText.value             = json[dialogargs.progressText.long].string ?? CLOptionText(OptionName: dialogargs.progressText, DefaultValue: " ")
    dialogargs.progressText.present           = json[dialogargs.progressText.long].exists() || CLOptionPresent(OptionName: dialogargs.progressText)
    
    //dialogargs.mainImage.value               = CLOptionText(OptionName: dialogargs.mainImage)
    dialogargs.mainImage.present             = json[dialogargs.mainImage.long].exists() || CLOptionPresent(OptionName: dialogargs.mainImage)
    
    //dialogargs.mainImageCaption.value        = CLOptionText(OptionName: dialogargs.mainImageCaption)
    dialogargs.mainImageCaption.present      = json[dialogargs.mainImageCaption.long].exists() || CLOptionPresent(OptionName: dialogargs.mainImageCaption)
    
    dialogargs.listItem.present              = json[dialogargs.listItem.long].exists() || CLOptionPresent(OptionName: dialogargs.listItem)

    dialogargs.windowWidth.value             = json[dialogargs.windowWidth.long].string ?? CLOptionText(OptionName: dialogargs.windowWidth)
    dialogargs.windowWidth.present           = json[dialogargs.windowWidth.long].exists() || CLOptionPresent(OptionName: dialogargs.windowWidth)

    dialogargs.windowHeight.value            = json[dialogargs.windowHeight.long].string ?? CLOptionText(OptionName: dialogargs.windowHeight)
    dialogargs.windowHeight.present          = json[dialogargs.windowHeight.long].exists() || CLOptionPresent(OptionName: dialogargs.windowHeight)
    
    dialogargs.watermarkImage.value          = json[dialogargs.watermarkImage.long].string ?? CLOptionText(OptionName: dialogargs.watermarkImage)
    dialogargs.watermarkImage.present        = json[dialogargs.watermarkImage.long].exists() || CLOptionPresent(OptionName: dialogargs.watermarkImage)
        
    dialogargs.watermarkAlpha.value          = json[dialogargs.watermarkAlpha.long].string ?? CLOptionText(OptionName: dialogargs.watermarkAlpha)
    dialogargs.watermarkAlpha.present        = json[dialogargs.watermarkAlpha.long].exists() || CLOptionPresent(OptionName: dialogargs.watermarkAlpha)
    
    dialogargs.watermarkPosition.value       = json[dialogargs.watermarkPosition.long].string ?? CLOptionText(OptionName: dialogargs.watermarkPosition)
    dialogargs.watermarkPosition.present     = json[dialogargs.watermarkPosition.long].exists() || CLOptionPresent(OptionName: dialogargs.watermarkPosition)
    
    dialogargs.watermarkFill.value           = json[dialogargs.watermarkFill.long].string ?? CLOptionText(OptionName: dialogargs.watermarkFill)
    dialogargs.watermarkFill.present         = json[dialogargs.watermarkFill.long].exists() || CLOptionPresent(OptionName: dialogargs.watermarkFill)
    
    dialogargs.autoPlay.value                = json[dialogargs.autoPlay.long].string ?? CLOptionText(OptionName: dialogargs.autoPlay, DefaultValue: "\(appvars.timerDefaultSeconds)")
    dialogargs.autoPlay.present              = json[dialogargs.autoPlay.long].exists() || CLOptionPresent(OptionName: dialogargs.autoPlay)
    
    dialogargs.statusLogFile.value           = json[dialogargs.statusLogFile.long].string ?? CLOptionText(OptionName: dialogargs.statusLogFile)
    dialogargs.statusLogFile.present         = json[dialogargs.statusLogFile.long].exists() || CLOptionPresent(OptionName: dialogargs.statusLogFile)
    
    if !dialogargs.statusLogFile.present {
        dialogargs.statusLogFile.value = appvars.defaultStatusLogFile
    }
    
    dialogargs.video.value                   = json[dialogargs.video.long].string ?? CLOptionText(OptionName: dialogargs.video)
    dialogargs.video.present                 = json[dialogargs.video.long].exists() || CLOptionPresent(OptionName: dialogargs.video)
    if dialogargs.video.present {
        // set a larger window size. 900x600 will fit a standard 16:9 video
        appvars.windowWidth = appvars.videoWindowWidth
        appvars.windowHeight = appvars.videoWindowHeight
    }
    
    dialogargs.videoCaption.value            = json[dialogargs.videoCaption.long].string ?? CLOptionText(OptionName: dialogargs.videoCaption)
    dialogargs.videoCaption.present          = json[dialogargs.videoCaption.long].exists() || CLOptionPresent(OptionName: dialogargs.videoCaption)

    if dialogargs.watermarkImage.present {
        // return the image resolution and re-size the window to match
        let bgImage = getImageFromPath(fileImagePath: dialogargs.watermarkImage.value)
        if bgImage.size.width > appvars.windowWidth && bgImage.size.height > appvars.windowHeight && !dialogargs.windowHeight.present && !dialogargs.watermarkFill.present {
            // keep the same width ratio but change the height
            var wWidth = appvars.windowWidth
            if dialogargs.windowWidth.present {
                wWidth = string2float(string: dialogargs.windowWidth.value)
            }
            let widthRatio = wWidth / bgImage.size.width  // get the ration of the image height to the current display width
            let newHeight = (bgImage.size.height * widthRatio) - 28 //28 needs to be removed to account for the phantom title bar height
            appvars.windowHeight = floor(newHeight) // floor() will strip any fractional values as a result of the above multiplication
                                                    // we need to do this as window heights can't be fractional and weird things happen
                        
            if !dialogargs.watermarkFill.present {
                dialogargs.watermarkFill.present = true
                dialogargs.watermarkFill.value = "fill"
            }
        }
    }
    
    // anthing that is an option only with no value
    dialogargs.button2Option.present         = json[dialogargs.button2Option.long].boolValue || CLOptionPresent(OptionName: dialogargs.button2Option)
    dialogargs.infoButtonOption.present      = json[dialogargs.infoButtonOption.long].boolValue || CLOptionPresent(OptionName: dialogargs.infoButtonOption)
    dialogargs.hideIcon.present              = json[dialogargs.hideIcon.long].boolValue || CLOptionPresent(OptionName: dialogargs.hideIcon)
    dialogargs.centreIcon.present            = json[dialogargs.centreIcon.long].boolValue || json[dialogargs.centreIconSE.long].boolValue || CLOptionPresent(OptionName: dialogargs.centreIcon) || CLOptionPresent(OptionName: dialogargs.centreIconSE)
    dialogargs.warningIcon.present           = json[dialogargs.warningIcon.long].boolValue || CLOptionPresent(OptionName: dialogargs.warningIcon)
    dialogargs.infoIcon.present              = json[dialogargs.infoIcon.long].boolValue || CLOptionPresent(OptionName: dialogargs.infoIcon)
    dialogargs.cautionIcon.present           = json[dialogargs.cautionIcon.long].boolValue || CLOptionPresent(OptionName: dialogargs.cautionIcon)
    dialogargs.lockWindow.present            = json[dialogargs.lockWindow.long].boolValue || CLOptionPresent(OptionName: dialogargs.lockWindow)
    dialogargs.forceOnTop.present            = json[dialogargs.forceOnTop.long].boolValue || CLOptionPresent(OptionName: dialogargs.forceOnTop)
    dialogargs.smallWindow.present           = json[dialogargs.smallWindow.long].boolValue || CLOptionPresent(OptionName: dialogargs.smallWindow)
    dialogargs.bigWindow.present             = json[dialogargs.bigWindow.long].boolValue || CLOptionPresent(OptionName: dialogargs.bigWindow)
    dialogargs.fullScreenWindow.present      = json[dialogargs.fullScreenWindow.long].boolValue || CLOptionPresent(OptionName: dialogargs.fullScreenWindow)
    dialogargs.jsonOutPut.present            = json[dialogargs.jsonOutPut.long].boolValue || CLOptionPresent(OptionName: dialogargs.jsonOutPut)
    dialogargs.ignoreDND.present             = json[dialogargs.ignoreDND.long].boolValue || CLOptionPresent(OptionName: dialogargs.ignoreDND)
    dialogargs.hideTimerBar.present          = json[dialogargs.hideTimerBar.long].boolValue || CLOptionPresent(OptionName: dialogargs.hideTimerBar)
    dialogargs.quitOnInfo.present            = json[dialogargs.quitOnInfo.long].boolValue || CLOptionPresent(OptionName: dialogargs.quitOnInfo)
    dialogargs.blurScreen.present            = json[dialogargs.blurScreen.long].boolValue || CLOptionPresent(OptionName: dialogargs.blurScreen)
    
    // command line only options
    dialogargs.listFonts.present             = CLOptionPresent(OptionName: dialogargs.listFonts)
    dialogargs.helpOption.present            = CLOptionPresent(OptionName: dialogargs.helpOption)
    dialogargs.demoOption.present            = CLOptionPresent(OptionName: dialogargs.demoOption)
    dialogargs.buyCoffee.present             = CLOptionPresent(OptionName: dialogargs.buyCoffee)
    dialogargs.showLicense.present           = CLOptionPresent(OptionName: dialogargs.showLicense)
    dialogargs.jamfHelperMode.present        = CLOptionPresent(OptionName: dialogargs.jamfHelperMode)
    dialogargs.debug.present                 = CLOptionPresent(OptionName: dialogargs.debug)
    dialogargs.getVersion.present            = CLOptionPresent(OptionName: dialogargs.getVersion)

}
