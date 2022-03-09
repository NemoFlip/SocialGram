//
//  LazyView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 20.02.2022.
//

import Foundation
import SwiftUI

struct LazyView<Content: View>: View {
    var content: () -> Content
    
    var body: some View {
        self.content()
    }
}
