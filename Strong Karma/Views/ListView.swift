//
//  ContentView.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/4/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import AVFoundation
import Models

struct ListViewState: Equatable {
    var meditations : IdentifiedArrayOf<Meditation>
    var meditationsReversed: IdentifiedArrayOf<Meditation> {
      IdentifiedArrayOf<Meditation>( self.meditations.reversed() )
    }
    var addEntryPopover : Bool
    var meditationView: MediationViewState?
    var collapsed: Bool
  var newMeditation : Meditation?
  var addMeditationVisible: Bool
    var timerBottomState: TimerBottomState?{
        get{
            guard let meditationView = self.meditationView else { return nil }
            
            return TimerBottomState(timerData: meditationView.timerData, timedMeditation: meditationView.timedMeditation, enabled: true)
            }
        set{
            if let newValue = newValue {
                self.meditationView!.timerData = newValue.timerData
                self.meditationView!.timedMeditation = newValue.timedMeditation
            }
        }
    }
}

enum ListAction: Equatable{
    case addButtonTapped
    case addMeditationDismissed
    case deleteMeditationAt(IndexSet)
    case dismissEditEntryView
    case edit(id: UUID, action: EditAction)
    case editNew(EditAction)
    case meditation(MediationViewAction)
    case presentTimedMeditationButtonTapped
    case saveData
    case timerBottom(TimerBottomAction)
}

struct ListEnv{
    var file = FileIO()
    var uuid : ()->UUID
    var now : ()->Date
    var medEnv: MediationViewEnvironment
}

let listReducer = Reducer<ListViewState, ListAction, ListEnv>.combine(
    todoReducer.forEach(state: \.meditations, action: /ListAction.edit(id:action:), environment: { _ in EditEnvironment()}),
    mediationReducer.optional.pullback(state: \.meditationView, action: /ListAction.meditation, environment: \ListEnv.medEnv),
    Reducer{ state, action, environment in
        switch action {
        case .addButtonTapped:
            state.addMeditationVisible = true
            let med = Meditation(id: environment.uuid(),
                                 date: environment.now().description,
                                 duration: 300,
                                 entry: "",
                                 title: "Untitled")
            state.newMeditation = med
            return .none
            
        case .addMeditationDismissed:
            let transfer = state.newMeditation!
            state.newMeditation = nil
            state.meditations.removeOrAdd(meditation: transfer)
            state.addMeditationVisible = false
            
            return Effect(value: .saveData)
            
        case .deleteMeditationAt(let indexSet):
            // Set comes in reversed
            let reversedSet : IndexSet = IndexSet(indexSet.reversed())
            state.meditations.remove(atOffsets: reversedSet)
            
             return .none
            
        case .dismissEditEntryView:
            state.collapsed = true
            return Effect(value: .saveData)
            
        case .edit(id: _, action: _):
            return .none
            
        case .editNew(.didEditText(let string)):
            state.newMeditation!.entry = string
            return .none

        case .editNew(.didEditTitle(let string)):
            state.newMeditation!.title = string
            return .none
            
        case .meditation(.timerFinished):
            let tempMed = state.meditationView!.timedMeditation!
            state.meditationView!.timedMeditation = nil
            state.meditations.removeOrAdd(meditation: tempMed)
            
            return .none
            
        case .meditation(_):
            return .none

        case .presentTimedMeditationButtonTapped:
              state.collapsed = false
              state.meditationView = MediationViewState()
            return .none
            
        case .saveData:
            let meds = state.meditations
            
            return
              Effect.fireAndForget {
                 environment.file.save(Array(meds))
            }
        case .timerBottom(.buttonPressed):
            state.collapsed = false
            return .none
        }
    }
)


struct ListView : View {

  var store: Store<ListViewState, ListAction>
  @State private var timerGoing = true
  
  var body: some View {
   WithViewStore(self.store) { viewStore in
      VStack {
          NavigationView {
            List {
               ForEachStore( self.store.scope(
                  state: { $0.meditations },
                  action: ListAction.edit(id:action:)) )
               { meditationStore in
                     NavigationLink(destination:
                        EditEntryView.init(store:meditationStore)
                           .onDisappear {
                              viewStore.send(.saveData)
                        }){
                        ListItemView(store: meditationStore)
                     }
                  
              }
               .onDelete { (indexSet) in
                  viewStore.send(.deleteMeditationAt(indexSet))
               }
               
              Text("Welcome the arrising, see it, let it through")
                .lineLimit(3)
                .padding()
            }
            .navigationBarTitle(Text("Strong Karma"))
            .navigationBarItems(trailing:
              Button(action: {
                viewStore.send(.addButtonTapped)
              }){
              Circle()
                .frame(width: 33.0, height: 33.0, alignment: .center)
                .foregroundColor(.secondary)
            })
          }
          
          if (viewStore.collapsed){
              IfLetStore(
                self.store.scope(
                    state: { $0.timerBottomState },
                    action: ListAction.timerBottom),
                then: { newStore in
                    TimerBottom(store: newStore)
                },
                else:
                    Button(action: {
                        viewStore.send(ListAction.presentTimedMeditationButtonTapped)
                    }){
                        Circle()
                            .frame(width: 44.0, height: 44.0, alignment: .center)
                            .foregroundColor(.secondary)
                    }
              )
          } else {
             
          }
//
        Text("")
          .hidden()
          .sheet(
            isPresented: viewStore.binding(
              get:  { !$0.collapsed },
              send:  { _ in ListAction.dismissEditEntryView }
            )
          ) {
              IfLetStore(
                self.store.scope(
                    state: { $0.meditationView },
                    action: ListAction.meditation),
                then: { newStore in
                    MeditationView(store: newStore)
                }
              )
          }
//
        Text("")
          .hidden()
          .sheet(
            isPresented: viewStore.binding(
              get:  { $0.addMeditationVisible },
              send:  { _ in

                print("isPresented send")

                return ListAction.addMeditationDismissed

              }
            )
          ) {
            IfLetStore( self.store.scope(
                          state: {_ in viewStore.newMeditation },
                          action: { return ListAction.editNew($0)}),
                        then: { store in
                          EditEntryView.init(store: store)
                        },
                        else: Text("Nothing here")
            )

      }
      .edgesIgnoringSafeArea(.bottom)
   }
  }
}
}






