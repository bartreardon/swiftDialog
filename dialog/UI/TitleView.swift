//
//  TitleView.swift
//  Dialog
//
//  Created by Reardon, Bart  on 19/3/21.
//

import Foundation
import SwiftUI

struct TitleView: View {
    
    @ObservedObject var observedDialogContent : DialogUpdatableContent
    
    var TitleViewOption: String = dialogargs.titleOption.value// CLOptionText(OptionName: dialogargs.titleOption, DefaultValue: appvars.titleDefault)
    //var TitleViewOption: String
        
    var body: some View {
        if appvars.titleFontName == "" {
            //Text(TitleViewOption)
            Text(observedDialogContent.titleText)
                .font(.system(size: appvars.titleFontSize, weight: appvars.titleFontWeight))
                .foregroundColor(appvars.titleFontColour)
                .frame(width: appvars.windowWidth , height: appvars.titleHeight, alignment: .center)
        } else {
            Text(observedDialogContent.titleText)
                .font(.custom(appvars.titleFontName, size: appvars.titleFontSize))
                .foregroundColor(appvars.titleFontColour)
                .frame(width: appvars.windowWidth , height: appvars.titleHeight, alignment: .center)
        }
    }
}
