//
//  CarPlaySceneDelegate.swift
//  RadioCarPlay
//
//  Created by Daniel Abrahams on 14/09/2022.
//

import Foundation
import CarPlay
import AVFoundation
import CoreData

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    var interfaceController: CPInterfaceController?
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var timer: Timer?
    var radioItems: [CPListItem] = []
    var currentlyPlayingItem: CPListItem?
    
    let persistenceController = PersistenceController.shared
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {
        
        // Store a reference to the interface controller so
        // you can add and remove templates as the user
        // interacts with your app.
        self.interfaceController = interfaceController
        
        // Create a template and set it as the root.
        let rootTemplate = self.makeRootTemplate()
        interfaceController.setRootTemplate(rootTemplate, animated: true,
                                            completion: nil)
    }
    
    func makeRootTemplate() -> CPTemplate {
        
        let request = NSFetchRequest<Radio>(entityName: "Radio")
        let radios = try! persistenceController.container.viewContext.fetch(request)
        
        for radio in radios {
            
            let testRadio = CPListItem(text: radio.title, detailText: radio.subTitle, image: UIImage(systemName: "questionmark")!)
            DispatchQueue.global().async {
                if let imgUrl = radio.imgUrl {
                    let data = try? Data(contentsOf: imgUrl)
                    DispatchQueue.main.async {
                        testRadio.setImage(UIImage(data: data!))
                    }
                }
            }
            testRadio.userInfo = ["url": radio.url]
            testRadio.handler = { [weak self] item, completion in
                self!.radioClickedHandler(item: item, completion: completion)
            }
            self.radioItems.append(testRadio)
        }
        
        let section = CPListSection(items: self.radioItems)
        let radioList = CPListTemplate(title: "Radios", sections: [section])
        
        return radioList
    }
    
    func radioClickedHandler(item: CPSelectableListItem, completion: () -> Void) {
        if self.player != nil {
            if let radio: CPListItem = item as? CPListItem {
                if radio == self.currentlyPlayingItem {
                    self.player?.pause()
                    self.player = nil
                    radio.setAccessoryImage(nil)
                } else {
                    self.currentlyPlayingItem?.setAccessoryImage(nil)
                    self.player?.pause()
                    self.player = nil
                    
                    if let userInfo = item.userInfo as? [String: URL] {
                        self.playerItem = AVPlayerItem(url: userInfo["url"]!)
                        self.player = AVPlayer(playerItem: self.playerItem)
                        self.player?.play()
                        if let radio: CPListItem = item as? CPListItem {
                            radio.setAccessoryImage(UIImage(systemName: "speaker.wave.3")!)
                            self.currentlyPlayingItem = radio
                        }
                    } else {
                        let alert = CPAlertTemplate(titleVariants: ["Error"], actions: [CPAlertAction(title: "Radio station invalid", style: .destructive, handler: {_ in self.interfaceController?.dismissTemplate(animated: true, completion: nil)})])
                        self.interfaceController?.presentTemplate(alert, animated: true, completion: nil)
                        
                    }
                }
            }
            
        } else {
            if let userInfo = item.userInfo as? [String: URL] {
                self.playerItem = AVPlayerItem(url: userInfo["url"]!)
                self.player = AVPlayer(playerItem: self.playerItem)
                self.player?.play()
                if let radio: CPListItem = item as? CPListItem {
                    radio.setAccessoryImage(UIImage(systemName: "speaker.wave.3")!)
                    self.currentlyPlayingItem = radio
                }
            } else {
                let alert = CPAlertTemplate(titleVariants: ["Error"], actions: [CPAlertAction(title: "Radio station invalid", style: .destructive, handler: {_ in self.interfaceController?.dismissTemplate(animated: true, completion: nil)})])
                self.interfaceController?.presentTemplate(alert, animated: true, completion: nil)
                
            }
            
        }
        
        completion()
    }
    
}
