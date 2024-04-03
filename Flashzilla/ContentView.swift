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
    @State private var cards = Array<Card>(repeating: .example, count: 10)
    
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() // a timer that fires every second
    
    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true // combining the scenePhase info with the info whether there are still cards to work thru
    
    var body: some View {
        //background behind cards
        ZStack{
            Image("background")
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
                    }
                }
            }
            if accessibilityDifferentiateWithoutColor {
                VStack{
                    Spacer()
                    HStack{
                        Image(systemName: "xmark.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(.circle)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle")
                            .padding()
                            .background(.black.opacity(0.7))
                            .clipShape(.circle)
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
                isActive = true
            }
            else{
                isActive = false
            }
        }
    }
    func removeCard(at index: Int){
        cards.remove(at: index)
    }
}

#Preview {
    ContentView()
}
