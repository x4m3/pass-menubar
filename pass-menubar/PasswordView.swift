//
//  PasswordView.swift
//  pass-menubar
//
//  Created by phil on 05/04/2021.
//

import SwiftUI
import Files

struct PasswordView: View {
    let password: Password

    var body: some View {
        Text(password.display)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .border(Color.green)
            .onTapGesture {
                print(password.file.path)
            }
    }
}

/*
struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        let test: Password
        // TODO: provide a password store to test with pgp key
        PasswordView(password: test)
    }
}
*/
