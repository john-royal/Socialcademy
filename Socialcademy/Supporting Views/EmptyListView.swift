//
//  EmptyListView.swift
//  Socialcademy
//
//  Created by John Royal on 11/1/21.
//

import SwiftUI

struct EmptyListView: View {
    let title: String
    let message: String
    var action: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text(message)
                .padding(.bottom)
            if let action = action {
                Button(action: action) {
                    Text("Try Again")
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary))
                }
            }
        }
        .font(.subheadline)
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
    }
}

struct EmptyListView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyListView(
            title: "Cannot Load Posts",
            message: "Missing or insufficient permissions.",
            action: {}
        )
        EmptyListView(
            title: "No Posts",
            message: "There aren’t any posts yet."
        )
    }
}
