//
//  ContentView.swift
//  RadioCarPlay
//
//  Created by Daniel Abrahams on 14/09/2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Radio.title, ascending: true)],
        animation: .default)
    private var radios: FetchedResults<Radio>
    
    @State var addingNewRadioStation = false
    
    func fetchImage(url: URL) -> UIImage {
        return UIImage(data: try! Data(contentsOf: url)) ?? UIImage(systemName: "questionmark")!
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(radios) { radio in
                    NavigationLink {
                        EditRadioStation(radio: radio)
                    } label: {
                        HStack {
                            if let imgUrl = radio.imgUrl {
                                Image(uiImage: self.fetchImage(url: imgUrl))
                                    .resizable()
                                    .frame(width: 50.0, height: 50.0)
                            }
                            
                            Text(radio.title!)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {addingNewRadioStation = true}) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
                
        }.sheet(isPresented: $addingNewRadioStation, content: {AddNewRadioStationSheet()})
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { radios[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct AddNewRadioStationSheet: View {
    
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    @Environment(\.presentationMode) var presentationMode
    
    @State var url: String = ""
    @State var imgUrl: String = ""
    @State var title: String = ""
    @State var subTitle: String = ""
    
    private func addRadio() {
        withAnimation {
            if title != "" && url != "" {
                let newRadio = Radio(context: viewContext)
                newRadio.url = URL(string: url)
                newRadio.title = title
                if subTitle != "" {
                    newRadio.subTitle = subTitle
                }
                if imgUrl != "" {
                    newRadio.imgUrl = URL(string: imgUrl)
                }

                do {
                    try viewContext.save()
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
    
    var body: some View {
        VStack{
            Text("Add new radio station")
            TextField("Title", text: $title)
                .padding(5.0)
                .border(.black)
                .padding()
            TextField("Subtitle", text: $subTitle)
                .padding(5.0)
                .border(.black)
                .padding()
            TextField("Url", text: $url)
                .padding(5.0)
                .border(.black)
                .padding()
            TextField("Image url", text: $imgUrl)
                .padding(5.0)
                .border(.black)
                .padding()
            Button("Add radio", action: {
                addRadio()
            })
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(25.0)
            
        }
    }
}

struct EditRadioStation: View {
    
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    
    @ObservedObject var radio: Radio
    
    @State var url: String
    @State var imgUrl: String
    @State var title: String
    @State var subTitle: String
    
    init(radio: Radio) {
        
        self.url = radio.url!.absoluteString
        self.title = radio.title!
        if let imgurl = radio.imgUrl {
            self.imgUrl = imgurl.absoluteString
        } else {
            self.imgUrl = ""
        }
        if let subtitle = radio.subTitle {
            self.subTitle = subtitle
        } else {
            self.subTitle = ""
        }
        self.radio = radio
    }
    
    private func editRadio() {
        withAnimation {
            if title != "" && url != "" {
                
                radio.url = URL(string: url)
                radio.title = title
                if subTitle != "" {
                    radio.subTitle = subTitle
                }
                if imgUrl != "" {
                    radio.imgUrl = URL(string: imgUrl)
                }

                do {
                    try viewContext.save()
                    
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
    
    var body: some View {
        VStack{
            Text("Edit radio station")
            TextField("Title", text: $title)
                .padding(5.0)
                .border(.black)
                .padding()
            TextField("Subtitle", text: $subTitle)
                .padding(5.0)
                .border(.black)
                .padding()
            TextField("Url", text: $url)
                .padding(5.0)
                .border(.black)
                .padding()
            TextField("Image url", text: $imgUrl)
                .padding(5.0)
                .border(.black)
                .padding()
            Button("Edit radio", action: {
                editRadio()
            })
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(25.0)
            
        }
    }
}
