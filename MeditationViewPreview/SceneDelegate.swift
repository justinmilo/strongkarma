//
//  SceneDelegate.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/4/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import UIKit
import SwiftUI

import ComposableArchitecture
import SwiftUI
import MeditationViewFeature
import ComposableArchitecture
import ComposableUserNotifications

private let store = Store(initialState: MediationViewState(),
                          reducer: mediationReducer.debug(),
                          environment: MediationViewEnvironment(
                            remoteClient: .randomDelayed,
                            userNotificationClient: UserNotificationClient.live,
                            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                            now: Date.init,
                            uuid: UUID.init)
)


@main
struct FSApp: App {
  @UIApplicationDelegateAdaptor var delegate: AppDelegate

  var body: some Scene {
    WindowGroup {
        MeditationView(store: store)
    }
  }
}

class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    ViewStore(store).send(.didFinishLaunching(notification: launchOptions?.notification))
    return true
  }

  func application(_ application: UIApplication,
                   didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    let notification = BackgroundNotification(
      appState: application.applicationState,
      content: BackgroundNotification.Content(userInfo: userInfo),
      fetchCompletionHandler: completionHandler
    )
    ViewStore(store).send(.didReceiveBackgroundNotification(notification))
  }
}

extension RemoteClient {
  static let randomDelayed = RemoteClient(
    fetchRemoteCount: {
      Effect(value: Int.random(in: 0...10))
        .delay(for: 2, scheduler: DispatchQueue.main)
        .eraseToEffect()
    }
  )
}

private extension Dictionary where Key == UIApplication.LaunchOptionsKey, Value == Any {
  var notification: UserNotification? {
    self[.remoteNotification]
      .flatMap { $0 as? [AnyHashable: Any] }
      .flatMap(UserNotification.init)
  }
}
