//
//  AppDelegate.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/4/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import UIKit
import ComposableArchitecture
import MeditationViewFeature
import ComposableUserNotifications
import ListViewFeature

let store : Store<AppState, AppAction>  = Store(
  initialState: AppState(
      listViewState: ListViewState(
        meditations: IdentifiedArray(FileClient.live.load()),
          addEntryPopover: false,
          meditationView: nil,
          collapsed: true,
          newMeditation: nil,
          addMeditationVisible: false)),
  reducer: appReducer.debug(),
  environment:  AppEnvironment(
      listEnv: ListEnv(
        file: FileClient.live, uuid: UUID.init, now: Date.init,
          medEnv: MediationViewEnvironment(
            remoteClient: .randomDelayed,
            userNotificationClient: UserNotificationClient.live,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            now: Date.init,
            uuid: UUID.init)
      )
  )
)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        ViewStore(store).send(.didFinishLaunching(notification: launchOptions?.notification))
      return true
    }
  
  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }

}

private extension Dictionary where Key == UIApplication.LaunchOptionsKey, Value == Any {
  var notification: UserNotification? {
    self[.remoteNotification]
      .flatMap { $0 as? [AnyHashable: Any] }
      .flatMap(UserNotification.init)
  }
}
