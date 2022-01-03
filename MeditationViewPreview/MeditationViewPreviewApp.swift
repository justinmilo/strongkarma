//
//  MeditationViewPreviewApp.swift
//  MeditationViewPreview
//
//  Created by Justin Smith on 1/2/22.
//  Copyright © 2022 Justin Smith. All rights reserved.
//

import SwiftUI
import MeditationViewFeature
import ComposableArchitecture

@main
struct MeditationViewPreviewApp: App {
    var body: some Scene {
        WindowGroup {
            MeditationView(
                store: Store(initialState: MediationViewState(),
                             reducer: mediationReducer,
                             environment: MediationViewEnvironment)
        }
    }
}
