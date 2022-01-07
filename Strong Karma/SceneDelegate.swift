//
//  SceneDelegate.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/4/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import UIKit
import SwiftUI
import ListViewFeature
import ComposableArchitecture

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    if let windowScene = scene as? UIWindowScene {
      
        let window = UIWindow(windowScene: windowScene)
      
      //NotificationHelper.singleton.store = store
      window.rootViewController = UIHostingController(
        rootView: ListView(store: store.scope(state:\.listViewState, action:AppAction.listAction))
      )
        self.window = window
        window.makeKeyAndVisible()
    }
  }
}

