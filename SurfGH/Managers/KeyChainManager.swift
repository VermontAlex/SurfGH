//
//  KeyChainManager.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import Foundation

final class KeyChainManager {
    
    private enum KeychainError: Error {
        case duplicateEntry
        case invalidToken
        case unhandledError(OSStatus)
        case unknown(OSStatus)
        case noPassword
        case unexpectedPasswordData
        case invalidDataTypeReturned
    }
    
    static func save(credentials: CredentialsModel) throws {
        guard let accessToken = credentials.personalToken.data(using: String.Encoding.utf8) else { throw KeychainError.invalidToken }
        
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: credentials.account as AnyObject,
            kSecAttrService as String: credentials.server as AnyObject,
            kSecValueData as String: accessToken as AnyObject
        ]
        
        var status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            let attributes: [String: AnyObject] = [
                kSecAttrAccount as String: credentials.account as AnyObject,
                kSecAttrService as String: credentials.server as AnyObject,
                kSecValueData as String: accessToken as AnyObject]
            
            status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        }
        
        guard status == errSecSuccess else {
            ErrorHandlerService.errorKeyChain(status).handleErrorWithDB()
            throw KeychainError.unknown(status)
        }
    }
    
    static func get(account: String, service: String) throws -> Data {
        
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account as AnyObject,
            kSecAttrService as String: service as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else {
            ErrorHandlerService.errorKeyChain(status).handleErrorWithDB()
            throw KeychainError.unhandledError(status) }
        guard let result = result as? Data else { throw KeychainError.invalidDataTypeReturned }
        
        return result
    }
}
