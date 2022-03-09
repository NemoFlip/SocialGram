//
//  LIkeAnimationView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 05.02.2022.
//

import SwiftUI

struct LIkeAnimationView: View {
    @Binding var animate: Bool
    var body: some View {
        ZStack {
            Image(systemName: "suit.heart.fill")
                .foregroundColor(.white)
                .font(.system(size: 100))
                .opacity(animate ? 1 : 0)
                .scaleEffect(animate ? 1 : 0)
        }.animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 1))
    }
}

struct LIkeAnimationView_Previews: PreviewProvider {
    @State static var animate = false
    static var previews: some View {
        LIkeAnimationView(animate: $animate)
            .previewLayout(.sizeThatFits)
    }
}
