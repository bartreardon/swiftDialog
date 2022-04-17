//
//  TaskProgressView.swift
//  dialog
//
//  Created by Bart Reardon on 20/1/2022.
//

import SwiftUI

struct TaskProgressView: View {
    
    @ObservedObject var observedDialogContent : DialogUpdatableContent
    
    var body: some View {
        if dialogargs.progressBar.present {
            VStack {
                ProgressView(value: observedDialogContent.progressValue, total: observedDialogContent.progressTotal)
                    .padding(.leading,40)
                    .padding(.trailing,40)
                Text(observedDialogContent.statusText)

            }
        }
    }
}


