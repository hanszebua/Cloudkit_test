//
//  petsModel.swift
//  Cloudkit_test
//
//  Created by Hans Zebua on 06/08/24.
//

import Foundation
import CloudKit

struct PetsModel: Hashable {
    let name: String
    let record: CKRecord
    let imageURL: URL?
    var tags: [String]
}
