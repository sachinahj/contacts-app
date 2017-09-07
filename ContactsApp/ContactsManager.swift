//
//  ContactsManager.swift
//  ContactsApp
//
//  Created by Sachin Ahuja on 9/4/17.
//  Copyright © 2017 Sachin Ahuja. All rights reserved.
//

import Foundation
import Contacts

class ContactsManager {
    let contactStore = CNContactStore()
    
    func get(completion: @escaping ([CNContact]) -> Void) {
        self.check(completion: completion)
    }
    
    func check(completion: @escaping ([CNContact]) -> Void) {
        
        let contactStatus = CNContactStore.authorizationStatus(for: .contacts)
        print("Authorization Status: rawValue", contactStatus.rawValue)
        
        if (contactStatus != .authorized) {
            contactStore.requestAccess(for: .contacts, completionHandler:
            { (granted, error) in
                if (granted) {
                    self.fetch(completion: completion)
                }
                if let errorDescription = error?.localizedDescription {
                    print("error?", errorDescription)
                }
            })
        } else {
            self.fetch(completion: completion)
        }
    }
    
    func fetch(completion: ([CNContact]) -> Void) {
        var contacts = [CNContact]()
        let contactKeys = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactImageDataKey as CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactPostalAddressesKey as CNKeyDescriptor,
            ]
        let contactsFetchRequest = CNContactFetchRequest(keysToFetch: contactKeys)
        
        do {
            try contactStore.enumerateContacts(with: contactsFetchRequest, usingBlock:
            { (cnContact, error) in
                if cnContact.postalAddresses.count > 0 {
                    contacts.append(cnContact)
                }
            })
        } catch {
            print("Catching error")
        }
        
        completion(contacts)
    }
    
}
