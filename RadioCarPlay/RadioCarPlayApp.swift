//
//  RadioCarPlayApp.swift
//  RadioCarPlay
//
//  Created by Daniel Abrahams on 14/09/2022.
//

import SwiftUI

@main
struct RadioCarPlayApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
