//
//  cloudkitAddRecord.swift
//  Cloudkit_test
//
//  Created by Hans Zebua on 05/08/24.
//

import SwiftUI
import CloudKit

struct cloudkitAddRecord: View {
    
    @StateObject private var vm = cloudKitCRUDVM()
    @StateObject private var tagsvm = tagsVM()
    
    @State private var petImage: UIImage?
    @State private var showingImagePicker = false
    @State private var newName: String = ""
    
    @State private var selectedPet: PetsModel? = nil
    @State private var showingUpdateSheet = false
    
    @State private var searchTerm = ""

    var filteredPet: [PetsModel] {
        guard !searchTerm.isEmpty else { return vm.pets }
        return vm.pets.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
    }
    
    @State private var selectedTags: Set<String> = []

    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    TextField("Add something here...", text: $vm.text)
                        .frame(height: 40)
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(4.0)
                    
                    ZStack {
                        if let petImage {
                            Image(uiImage: petImage)
                                .resizable()
                                .frame(height: 200)
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 200)
                            
                            VStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.largeTitle)
                                    .foregroundColor(.blue)
                                
                                Text("Insert your Pets image here")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .onTapGesture {
                        self.showingImagePicker = true
                    }
                    .sheet(isPresented: $showingImagePicker) {
                        ImagePicker(sourceType: .photoLibrary, image: $petImage)
                    }
                    
                    Text("Select Tags")
                        .padding()
                        .font(.title2)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tagsvm.tags, id: \.self) { tag in
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
                    
                    Button {
                        vm.addButtonPressed(petImage: petImage, tags: selectedTags)
                    } label: {
                        HStack {
                            Text("Add Item")
                                .foregroundColor(.white)
                                .padding()
                        }
                        .background(Color.blue)
                        .cornerRadius(4.0)
                        .padding()
                    }
                }
                .padding()
                
                List {
                    ForEach(filteredPet, id: \.self) { pet in
                        VStack {
                            HStack {
                                Text(pet.name)
                                if let url = pet.imageURL, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                }
                            }
                            HStack {
                                ForEach(Array(pet.tags), id: \.self) { tag in
                                    Text(tag)
                                        .padding()
                                        .background(Color.gray)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .onTapGesture {
                            selectedPet = pet // Set the selected pet
                            newName = pet.name // Pre-fill the TextField with the current name
                            showingUpdateSheet = true // Show the update sheet
                        }
                    }
                    .onDelete(perform: vm.deleteItem)
                }
                .navigationTitle("Add New Records")
            }
            .padding()
            .searchable(text: $searchTerm, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Menu")
            .sheet(isPresented: $showingUpdateSheet) {
                VStack {
                    Text("Update Name")
                        .font(.headline)
                    
                    TextField("Enter new name...", text: $newName)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    
                    Button("Update") {
                        if let pet = selectedPet {
                            vm.updateItem(pet: pet, newName: newName)
                        }
                        showingUpdateSheet = false // Dismiss the sheet
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
        }
    }
}


#Preview {
    cloudkitAddRecord()
}
