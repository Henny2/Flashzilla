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
    var body: some View {
        //background behind cards
        ZStack{
            Image("background")
                .resizable()
                .ignoresSafeArea()
            // timer above cards
            VStack{
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
        }
    }
    func removeCard(at index: Int){
        cards.remove(at: index)
    }
}

#Preview {
    ContentView()
}
