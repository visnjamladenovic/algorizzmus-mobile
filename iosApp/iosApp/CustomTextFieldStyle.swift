//
//  CustomTextFieldStyle.swift
//  iosApp
//
//  Created by Ilija Neskovic on 2.8.25..
//

import SwiftUI


struct CustomTextFieldStyle: TextFieldStyle {
    let isError: Bool
    
    init(isError: Bool = false) {
        self.isError = isError
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isError ? Color.orange : Color.gray.opacity(0.3), lineWidth: isError ? 2 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )
            )
    }
}
