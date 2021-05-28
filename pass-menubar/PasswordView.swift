//
//  PasswordView.swift
//  pass-menubar
//
//  Created by phil on 05/04/2021.
//

import SwiftUI
import Files

struct PasswordView: View {
    @State private var isHover = false
    let password: Password
    @AppStorage("rawPathKey") private var rawPathKey = ""

    var body: some View {
        Text(password.display)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .background(isHover ? Color.red : Color.clear)
            .onHover {
                self.isHover = $0
            }
            .onTapGesture {
                do {
                    // Attempt to get passphrase from macos keychain
                    let keyId = extractKeyIdFromFile(path: rawPathKey)
                    try getPassphrase(keyId: keyId) { (passphrase) in
                        print("got passphrase from keychain: \(passphrase)")

                        // Attempt to decrypt with passphrase from keychain
                        let result = try? decrypt(path: password.path, key: rawPathKey, passphrase: passphrase, line: 0)
                        if let result = result {
                            print("decryption result: \(result)")

                            // Display success view, and copy to clipboard
                            let decryptSuccessView = DecryptSuccessView(password: password, decryptedPassword: result)
                            let controller = ViewWindowController(rootView: decryptSuccessView, title: password.display)
                            controller.openWindow()
                        }
                    }
                } catch {
                    print("error while decrypting : \(error)")
                    print("gonna show passphrase prompt")
                    let decryptView = DecryptView(password: password)
                    let controller = ViewWindowController(rootView: decryptView, title: password.display)
                    controller.openWindow()
                }
            }
    }
}

struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView(password: Password(path: "/Users/phil/.password-store/file.gpg", relativePath: "file"))
    }
}
