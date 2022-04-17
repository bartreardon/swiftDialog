//
//  ContentView.swift
//  dialog
//
//  Created by Bart Reardon on 9/3/21.
//

import SwiftUI
import Cocoa

struct ContentView: View {

    var bannerAdjustment       = CGFloat(5)
    var waterMarkFill          = String("")
    var progressSteps : CGFloat = appvars.timerDefaultSeconds
    
    //@ObservedObject var observedDialogContent = DialogUpdatableContent()
    @ObservedObject var observedDialogContent : DialogUpdatableContent
    
    init (observedDialogContent : DialogUpdatableContent) {
        self.observedDialogContent = observedDialogContent
        if dialogargs.timerBar.present {
            progressSteps = string2float(string: dialogargs.timerBar.value)
        }
    }
//
//    // set up timer to read data from temp file
//    let updateTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect() // tick every 1 second
//
    var body: some View {
                        
        ZStack {            
            if dialogargs.watermarkImage.present {
                    watermarkView(imagePath: dialogargs.watermarkImage.value, opacity: Double(dialogargs.watermarkAlpha.value), position: dialogargs.watermarkPosition.value, scale: dialogargs.watermarkFill.value)
            }
        
            // this stack controls the main view. Consists of a VStack containing all the content, and a HStack positioned at the bottom of the display area
            VStack {
                if dialogargs.bannerImage.present {
                    BannerImageView(imagePath: dialogargs.bannerImage.value)
                        .border(appvars.debugBorderColour, width: 2)
                }

                if observedDialogContent.titleText != "none" {
                    // Dialog title
                    TitleView(observedDialogContent: observedDialogContent)
                        .border(appvars.debugBorderColour, width: 2)
                        .offset(y: 10) // shift the title down a notch
                    
                    // Horozontal Line
                    Divider()
                        .frame(width: appvars.windowWidth*appvars.horozontalLineScale, height: 2)
                }
                
                if dialogargs.video.present {
                    VideoView(videourl: dialogargs.video.value, autoplay: dialogargs.autoPlay.present, caption: dialogargs.videoCaption.value)
                } else {
                    DialogView(observedDialogContent: observedDialogContent)
                }
                
                Spacer()
                
                // Buttons
                HStack() {
                    if dialogargs.infoButtonOption.present || dialogargs.buttonInfoTextOption.present {
                        MoreInfoButton()
                        if !dialogargs.timerBar.present {
                            Spacer()
                        }
                    }
                    if dialogargs.timerBar.present {
                        timerBarView(progressSteps: progressSteps, visible: !dialogargs.hideTimerBar.present, observedDialogContent : observedDialogContent)
                            .frame(alignment: .bottom)
                    }
                    if (dialogargs.timerBar.present && dialogargs.button1TextOption.present) || !dialogargs.timerBar.present || dialogargs.hideTimerBar.present  {
                        ButtonView(observedDialogContent: observedDialogContent) // contains both button 1 and button 2
                    }
                }
                //.frame(alignment: .bottom)
                .padding(.leading, 15)
                .padding(.trailing, 15)
                .padding(.bottom, 15)
                .border(appvars.debugBorderColour, width: 2)
            }
        
        }
        .edgesIgnoringSafeArea(.all)
        .hostingWindowPosition(vertical: appvars.windowPositionVertical, horizontal: appvars.windowPositionHorozontal)

         
    }
    

}

