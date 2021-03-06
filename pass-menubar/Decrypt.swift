//
//  Decrypt.swift
//  pass-menubar
//
//  Created by phil on 18/04/2021.
//

import ObjectivePGP

enum DecryptError: Error {
    case file
    case key
    case line
    case decryption
    case stringConversion
}

func extractPrivateKeyIdFromFile(path: String) -> String {
    guard let keys = try? ObjectivePGP.readKeys(fromPath: path) else {
        return ""
    }
    return extractPrivateKeyIdFromKeys(keys: keys)
}

func extractPrivateKeyIdFromKeys(keys: [Key]) -> String {
    for key in keys {
        if let privateKey = key.secretKey {
            return "\(privateKey.keyID)"
        }
    }
    return ""
}

func decrypt(path: String, key: String, passphrase: String, remember: Bool) throws -> String {
    // load file from path as NSData
    guard let encryptedData = FileManager.default.contents(atPath: path) else {
        throw DecryptError.file
    }

    // open pgp key
    guard let keys = try? ObjectivePGP.readKeys(fromPath: key) else {
        throw DecryptError.key
    }

    // decrypt file
    guard let decryptedData = try? ObjectivePGP.decrypt(encryptedData, andVerifySignature: false, using: keys, passphraseForKey: { (_) -> String? in
        return passphrase
    }) else {
        throw DecryptError.decryption
    }

    if remember == true {
        let keyID = extractPrivateKeyIdFromKeys(keys: keys)
        try savePassphraseKeychain(keyId: keyID, passphrase: passphrase)
    }

    // convert raw bytes to a oneline string
    guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
        throw DecryptError.stringConversion
    }

    // get specific line of multi line password
    let line = 0
    let password = decryptedString.components(separatedBy: "\n")
    if password.indices.contains(line) == false {
        throw DecryptError.line
    }
    return password[line]
}
