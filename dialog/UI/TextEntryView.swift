//
//  TextEntryView.swift
//  dialog
//
//  Created by Reardon, Bart  on 23/7/21.
//

import SwiftUI

struct TextEntryView: View {
    
    @ObservedObject var observedDialogContent : DialogUpdatableContent
    
    @State var textFieldValue = Array(repeating: "", count: textFields.count)
    @State var datePickerValue = Array(repeating: Date(), count: textFields.count)
    //var textPromptValue = Array(repeating: "", count: textFields.count)
    
    @State private var animationAmount = 1.0
    
    var textFieldPresent: Bool = false
    var fieldwidth: CGFloat = 0
    var requiredFieldsPresent : Bool = false
    var dateComponentSelected : DatePickerComponents = .date
    
    init(observedDialogContent : DialogUpdatableContent) {
        self.observedDialogContent = observedDialogContent
        if cloptions.textField.present {
            textFieldPresent = true
            for i in 0..<textFields.count {
                datePickerValue.append(Date())
                //textFieldValue.append(" ")
                if textFields[i].required {
                    requiredFieldsPresent = true
                }
                //highlight.append(Color.clear)
            }
        }
        if cloptions.hideIcon.present {
            fieldwidth = appvars.windowWidth
        } else {
            fieldwidth = appvars.windowWidth - appvars.iconWidth
        }
    }
    
    var body: some View {
        if textFieldPresent {
            VStack {
                ForEach(0..<textFields.count, id: \.self) {index in
                    HStack {
                        Spacer()
                        Text(textFields[index].title + (textFields[index].required ? " *":""))
                            .bold()
                            .font(.system(size: 15))
                            .frame(idealWidth: fieldwidth*0.20, maxWidth: 150, alignment: .leading)
                        Spacer()
                            .frame(width: 20)
                        HStack {
                            if textFields[index].secure {
                                ZStack() {
                                    SecureField("", text: $textFieldValue[index])
                                        .disableAutocorrection(true)
                                        .textContentType(.password)
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(stringToColour("#008815")).opacity(0.5)
                                            .frame(idealWidth: fieldwidth*0.50, maxWidth: 300, alignment: .trailing)
                                }
                            } else {
                                if #available(macOS 12.0, *) {
                                    TextField("", text: $textFieldValue[index], prompt:Text(textFields[index].prompt))
                                } else {
                                    TextField("", text: $textFieldValue[index])
                                }
                                if textFields[index].date || textFields[index].time {
                                    DatePicker("", selection: $datePickerValue[index], displayedComponents: dateComponentSelected)
                                    .frame(width: 100)
                                    .onChange(of: datePickerValue[index], perform: { value in
                                        //textFields[index].value = value.formatted(date: .numeric, time: .numeric)
                                        //print(datePickerValue[index])
                                    })
                                }
                            }
                        }
                        .frame(idealWidth: fieldwidth*0.50, maxWidth: 300, alignment: .trailing)
                        .onChange(of: textFieldValue[index], perform: { value in
                            //update appvars with the text that was entered. this will be printed to stdout on exit
                            textFields[index].value = textFieldValue[index]
                        })
                        .overlay(RoundedRectangle(cornerRadius: 5)
                                    .stroke(observedDialogContent.requiredTextfieldHighlight[index], lineWidth: 2)
                                    .animation(.easeIn(duration: 0.2)
                                                .repeatCount(3, autoreverses: true)
                                               )
                                 )
                        Spacer()
                    }
                }
                if requiredFieldsPresent {
                    HStack {
                        Spacer()
                        Text("* Required Fields")
                            .font(.system(size: 10)
                                    .weight(.light))
                            .padding(.trailing, 10)
                    }
                }
            }
        }
    }
}


