//
//  testprivateview.swift
//  Cloudkit_test
//
//  Created by Hans Zebua on 15/08/24.
//

import SwiftUI
import CloudKit

struct cloudkitAddRecordPrivate: View {
    
    @StateObject private var vm = privateDBTest()
    
    @State private var newName: String = ""
    
    @State private var selectedPet: Dummy? = nil
    @State private var showingUpdateSheet = false
    
    @State private var searchTerm = ""

    var filteredPet: [Dummy] {
        guard !searchTerm.isEmpty else { return vm.pets }
        return vm.pets.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    TextField("Add something here...", text: $vm.text)
                        .frame(height: 40)
                        .padding()
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(4.0)
                    
                    Text("Select Tags")
                        .padding()
                        .font(.title2)
                    
                    Button {
                        vm.addButtonPressed()
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
                .navigationTitle("Add New Records privateDBTest")
                .padding()
                
                if vm.pets.isEmpty {
                    Text("kosong bjir")
                } else {
                    List {
                        ForEach(vm.pets, id: \.self) { pet in
                            VStack {
                                HStack {
                                    Text(pet.name)
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
                }
            }
            .padding()
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
    cloudkitAddRecordPrivate()
}
