//
//  CaoruselView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 25.01.2022.
//

import SwiftUI

struct CarouselView: View {
    @State var selection: Int = 1
    @State var timerAdded = false
    let maxCount = 8
    
    var body: some View {
        TabView(selection: $selection) {
            ForEach(1..<maxCount) {count in
            Image("dog\(count)")
                .resizable()
                .scaledToFill()
                .tag(count)
            }
            
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 300)
        .animation(.default)
        .onAppear {
            if !timerAdded {
                addTimer()
            }
        }
    }
    private func addTimer() {
        timerAdded = true
        let timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { timer in
            
            if selection == (maxCount - 1) {
                selection = 1
            } else {
                selection += 1
            }
        }
        timer.fire()
    }
}

struct CaoruselView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselView()
            .previewLayout(.sizeThatFits)
    }
}
