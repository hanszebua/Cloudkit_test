//
//  tagspicker.swift
//  Cloudkit_test
//
//  Created by Hans Zebua on 13/08/24.
//

import SwiftUI

struct TagsPicker: View {
    @Binding var selectedTags: Set<String>
    @ObservedObject var tagsvm: tagsVM
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tagsvm.publicTags, id: \.self) { tag in
                    Text(tag.name)
                        .padding()
                        .background(selectedTags.contains(tag.name) ? .blue : .gray)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .onTapGesture {
                            if selectedTags.contains(tag.name) {
                                selectedTags.remove(tag.name)
                            } else {
                                selectedTags.insert(tag.name)
                            }
                        }
                }
                .foregroundColor(.white)
            }
        }
    }
}
