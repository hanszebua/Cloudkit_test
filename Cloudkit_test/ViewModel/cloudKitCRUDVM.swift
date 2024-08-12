//
//  cloudKitCRUDVM.swift
//  Cloudkit_test
//
//  Created by Hans Zebua on 06/08/24.
//

import Foundation
import CloudKit
import SwiftUI

class cloudKitCRUDVM: ObservableObject {
    @Published var text: String = ""
    @Published var pets: [PetsModel] = []
    
    init() {
        fetchItems()
    }
    
    func addButtonPressed(petImage: UIImage?, tags: Set<String>) {
        guard !text.isEmpty else { return }
        addItem(name: text, petImage: petImage, tags: tags)
    }
    
    private func addItem(name: String, petImage: UIImage?, tags: Set<String>) {
        let newPet = CKRecord(recordType: "Pets")
        newPet["name"] = name
        newPet["tags"] = Array(tags) as CKRecordValue // Add tags to the record

        if let image = petImage,
           let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(UUID().uuidString + ".jpg"),
           let data = image.jpegData(compressionQuality: 1.0) {
            
            do {
                try data.write(to: url)
                let asset = CKAsset(fileURL: url)
                newPet["image"] = asset
            } catch let error {
                print(error)
            }
        }
        
        saveItem(record: newPet) // Save the record (with or without an image)
    }
    
    private func saveItem(record: CKRecord) {
        CKContainer.default().publicCloudDatabase.save(record) { [weak self] returnedRecord, returnedError in
            DispatchQueue.main.async {
                if let savedRecord = returnedRecord {
                    let name = savedRecord["name"] as? String ?? ""
                    let imageAsset = savedRecord["image"] as? CKAsset
                    let imageURL = imageAsset?.fileURL
                    let tags = savedRecord["tags"] as? [String] ?? [] // Fetch the tags
                    let newPet = PetsModel(name: name, record: savedRecord, imageURL: imageURL, tags: tags)
                    
                    self?.pets.append(newPet)
                }
                self?.text = ""
            }
        }
    }
    
    func fetchItems() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Pets", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        var returnedItems: [PetsModel] = []
        
        queryOperation.recordMatchedBlock = { (returnedRecordID, returnedResult) in
            switch returnedResult {
            case .success(let record):
                guard let name = record["name"] as? String else { return }
                let imageAsset = record["image"] as? CKAsset
                let imageURL = imageAsset?.fileURL
                let tags = record["tags"] as? [String] ?? [] // Fetch the tags
                returnedItems.append(PetsModel(name: name, record: record, imageURL: imageURL, tags: tags))
            case .failure(let error):
                print(error)
            }
        }
        
        queryOperation.queryResultBlock = { [weak self] returnedResult in
            print("\(returnedResult)")
            DispatchQueue.main.async {
                self?.pets = returnedItems
            }
        }
        
        addOperation(operation: queryOperation)
    }
    
    func addOperation(operation: CKDatabaseOperation) {
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    func updateItem(pet: PetsModel, newName: String) {
        let record = pet.record
        record["name"] = newName
        
        // Save the updated record back to CloudKit
        saveItem(record: record)
    }
    
    func deleteItem(indexset: IndexSet) {
        guard let index = indexset.first else { return }
        let pet = pets[index]
        let record = pet.record
        
        CKContainer.default().publicCloudDatabase.delete(withRecordID: record.recordID) { [weak self] returnedRecordID, returnedError in
            DispatchQueue.main.async {
                self?.pets.remove(at: index)
            }
        }
    }
    
}
