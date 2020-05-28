//
//  EditView.swift
//  NeverForgetNames
//
//  Created by Christopher Walter on 5/27/20.
//  Copyright © 2020 Christopher Walter. All rights reserved.
//

import SwiftUI

struct EditView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var person: Person
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Enter Name", text: $person.name)
                    TextField("Details, ie where you met?, where you know them from?, etc", text: $person.details)
                }
                Section {
                    Image(uiImage: person.wrappedUIImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    
                }
            }
            .navigationBarTitle("Edit Person")
            .navigationBarItems(trailing: Button("Done") {
                self.presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        
        EditView(person: Person())
    }
}



