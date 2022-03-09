//
//  SettingsLabelView.swift
//  SocialGram
//
//  Created by Артем Хлопцев on 30.01.2022.
//

import SwiftUI
struct SettingsLabelView: View {
    var labelText: String
    var imageName: String
    var body: some View {
        VStack {
            HStack {
                Text(labelText)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: imageName)
            }
            Divider()
                .padding(.vertical, 4)
        }
    }
}

struct SettingsLabelView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsLabelView(labelText: "Label", imageName: "heart")
            .previewLayout(.sizeThatFits)
    }
}
