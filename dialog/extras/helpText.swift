//
//  helpText.swift
//  dialog
//
//  Created by Bart Reardon on 17/9/21.
//

//import Foundation

var helpText = """
    Dialog version \(getVersionString()) ©2022 Bart Reardon

    OPTIONS:
    
    ** Basic Options - - - - - - - - - - - - - - - -
    
        -\(dialogargs.titleOption.short), --\(dialogargs.titleOption.long) <text>
                    Set the Dialog title
                    Text beyond the length of the title area will get truncated
                    Default Title is "\(appvars.titleDefault)"
                    Use keyword "none" to disable the title area entirely

        --\(dialogargs.titleFont.long) <text>
                    Lets you modify the title text of the dialog.
    
                    Can accept up to three parameters, in a comma seperated list, to modify font properties.
                    
                        color,colour=<text><hex>  - specified in hex format, e.g. #00A4C7
                                                    Also accepts any of the standard Apple colours
                                                    black, blue, gray, green, orange, pink, purple, red, white, yellow
                                                    default if option is invalid is system primary colour
    
                        size=<float>              - accepts any float value.
    
                        name=<fontname>           - accepts a font name or family
                                                    list of available names can be determined with --\(dialogargs.listFonts.long)

                        weight=[thin | light | regular | medium | heavy | bold]
                            default is bold
    
                    Example1: \"colour=#00A4C7,weight=light,size=60\"
                    Example2: \"name=Chalkboard,colour=#FFD012,size=40\"
        
        -\(dialogargs.messageOption.short), --\(dialogargs.messageOption.long) <text>
                    Set the dialog message
                    Messages can be plain text or can include Markdown
                    Markdown follows the CommonMark Spec https://spec.commonmark.org/current/
                    The message can be of any length. If it is larger than the viewable area
                    The message contents will be presented in  scrolable area.
    
        --\(dialogargs.messageAlignment.long) [left | centre | center | right]
                    Set the message alignment.
                    Default is 'left'
    
        --\(dialogargs.messageFont.long) <text>
                    Lets you modify the message text of the dialog.
    
                    Can accept up to three parameters, in a comma seperated list, to modify font properties.
                    
                        color,colour=<text><hex>  - specified in hex format, e.g. #00A4C7
                                                    Also accepts any of the standard Apple colours
                                                    black, blue, gray, green, orange, pink, purple, red, white, yellow
                                                    default if option is invalid is system primary colour
    
                        size=<float>              - accepts any float value.
    
                        name=<fontname>           - accepts a font name or family
                                                    list of available names can be determined with --\(dialogargs.listFonts.long)

                        weight=[thin | light | regular | medium | heavy | bold]
                            default is regular
    
                    Example1: \"colour=#00A4C7,weight=light,size=60\"
                    Example2: \"name=Chalkboard,colour=#FFD012,size=40\"
    
                    ## CAUTION : Results may be unexpected when mixing font names and weights with markdown
        
        -\(dialogargs.mainImage.short), --\(dialogargs.mainImage.long)  <file> | <url>
                    Display an image instead of a message.
                    Images will be resized to fit the available display area
    
                    --\(dialogargs.mainImageCaption.long) <text>
                        Text that will appear underneath the displayed image.
    
        --\(dialogargs.video.long)  <file> | <url>
                    Display a video instead of a message.
                    Videos will be resized to fit the available display area without clipping the video
                    Default dialog window size is changed to \(appvars.videoWindowWidth) x \(appvars.videoWindowHeight)
                    
    
                    --\(dialogargs.videoCaption.long) <text>
                        Text that will appear underneath the displayed video.
    
                    --\(dialogargs.autoPlay.long)
                        Will force the video to start playing automatically.
        
        -\(dialogargs.iconOption.short), --\(dialogargs.iconOption.long) <file> | <url>
                    Set the icon to display
                    Acceptable Values:
                    file path to png or jpg           -  "/file/path/image.[png|jpg]"
                    file path to Application          -  "/Applications/Chess.app"
                    URL of file resource              -  "https://someurl/file.[png|jpg]"
                    SF Symbol                         -  "SF=sf.symbol.name"
                    builtin                           -  info | caution | warning

                    if not specified, default icon will be used
                    Images from either file or URL are displayed as roundrect if no transparancy
    
                    "none" can also be specified to not display an icon but maintain layout (see also --\(dialogargs.hideIcon.long))
    
        --\(dialogargs.iconSize.long)
                    Will render the icon with the specified size.
                    Default size is 170
    
        --\(dialogargs.centreIcon.long)
                    re-positions the icon to be in the centre, between the title and message areas
    
        -\(dialogargs.overlayIconOption.short), --\(dialogargs.overlayIconOption.long) <file> | <url>
                    Set an image to display as an overlay to --icon
                    image is displayed at 1/2 resolution to the main image and positioned to the bottom right
                    Acceptable Values:
                    file path to png or jpg           -  "/file/path/image.[png|jpg]"
                    file path to Application          -  "/Applications/Chess.app"
                    URL of file resource              -  "https://someurl/file.[png|jpg]"
                    SF Symbol                         -  "SF=sf.symbol.name"
                    builtin                           -  info | caution | warning
    
                When Specifying SF Symbols for icon or overlay icon, additional parameters for colour and weight are available:
                additionl parameters are seperated by comma

                    "SF=sf.symbol.name,colour=<text><hex>,weight=<text>"
    
                    SF Symbols - visit https://developer.apple.com/sf-symbols/ for details on over 3,100 symbols

                    color,colour=<text><hex>          - specified in hex format, e.g. #00A4C7
                    bgcolor,bgcolour=<text><hex>
                                                      Also accepts any of the standard Apple colours
                                                      black, blue, gray, green, orange, pink, purple, red, white, yellow
                                                      default if option is invalid is system primary colour
    
                                                      bgcolour, bgcolor will set the background colour of the icon overlay
                                                        when SF Symbols are used
    
                                                      - Special colour "auto".
                                                      When used with a multicolor SF Symbol, the symbols
                                                        default colour scheem will be used
                                                      ** If used with a monochrome SF Symbol **
                                                      ** it will default to black and will not respect dark mode **

                    weight=<text>                     - accepts any of the following values:
                                                       thin (default), light, regular, medium, heavy, bold
    
        -\(dialogargs.hideIcon.short), --\(dialogargs.hideIcon.long)
                    Hides the icon from view
                    Doing so increases the space available for message text
        
        --\(dialogargs.button1TextOption.long) <text>
                    Set the label for Button1
                    Default label is "\(appvars.button1Default)"
                    Bound to <Enter> key

        --\(dialogargs.button1ActionOption.long) <url>
                    Set the action to take.
                    Accepts URL
                    Default action if not specified is no action
                    Return code when actioned is 0
    
        --\(dialogargs.button1ShellActionOption.long) <command>
                    << EXPERIMENTAL >>
                    Runs the specified shell command using zsh
                    Command input and output is not sanitised or checked.
                    If your command fails, Dialog still exits 0
    
        --\(dialogargs.button1Disabled.long)
                    Launches dialig with button1 disabled
                    To re-enable, send `buton1: enable` to the dialog command file.

        -\(dialogargs.button2Option.short), --\(dialogargs.button2Option.long)
                    Displays button2 with default label of "\(appvars.button2Default)"
            OR

        --\(dialogargs.button2TextOption.long) <text>
                    Set the label for Button1
                    Bound to <ESC> key

        --\(dialogargs.button2ActionOption.long) <url>
                    Return code when actioned is 2
                    -- Setting Custon Actions For Button 2 Is Not Implemented at this time --

        -\(dialogargs.infoButtonOption.short), --\(dialogargs.infoButtonOption.long)
                    Displays info button with default label of "\(appvars.buttonInfoDefault)"
            
            OR

        --\(dialogargs.buttonInfoTextOption.long) <text>
                    Set the label for Information Button
                    If not specified, Info button will not be displayed
    
        --\(dialogargs.buttonInfoActionOption.long)  <url>
                    Set the action to take.
                    Accepts URL
                    Default action if not specified is no action
    
        --\(dialogargs.quitOnInfo.long)
                    Will tell Dialog to quit when the info button is selected
                    Return code when actioned is 3
    
    ** Advanced Options - - - - - - - - - - - - - - - -
    
        -\(dialogargs.fullScreenWindow.short), --\(dialogargs.fullScreenWindow.long)
                    Uses full screen view.
                    In this view, only banner, title, icon and the message area are visible.
    
        --\(dialogargs.blurScreen.long)
                    Will blur the background of the display while dialog is showing
    
        --\(dialogargs.progressBar.long) <int>
                    Makes an interactive progress bar visible with <int> steps.
                    To increment the progress bar send "progress: <int>" command to the dialog command file
    
        --\(dialogargs.progressText.long) <text>
                    Initiate the progress text are with some useful content.
                    To update progress text send "progresstext: <text>" command to the dialog command file
    
        --\(dialogargs.statusLogFile.long) <file>
                    Sets the path to the command file Dialog will read from to receive updates
                    Default file is /var/log/dialog.log

        -\(dialogargs.bannerImage.short), --\(dialogargs.bannerImage.long) <file> | <url>
                    Shows a banner image at the top of the dialog
                    Banners images fill the entire top width of the window and are resized to fill, positioned from
                    the top left corner of the image.
                    Specifying this option will imply --\(dialogargs.hideIcon.long)
                    Recommended Banner Image size is 850x150.
    
        --\(dialogargs.dropdownTitle.long) <text>
                    Title for dropdown selection
    
        --\(dialogargs.dropdownValues.long) <text><csv>
                    List of values to be displayed in the dropdown, specivied in CSV format
                    e.g. "Option 1,Option 2,Option 3"
    
        --\(dialogargs.dropdownDefault.long) <text>
                    Default option to be selected (must match one of the items in the list)
    
                    If specified, the selected option will be sent to stdout in two forms:
                      SelectedOption - Outputs the text of the option seelcted
                      SelectedIndex  - Outputs the index of the option selected, starting at 0
    
                      example output b:
                        SelectedOption: Option 1
                        SelectedIndex: 0
    
                    Output of select items is only shown if Dialog's exit code is 0
    
                    Multiple dropdown caluse, titles and default selections can be specified as required.
                    Associations are made in the order they are presented on the command line
                    Or use json formatting for more direct control. for example:
                    
                    "selectitems" : [
                        {"title" : "Select 1", "values" : ["one","two","three"]},
                        {"title" : "Select 2", "values" : ["red","green","blue"], "default" : "red"}
                    ]
    
                    When using multiple dropdown lists, output will be in the form:
                    <title> : <value>
                    <title> index : <index_value>
    
        --\(dialogargs.textField.long) <text>(,required,secure,prompt="<text>")
                    Present a textfield with the specified label
                    When Dialog exits the contents of the textfield will be presented as <text> : <user_input>
                    in plain or as json using [-\(dialogargs.jsonOutPut.short), --\(dialogargs.jsonOutPut.long)] option
                    Multiple textfields can be specified as required.
    
                    Modifiers available to text fields are:
                        secure   - Presends a secure input area. Contents of the textfield will not be shown on screen
                        required - Dialog will not exit until the field is populated
                        prompt   - Pre-fill the field with some prompt text (prompt text will not be returned, macOS 12+ only, macOS 11 safe)
    
                    modifiers can be combined e.g. --\(dialogargs.textField.long) <text>,secure,required
                                               or  --\(dialogargs.textField.long) <text>,required,prompt="<text>"
                    (secure fields cannot have the prompt modifier applied)
    
        --\(dialogargs.checkbox.long) <text>
                    Present a checkbox with the specified label
                    When Dialog exits the status of the checkbox will be presented as <text> : [true|false]
                    in plain or as json using [-\(dialogargs.jsonOutPut.short), --\(dialogargs.jsonOutPut.long)] option
                    Multiple checkboxes can be specified as required.
    
        --\(dialogargs.listItem.long) <text>
                    Creates a list item with the specified text as the item title.
                    Multiple items can be added by specifying --\(dialogargs.listItem.long) multiple times
    
                    Alternatly, specify a list item with either of the follwoing JSON formats:
                    Simple:
                    {
                      "listitem" : ["Item One", "Item Two", "Item Three", "Item Four", "Item Five"]
                    }
    
                    Advanced:
                    {
                      "listitem" : [
                        {"title" : "<text>", "status" : "<status>", "statustext" : "<text>"},
                        {"title" : "<text>", "status" : "<status>", "statustext" : "<text>"}
                      ]
                    }
                    
                    <status> can be one of "wait", "success", "fail", "error" or "pending"
                    and will display an apropriate icon in the status area.
    
                    Updates to items in the list can be sent to the command file specified by --\(dialogargs.statusLogFile.long):
                    Clear an existing list:
                        list: clear
                    Create a new list:
                        list: <csv>
                    Update a list item (simple):
                        listitem: <title>: [<text>|<status>]
                    Update a list item (advanced):
                        listitem: [title: <title>|index: <index>], status: <status>, statustext: <text>
                    
                    <index> starts at 0
    
        -\(dialogargs.watermarkImage.short), --\(dialogargs.watermarkImage.long) <file>
                    Displays the selected file as a background image.
                    If the image is larger than the default dialog size (820x380) and no window size options are given (specifically window height),
                    the dialog window height will be adjusted so the image fills the entire window width, 820 by default or if specified using --\(dialogargs.windowWidth.long)
    
        -\(dialogargs.watermarkAlpha.short), --\(dialogargs.watermarkAlpha.long) <number>
                    Number between 0 and 1
                    0 is fully transparant
                    1 is fully opaque
                    Default is 0.5
                    
        -\(dialogargs.watermarkPosition.short), --\(dialogargs.watermarkPosition.long) [topleft | left | bottomleft | top | center/cetre | bottom | topright | right | bottomright]
                    Positions the background image in the window.
                    Default is center
    
        -\(dialogargs.watermarkFill.short), --\(dialogargs.watermarkFill.long) [fill | fit]
                    fill - resizes the image to fill the entire window. Image will be truncated if necessary
                    fit  - resizes the image to fit the window but will not truncate
                    Default is none which will display the image at its native resolution
    
    
        --\(dialogargs.windowWidth.long) <number>
                    Sets the width of the dialog window to the specified width in points
    
        --\(dialogargs.windowHeight.long) <number>
                    Sets the height of the dialog window to the specified height in points
    
        --\(dialogargs.position.long) [topleft | left | bottomleft | top | center/centre | bottom | topright | right | bottomright]
                    Poitions the dialog window a the the defined location on the screen
    
        --\(dialogargs.timerBar.long) (<seconds>)
                    Replaces default button with a timer countdown after which dialog will close with exit code 4
                    Default timer value is 10 seconds
                    Optional value <seconds> can be specified to the desired value
    
                    If used in conjuction with --\(dialogargs.button1TextOption.long) the default button
                    will be displayed but will be disabled for the first 3 seconds of the timer, after which it
                    becomes active and can be used to dismiss dialog with the standard button 1 exit code of 0
    
        --\(dialogargs.hideTimerBar.long)
                    Will hide the timer bar. Dialog will close after time specified by --\(dialogargs.timerBar.long)
                    Default OK button is displayed. This is to prevent persistant or unclosable dialogs of unknown duration.
    
        -\(dialogargs.lockWindow.short), --\(dialogargs.lockWindow.long)
                    Let window me moved around the screen. Default is not moveable

        -\(dialogargs.forceOnTop.short), --\(dialogargs.forceOnTop.long)
                    Make the window appear above all other windows even when not active

        -\(dialogargs.bigWindow.short), --\(dialogargs.bigWindow.long)
                    Makes the dialog 25% bigger than normal. More room for message text

        -\(dialogargs.smallWindow.short), --\(dialogargs.smallWindow.long)
                    Makes the dialog 25% smaller. Less room for message text.
    
        -\(dialogargs.jsonOutPut.short), --\(dialogargs.jsonOutPut.long)
                    Outputs any results in json format for easier processing
                    (for dropdown item selections and textfield responses)
    
        --\(dialogargs.jsonFile.long) <file>
                    Use JSON formatted data file as input instead of command line paramaters
    
                    Uses the same naming convention as the long form command line options
                    e.g.
                    {
                        "\(dialogargs.titleOption.long)" : "Title here",
                        "\(dialogargs.messageOption.long)" : "Message here"
                    }
    
                    "\(dialogargs.mainImage.long)" and "\(dialogargs.checkbox.long)" can accept an array of multiple values
                    e.g.
                    {
                        "checkbox" : [{
                            "label" : "Option 1",
                            "checked" : true,
                            "disabled" : true
                        },
                        ...]
                        "image": [{
                            "imagename": "<image>",
                            "caption": "<caption>"
                        },
                        ...]
                    }
    
                    "\(dialogargs.textField.long)" can specify multiple valuse as a simple array:
                    e.g.
                    {
                        "textfield": ["Text Entry 1", "Text Entry 2", "Text Entry 3"]
                    }
    
        --\(dialogargs.jsonString.long) <text>
                    Same data format as --\(dialogargs.jsonFile.long) but passed in as a string on the command line without
                    requiring an intermediate file.
                    

        -\(dialogargs.ignoreDND.short), --\(dialogargs.ignoreDND.long)
                    Will ignore user Do Not Disturb setting
                        (Do Not Disturb detection only works in macOS 11)
    
    
        -\(dialogargs.jamfHelperMode.short), --\(dialogargs.jamfHelperMode.long)
                    Switches all command line options to accept jamfHelper style options
                    Useful for using as a drop in replacement for jamfHelper in existing scripts
                        replace "/path/to/jamfHelper" with \"/path/to/dialog -\(dialogargs.jamfHelperMode.short)\"
                    Does not (yet) support the following:
                        -windowType hud
                        -showDelayOptions
                        -alignDescription, -alignHeading, -alignCountdown
                        -iconSize
                    Dialog will do its best to display jamfHelper content in a dialog-esque way.
                    Any unsupported display options will be ignored.
                        
        -\(dialogargs.getVersion.short), --\(dialogargs.getVersion.long)
                    Prints the app version

        -\(dialogargs.showLicense.short), --\(dialogargs.showLicense.long)
                    Display the Software License Agreement for Dialog

        --\(dialogargs.helpOption.long)
                    Prints this text
    """
