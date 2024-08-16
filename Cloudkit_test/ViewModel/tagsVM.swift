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
    @Published var publicTags: [petsLabel] = []
    @Published var privateTags: [petsLabel] = []
    
    init() {
        // Optionally fetch both public and private data at initialization
        fetchItems(from: .publicDB)
        fetchItems(from: .privateDB)
    }
    
    func addUserPreferences(tags: Set<String>) {
        guard !tags.isEmpty else { return }
        for tag in tags {
            addItem(name: tag)
        }
    }
    
    private func addItem(name: String) {
        let newTag = CKRecord(recordType: "Tags")
        newTag["name"] = name
        
        saveUserPreferences(record: newTag)
    }
    
    private func saveUserPreferences(record: CKRecord) {
        CKContainer.default().privateCloudDatabase.save(record) { [weak self] returnedRecord, returnedError in
            DispatchQueue.main.async {
                if let savedRecord = returnedRecord {
                    let name = savedRecord["name"] as? String ?? ""
                    let newTag = petsLabel(name: name, record: savedRecord)
                    
                    self?.privateTags.append(newTag) // Assuming new tags are private
                }
                self?.text = ""
            }
        }
    }
    
    enum DatabaseType {
        case publicDB
        case privateDB
    }
    
    func fetchItems(from databaseType: DatabaseType) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Tags", predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        
        var returnedItems: [petsLabel] = []
        
        queryOperation.recordMatchedBlock = { (returnedRecordID, returnedResult) in
            switch returnedResult {
            case .success(let record):
                guard let name = record["name"] as? String else { return }
                returnedItems.append(petsLabel(name: name, record: record))
            case .failure(let error):
                print("Error fetching record: \(error.localizedDescription)")
            }
        }
        
        queryOperation.queryResultBlock = { [weak self] returnedResult in
            print("Fetch result: \(returnedResult)")
            
            DispatchQueue.main.async {
                switch databaseType {
                case .publicDB:
                    self?.publicTags = returnedItems
                case .privateDB:
                    self?.privateTags = returnedItems
                    print("Private Fetch result: \(returnedResult)")
                }
            }
        }
        
        addOperation(operation: queryOperation, to: databaseType)
    }
    
    private func addOperation(operation: CKDatabaseOperation, to databaseType: DatabaseType) {
        let database: CKDatabase
        
        switch databaseType {
        case .publicDB:
            database = CKContainer.default().publicCloudDatabase
        case .privateDB:
            database = CKContainer.default().privateCloudDatabase
        }
        
        database.add(operation)
    }
}

