//
//  File_public.swift
//  Cloudkit_test
//
//  Created by Hans Zebua on 15/08/24.
//

import Foundation
import SwiftUI
import CloudKit

class privateDBTest: ObservableObject {
    @Published var text: String = ""
    @Published var pets: [Dummy] = []
    
    init() {
        fetchItems()
    }
    
    func addButtonPressed() {
        guard !text.isEmpty else { return }
        addItem(name: text)
    }
    
    private func addItem(name: String) {
        let newPet = CKRecord(recordType: "Test")
        newPet["name"] = name
        
        saveItem(record: newPet) // Save the record (with or without an image)
    }
    
    private func saveItem(record: CKRecord) {
        CKContainer.default().privateCloudDatabase.save(record) { [weak self] returnedRecord, returnedError in
            DispatchQueue.main.async {
                if let savedRecord = returnedRecord {
                    let name = savedRecord["name"] as? String ?? ""
                    let newPet = Dummy(name: name, record: savedRecord)
                    
                    self?.pets.append(newPet)
                }
                self?.text = ""
            }
        }
    }
    
    func fetchItems() {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Test", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        var returnedItems: [Dummy] = []
        
        queryOperation.recordMatchedBlock = { (returnedRecordID, returnedResult) in
            switch returnedResult {
            case .success(let record):
                guard let name = record["name"] as? String else { return }
                returnedItems.append(Dummy(name: name, record: record))
            case .failure(let error):
                print(error)
            }
        }
        
        queryOperation.queryResultBlock = { [weak self] returnedResult in
            DispatchQueue.main.async {
                self?.pets = returnedItems
            }
        }
        
        addOperation(operation: queryOperation)
    }
    
    func addOperation(operation: CKDatabaseOperation) {
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    func updateItem(pet: Dummy, newName: String) {
        let record = pet.record
        record["name"] = newName
        
        // Save the updated record back to CloudKit
        saveItem(record: record)
    }
    
    func deleteItem(indexset: IndexSet) {
        guard let index = indexset.first else { return }
        let pet = pets[index]
        let record = pet.record
        
        CKContainer.default().privateCloudDatabase.delete(withRecordID: record.recordID) { [weak self] returnedRecordID, returnedError in
            DispatchQueue.main.async {
                self?.pets.remove(at: index)
            }
        }
    }
}
