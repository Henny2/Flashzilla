//
//  ContentView.swift
//  Flashzilla
//
//  Created by Henrieke Baunack on 3/9/24.
//

import SwiftUI

extension View {
    // total: total card count
    // position: position in the stack
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total-position)
        // 10 points down per card in the stack
        return self.offset(y: offset * 10)
    }
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor  // for red green blindness
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    @State private var cards = Array<Card>(repeating: .example, count: 10)
    
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() // a timer that fires every second
    
    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true // combining the scenePhase info with the info whether there are still cards to work thru
    
    var body: some View {
        //background behind cards
        ZStack{
            Image(decorative: "background") // adding decorative for accessibility
                .resizable()
                .ignoresSafeArea()
            // timer above cards
            VStack{
                Text("Time is \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(.capsule)
                // cards above each other
                ZStack{
                    ForEach(0..<cards.count, id:\.self) { index in
                        CardView(card: cards[index]){
                            withAnimation {
                                removeCard(at: index)
                            }
                        }
                            .stacked(at: index, in: cards.count)
                            .allowsHitTesting(index == cards.count-1) // only allow the top most card to be dragged
                            .accessibilityHidden(index < cards.count-1) //hide card from voice over
                    }
                }
                .allowsHitTesting(timeRemaining > 0) //only allowing interactivy when there is still time remaining
                if cards.isEmpty {
                    Button("Start again", action:resetCards)
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(.capsule)
                }
            }
            // showing buttons for voice over as well
            if accessibilityDifferentiateWithoutColor || accessibilityVoiceOverEnabled {
                VStack{
                    Spacer()
                    HStack{
                        Button{
                            withAnimation {
                                removeCard(at: cards.count-1)
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                        }
                        .accessibilityLabel("Wrong")
                        .accessibilityHint("Mark you answer as wrong")
                        Spacer()
                        
                        Button{
                            withAnimation {
                                removeCard(at: cards.count-1)
                            }
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                        }
                        .accessibilityLabel("Correct")
                        .accessibilityHint("Mark you answer as correct")
                    }
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }.onReceive(timer) { time in
            guard isActive else {return} //making sure the timer pauses when the app goes into background
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                if cards.isEmpty == false { // make sure the timer does not restart when coming back from background when cards are empty
                    isActive = true
                }
            }
            else{
                isActive = false
            }
        }
    }
    func removeCard(at index: Int){
        guard index >= 0 else { return } // only run this function if there are cards to remove
        cards.remove(at: index)
        
        if cards.isEmpty {
            isActive = false
        }
    }
    func resetCards() {
        cards = Array<Card>(repeating: .example, count: 10)
        timeRemaining = 100
        isActive = true
    }
}

#Preview {
    ContentView()
}
