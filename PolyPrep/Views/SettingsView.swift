//
//  SettingsView.swift
//  PolyPrep
//
//  Created by Дмитрий Григорьев on 21.04.2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("BackEndURL") private var BackEndURL: String = APIConstants.baseURL
    @AppStorage("KeyCloakURL") private var KeyCloakURL: String = APIConstants.KeyCloakURL
    
    var body: some View {
        
        Form {
            HStack{
                Text("Backend URL:")
                TextField(text: $BackEndURL, prompt: Text("Required")) {
                    Text("IP")
                }
                .onSubmit {
                    UserDefaults.standard.set(BackEndURL, forKey: "BackEndURL")
                    APIConstants.baseURL = BackEndURL
                }
            }
            HStack{
                Text("KeyCloak URL:")
                TextField(text: $BackEndURL, prompt: Text("Required")) {
                    Text("IP")
                }
                .onSubmit {
                    UserDefaults.standard.set(KeyCloakURL, forKey: "KeyCloakURL")
                    APIConstants.KeyCloakURL = KeyCloakURL
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
