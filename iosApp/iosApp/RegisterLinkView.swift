//
//  RegisterLinkView.swift
//  iosApp
//
//  Created by Ilija Neskovic on 2.8.25..
//

import SwiftUICore
import SwiftUI


struct RegisterLinkView: View {
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(.secondary)
            
            Button("Sign Up", action: action)
                .fontWeight(.medium)
                .foregroundColor(.accentColor)
        }
        .font(.subheadline)
        .padding(.top, 20)
    }
}
