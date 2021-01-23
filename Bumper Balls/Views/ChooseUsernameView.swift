//
//  ChooseUsernameView.swift
//  Bumper Balls
//
//  Created by Samuel Donovan on 1/21/21.
//

import SwiftUI

extension String: Identifiable {
    public var id: String {
        return self
    }
}

struct ChooseUsernameView: View {
    
    @State var errorMessage: String?
    
    var body: some View {
        Text("Hi")
            .alert(item: $errorMessage, content: {(errorMessage: String) in
                Alert(title: Text("Connection Reset"), message: Text(errorMessage), dismissButton: nil)
            })
    }
}

struct ChooseUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseUsernameView(errorMessage: "i can't seem to face up to the facts")
    }
}
