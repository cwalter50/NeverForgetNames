//
//  ContentView.swift
//  NeverForgetNames
//
//  Created by Christopher Walter on 5/26/20.
//  Copyright © 2020 Christopher Walter. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var people: [Person] = [Person]()
    
    // For ImagePicker
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? // this is needed to get the image from UIimagePickerController because we have a Binding Property of uiimage...
    @State private var selectedPerson: Person? // this is used to pass to the EditView to update the person...
    
    // for the action sheet to enter name and details
    @State private var showingEditName = false
    
    // This will be used to get the location of where you met the new person.
    let locationFetcher = LocationFetcher()
    
    var body: some View {
        NavigationView {
            List {
                ForEach (people) { person in
                    HStack {
                        // display the image
                        Image(uiImage: person.uiImage!)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        VStack {
                            Text(person.name)
                                .font(.title)
                                .foregroundColor(.primary)
                            Text(person.details)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onTapGesture {
                        // update selected Person
                        self.selectedPerson = person
                        // present the edit name alert
                        self.showingEditName = true
                        
                    }
                }
                .onDelete(perform: removePerson)
                
            }
            .onAppear(perform: loadData)
            .navigationBarTitle("Never Forget Names")
            .navigationBarItems(leading: EditButton(), trailing: Button(action: {
                        // start the location Fetcher, so that we know where the picture was taken
                        self.locationFetcher.start()
                        self.showingImagePicker = true
                        print("should show ImagePicker")
        
                    }) {
                        Image(systemName: "plus")
                    })

            .sheet(isPresented: $showingImagePicker, onDismiss: addNewPerson) {
                ImagePicker(image: self.$inputImage)
            }

            
        }
        
        .sheet(isPresented: $showingEditName, onDismiss: saveData) {
            if self.selectedPerson != nil { // can't use if let, so we do this instead.
                EditView(person: self.selectedPerson!)
            }
        }
    }
    
    func removePerson(at offsets: IndexSet) {
        people.remove(atOffsets: offsets)
        // override the last save, and update the people saved to Documents Directory
        saveData()
    }
    
    func addNewPerson()
    {
        let newPerson = Person(uiImage: inputImage)
        // grab the location of the meeting
        if let location = self.locationFetcher.lastKnownLocation {
            newPerson.location = location
        } else {
            print("Your location is unknown")
        }
        
        selectedPerson = newPerson
        people.insert(newPerson, at: 0)
        showingEditName = true // this will trigger the sheet so that we can edit the name and details
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        print(paths[0])
        return paths[0]
    }
    
    func loadData() {
        print("loading")
        let filename = getDocumentsDirectory().appendingPathComponent("SavedPeople")

        do {
            let data = try Data(contentsOf: filename)
            people = try JSONDecoder().decode([Person].self, from: data).sorted()
            print("load successful")
        } catch {
            print(error)
            print("Unable to load saved data.")
        }
    }
    
    func saveData() {
        print("saving")
        do {
            let filename = getDocumentsDirectory().appendingPathComponent("SavedPeople")
            people = people.sorted()
            let data = try JSONEncoder().encode(self.people)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            print("save successful")
        } catch {
            print("Unable to save data.")
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {

//        ContentView(names: [Person(name: "Beth", id: UUID()), Person(name: "Doc", id: UUID())])
        ContentView()
    }
}
