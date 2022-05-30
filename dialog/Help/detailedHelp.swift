//
//  detailedHelp.swift
//  dialog
//
//  Created by Bart Reardon on 30/5/2022.
//

struct HelpStruct {
    var argument : String
    var brief : String
    var detailed : String
}

struct HelpContent {
    
    var helpTitle = HelpStruct(
        argument: "-\(cloptions.titleOption.short), --\(cloptions.titleOption.long) <text>",
        brief: "Set the window title",
        detailed: """
            Set the Dialog title
            Text beyond the length of the title area will get truncated
            Default Title is "\(appvars.titleDefault)"
            Use keyword "none" to disable the title area entirely
        """
    )
    
    var helpTitleFont = HelpStruct(
        argument: "--\(cloptions.titleFont.long) <text>",
        brief: "Change font, size, weight and colour of the window title",
        detailed: """
            Lets you modify the title text of the dialog.

            Can accept up to three parameters, in a comma seperated list, to modify font properties.
            
                color,colour=<text><hex>  - specified in hex format, e.g. #00A4C7
                                            Also accepts any of the standard Apple colours
                                            black, blue, gray, green, orange, pink, purple, red, white, yellow
                                            default if option is invalid is system primary colour

                size=<float>              - accepts any float value.

                name=<fontname>           - accepts a font name or family
                                            list of available names can be determined with --\(cloptions.listFonts.long)

                weight=[thin | light | regular | medium | heavy | bold]
                    default is bold

            Example1: \"colour=#00A4C7,weight=light,size=60\"
            Example2: \"name=Chalkboard,colour=#FFD012,size=40\"
        """
    )
    
    var helpMessage  = ""
    
    var helpMessageAlignment = ""
    
    var helpMessageFont = ""
    
    var helpImage = ""
    
    var helpVideo = ""
    
    var helpIcon = ""
    
    var helpIconSize = ""
    
    var helpCentreIcon = ""
    
    var helpOverlayIcon = ""
    
    var helpHideIcon = ""
    
    var helpButton1 = ""
    
    var helpButton1Action = ""
    
    var helpButton1ShellAction = ""
    
    var helpButton1Disabled = ""
    
    var helpButton2 = ""
    
    var helpButton2Action = ""
    
    var helpInfoButton = ""
    
    var helpInfoButtonAction = ""
    
    var helpQuitOnInfo = ""
    
    var helpFullScreen = ""
    
    var helpBlurScreen = ""
    
    var helpProgressBar = ""
    
    var helpStatusLog = ""
    
    var helpBannerImage = ""
    
    var helpDropDownTitle = ""
    
    var helpDropDownValues = ""
    
    var helpDropDownDefault = ""
    
    var helpTextField = ""
    
    var helpCheckBox = ""
    
    var helpListItem = ""
    
    var helpBackgroundImage = ""
    
    var helpBackgrounfAlpha = ""
    
    var helpBackgroundFill = ""
    
    var helpWindowWidth = ""
    
    var helpWindowHeight = ""
    
    var helpWindowPosition = ""
    
    var helpTimerBar = ""
    
    var helpHideTimerBar = ""
    
    var helpLockWindow = ""
    
    var helpForceOnTop = ""
    
    var helpBigWindow = ""
    
    var helpSmallWindow = ""
    
    var helpJSONOutput = ""
    
    var helpJSONFile = ""
    
    var helpJSONString = ""
    
    var helpQuitKey = ""
    
    var helpIgnoreDND = ""
    
    var helpJAMFHelper = ""
    
    var helpVersion = ""
    
    var helpShowLicense = ""
    
    var helpHelp = ""
    
    var helpTemplate = (
        brief: String(""),
        detailed: String("""
        
        """)
    )
    
}
