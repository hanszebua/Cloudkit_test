//
//  checkuserVM.swift
//  Cloudkit_test
//
//  Created by Hans Zebua on 04/08/24.
//

import Foundation
import CloudKit

class checkUserStatusVM: ObservableObject {
    
    @Published var isSignedIntoiCloud: Bool = false
    @Published var error: String = ""
    @Published var permissionStatus: Bool = false
    @Published var userName: String = ""
    
    init () {
        getIcloudStatus()
        requestPermission()
        fetchIcloudUserRecordID()
    }
    
    private func getIcloudStatus() {
        CKContainer.default().accountStatus {
            returnedStatus, returnedError in
            DispatchQueue.main.async {
                switch returnedStatus {
                case .available:
                    self.isSignedIntoiCloud = true
                case .noAccount:
                    self.error = CloudKitError.iCloudAccountNotFound.rawValue
                case .couldNotDetermine:
                    self.error = CloudKitError.iCloudAccountNotDetermined.rawValue
                case .restricted:
                    self.error = CloudKitError.iCloudAccountRestricted.rawValue
                default:
                    self.error = CloudKitError.iCloudAccountUnknown.rawValue
                }
            }
        }
    }
    
    enum CloudKitError: String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknown
    }
   
    func requestPermission() {
        
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) { [weak self] returnedStatus,
            returnedError in
            DispatchQueue.main.async {
                if returnedStatus == .granted {
                    self?.permissionStatus = true
                }
            }
            
        }
    }
    
    func fetchIcloudUserRecordID() {
        CKContainer.default().fetchUserRecordID { [weak self] returnedID,
            returnedError in
            if let id = returnedID {
                self?.discoveriCLoudUser(id: id)
            }
            
        }
    }
    
    func discoveriCLoudUser(id: CKRecord.ID) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) {
            [weak self] returnedIdentity, returnedError in
            DispatchQueue.main.async {
                if let name = returnedIdentity?.nameComponents?.givenName {
                    self?.userName = name
                }
            }
        }
    }
}
