//
//  DecryptSuccessView.swift
//  pass-menubar
//
//  Created by phil on 27/05/2021.
//

import SwiftUI

func clearClipboardCloseWindow() {
    if clearClipboard() == true {
        NSApplication.shared.keyWindow?.close()
    } else {
        print("failed to clear clipboard")
    }
}

struct DecryptSuccessView: View {
    let password: Password
    var clipboardSuccess = false
    @State private var timeLeft = 45
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Copy to clipboard
    init(password: Password, decryptedPassword: String) {
        self.password = password
        if copyClipboard(str: decryptedPassword) == true {
            clipboardSuccess = true
        } else {
            print("failed to copy to clipboard")
        }
    }

    var body: some View {
        HStack {
            Text("Password ")
            TextField("", text: .constant(password.display)).fixedSize()
            Text(" has been copied to clipboard.").fontWeight(.bold)
        }
        Text("Will clear in \(timeLeft) seconds.").fontWeight(.bold)
            .onReceive(timer) { _ in
                if timeLeft > 0 {
                    timeLeft -= 1
                } else {
                    // Clear clipboard and close window when timer is over
                    clearClipboardCloseWindow()
                }
            }
        Button("Clear now", action: {
            clearClipboardCloseWindow()
        }).keyboardShortcut(.defaultAction)
    }
}

struct DecryptSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        let password = Password(path: "/Users/phil/.password-store/file.gpg", relativePath: "file")
        DecryptSuccessView(password: password, decryptedPassword: "password")
    }
}
