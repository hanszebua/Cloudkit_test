//
//  cloudkituser.swift
//  Cloudkit_test
//
//  Created by Hans Zebua on 31/07/24.
//

import SwiftUI
import CloudKit

struct cloudkituser: View {
    
    @StateObject private var checkUserStatusvm = checkUserStatusVM()
    
    var body: some View {
        
        NavigationStack {
            VStack {
                var signInStatus: String = "\(checkUserStatusvm.isSignedIntoiCloud.description.uppercased())"
                
                Text("IS SIGNED IN: \(signInStatus)")
                
                
                VStack {
                    if signInStatus == "TRUE" {
                        
                        Text("Welcome \(checkUserStatusvm.userName.description)!")
                        
                        NavigationLink {
                           cloudkitAddRecord()
                        } label: {
                            Text("Continue")
                        }
                        .padding()
                    }
                    else if signInStatus == "FALSE" {
                        Text(checkUserStatusvm.error)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    cloudkituser()
}
