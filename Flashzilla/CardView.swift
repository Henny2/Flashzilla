//
//  CardView.swift
//  Flashzilla
//
//  Created by Henrieke Baunack on 3/31/24.
//

import SwiftUI
// in General tab of Project we disallowed portrait mode
struct CardView: View {
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor  // for red green blindness
    let card: Card
    var removal: (() -> Void)? = nil
    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero // no drag by default
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                .fill(
                    accessibilityDifferentiateWithoutColor
                    ? .white
                    :.white
                    .opacity(1 - Double(abs(offset.width/50.0))))
                .background(
                    accessibilityDifferentiateWithoutColor
                    ? nil
                    : RoundedRectangle(cornerRadius: 25)
                        .fill(offset.width>0 ? .green : .red)) // is postive when dragged to the right, negative when dragged to the left
                .shadow(radius: 10)
            VStack{
                Text(card.prompt)
                    .font(.largeTitle)
                    .foregroundStyle(.black)
                if isShowingAnswer {
                    Text(card.answer)
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        // this frame size fits on all the iphone screens out there
        .frame(width:450, height:250)
        .rotationEffect(.degrees(offset.width/5.0))
        .offset(x:offset.width*5)
        .opacity(2-Double(abs(offset.width/50)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
                        removal?()
                    } else {
                        offset = .zero
                    }
                }
        )
        .onTapGesture {
            isShowingAnswer.toggle()
        }
    }
}

#Preview {
    CardView(card: Card.example)
}
