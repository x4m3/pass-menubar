//
//  pass_menubarTests.swift
//  pass-menubarTests
//
//  Created by phil on 07/04/2021.
//

import XCTest
import Files
@testable import pass_menubar

func countFilesInDirectory(path: String) -> Int {
    var count = 0
    do {
        let rootPasswordStore = try Folder(path: path)
        for file in rootPasswordStore.files.recursive {
            // get gpg files
            if file.path.suffix(4) != ".gpg" {
                continue
            }
            count += 1
        }
    } catch {
        count = -1
    }
    return count
}

class PassMenubarTests: XCTestCase {

    func testPassword() throws {
        let testBundle = Bundle(for: type(of: self))
        let passwordStoreRoot = testBundle.resourcePath! + "/assets/password-store/"

        let filename = "destroy.gpg"
        let passwordPath = passwordStoreRoot + filename

        let password = Password(path: passwordPath, relativePath: filename)
        XCTAssertEqual(password.display, "destroy")
    }

    func testPasswordList() throws {
        // Get test password store
        let testBundle = Bundle(for: type(of: self))
        let passwordStore = testBundle.resourcePath! + "/assets/password-store"

        let passwords = passwordList(path: passwordStore)
        XCTAssertEqual(passwords.count, countFilesInDirectory(path: passwordStore))
    }

    func testdecryptValidPassphrase() throws {
        let passphrase = "password"

        let testBundle = Bundle(for: type(of: self))
        let assetsRoot = testBundle.resourcePath! + "/assets"
        let secretKey = assetsRoot + "/secret-key.asc"
        let passwordPath = assetsRoot + "/password-store/destroy.gpg"

        let output = try decrypt(path: passwordPath, key: secretKey, passphrase: passphrase, remember: false)
        XCTAssertEqual(output, "destroy")
    }

    func testDecryptInvalidPassphrase() throws {
        let passphrase = "invalid_password"

        let testBundle = Bundle(for: type(of: self))
        let assetsRoot = testBundle.resourcePath! + "/assets"
        let secretKey = assetsRoot + "/secret-key.asc"
        let passwordPath = assetsRoot + "/password-store/destroy.gpg"

        do {
        _ = try decrypt(path: passwordPath, key: secretKey, passphrase: passphrase, remember: false)
        } catch let error as DecryptError {
            XCTAssertEqual(error, DecryptError.decryption)
        }
    }

    func testDecryptInvalidKey() throws {
        let passphrase = "password"

        let testBundle = Bundle(for: type(of: self))
        let assetsRoot = testBundle.resourcePath! + "/assets"
        let secretKey = assetsRoot + "/does_not_exist"
        let passwordPath = assetsRoot + "/password-store/destroy.gpg"

        do {
            _ = try decrypt(path: passwordPath, key: secretKey, passphrase: passphrase, remember: false)
        } catch let error as DecryptError {
            XCTAssertEqual(error, DecryptError.key)
        }
    }

    func testDecryptMultilinePassword() throws {
        let passphrase = "password"

        let testBundle = Bundle(for: type(of: self))
        let assetsRoot = testBundle.resourcePath! + "/assets"
        let secretKey = assetsRoot + "/secret-key.asc"
        let passwordPath = assetsRoot + "/password-store/multiline.gpg"

        // First line of the file is "this"
        let firstLine = try decrypt(path: passwordPath, key: secretKey, passphrase: passphrase, remember: false)
        XCTAssertEqual(firstLine, "this")
    }
}
