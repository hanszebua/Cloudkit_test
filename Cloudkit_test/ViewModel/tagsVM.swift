//
//  tagsVM.swift
//  Cloudkit_test
//
//  Created by Hans Zebua on 11/08/24.
//

import Foundation
import SwiftUI
import CloudKit

class tagsVM: ObservableObject {
    @Published var text: String = ""
    @Published var tags: [petsLabel] = []
 
    init () {
        fetchItems()
    }
    
    private func addItem(name: String, petImage: UIImage?) {
        let newPet = CKRecord(recordType: "Pets")
        newPet["name"] =  name
        
        saveItem(record: newPet)
    }
    
    private func saveItem(record: CKRecord) {
        CKContainer.default().publicCloudDatabase.save(record) { [weak self] returnedRecord, returnedError in
            DispatchQueue.main.async {
                if let savedRecord = returnedRecord {
                    let name = savedRecord["name"] as? String ?? ""
                    let newPet = petsLabel(name: name, record: savedRecord)
                    
                    self?.tags.append(newPet)
                }
                self?.text = ""
            }
        }
    }
    
    func fetchItems() {
        let predicate = NSPredicate(value: true)
        let querry = CKQuery(recordType: "Tags", predicate: predicate)
        let querryOperation = CKQueryOperation(query: querry)
        
        var returnedItems: [petsLabel] = []
        
        querryOperation.recordMatchedBlock = { (returnedRecordID, returnedresult) in
            switch returnedresult {
            case .success(let record):
                guard let name = record["name"] as? String else { return }
                returnedItems.append(petsLabel(name: name, record: record))
            case .failure(let error):
                break
            }
        }
        
        querryOperation.queryResultBlock = { [weak self] returnedResult in
                print("\(returnedResult)")
            
            DispatchQueue.main.async {
                self?.tags = returnedItems
            }
        }
        
        addOperation(operation: querryOperation)
    }
    
    func addOperation(operation: CKDatabaseOperation) {
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
}

