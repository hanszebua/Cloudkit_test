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
    @StateObject private var tagsvm = tagsVM()
    @State private var selectedTags: Set<String> = []
    
    var body: some View {
        
        NavigationStack {
            VStack {
                var signInStatus: String = "\(checkUserStatusvm.isSignedIntoiCloud.description.uppercased())"
                
                Text("IS SIGNED IN: \(signInStatus)")
                
                VStack {
                    if signInStatus == "TRUE" {
                        
                        Text("Welcome \(checkUserStatusvm.userName.description)!")
                        
                        TagsPicker(selectedTags: $selectedTags, tagsvm: tagsvm)
                            .padding()
                        
                        Button {
                            tagsvm.addUserPreferences(tags: selectedTags)
                        } label: {
                            Text("Saves Preferences")
                                .padding()
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .foregroundColor(.white)
                        }
                        .padding()
                        
                        if tagsvm.privateTags.isEmpty {
                            Text("Kosong bjir")
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(tagsvm.privateTags, id: \.self) { tag in
                                        Text(tag.name)
                                    }
                                    .padding()
                                    .background(.blue)
                                }
                            }
                        }
                        
                        NavigationLink {
                           cloudkitAddRecord()
                        } label: {
                            Text("Continue")
                                .padding()
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .foregroundColor(.white)
                        }
                        .padding()
                        
                        NavigationLink {
                            cloudkitAddRecordPrivate()
                        } label: {
                            Text("Continue privately")
                                .padding()
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .foregroundColor(.white)
                        }
                        .padding()
                        
                        NavigationLink {
                            cloudkitAddRecordpublic()
                        } label: {
                            Text("Continue privately")
                                .padding()
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .foregroundColor(.white)
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
