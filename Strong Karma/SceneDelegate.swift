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
import Foundation
import Models
import MeditationViewFeature
import ComposableUserNotifications
import Parsing



let deepLinker = PathComponent("one")
    .take(inventoryDeepLinker2)
    .map(AppRoute.one)
  .orElse(
    PathComponent("inventory")
      .take(inventoryDeepLinker)
      .map(AppRoute.inventory)
  )
  .orElse(
    PathComponent("three")
      .skip(PathEnd())
      .map { .three }
  )

struct AppState : Equatable {
    var listViewState: ListViewState
}

enum AppAction : Equatable {
    case listAction(ListAction)
    case didFinishLaunching(notification: UserNotification?)
    case userNotification(UserNotificationClient.Action)
    case requestAuthorizationResponse(Result<Bool, UserNotificationClient.Error>)
    case open(URL)
}

struct AppEnvironment {
    var listEnv: ListEnv
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    listReducer.pullback(state: \.listViewState, action: /AppAction.listAction, environment: \AppEnvironment.listEnv),
    Reducer{ state, action, environment in
        
        switch action {
        case .listAction(_):
            return .none
        case .requestAuthorizationResponse:
            return .none
        case .didFinishLaunching(notification: let notification):
            
            return .merge(
                environment.listEnv.medEnv.userNotificationClient
                    .delegate()
                    .map(AppAction.userNotification),
                environment.listEnv.medEnv.userNotificationClient.requestAuthorization([.alert, .badge, .sound])
                    .catchToEffect()
                    .map(AppAction.requestAuthorizationResponse)
            )
        case let .userNotification(.didReceiveResponse(response, completion)):
            let notification = UserNotification(userInfo: response.notification.request.content.userInfo())
            
            return .fireAndForget(completion)
        case .userNotification(.willPresentNotification(_, completion: let completion)):
            return .fireAndForget {
                completion([.list, .banner, .sound])
            }
        case .userNotification(.openSettingsForNotification(_)):
            return .none
        case .open(_):
            var request = DeepLinkRequest(url: url)
            if let route = deepLinker.parse(&request) {
              switch route {
              case let .one(inventoryRoute):
                self.selectedTab = .one
                  self.inventoryViewModel2.navigate(to: inventoryRoute)

              case let .inventory(inventoryRoute):
                self.selectedTab = .inventory
                self.inventoryViewModel.navigate(to: inventoryRoute)

              case .three:
                self.selectedTab = .three
              }
            }
        }
    }
)





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

