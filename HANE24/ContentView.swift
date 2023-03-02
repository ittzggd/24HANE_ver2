//
//  ContentView.swift
//  HANE24
//
//  Created by Katherine JANG on 2/13/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @EnvironmentObject var hane: Hane
    @ObservedObject var networkManager = NetworkManager()
    @State var signInChecked = false

    var body: some View {
        ZStack{
            if !signInChecked {
                LoadingView()
            } else {
                switch hane.isSignIn{
                case false:
                    SignInView()
                case true:
                    MainView()
                }
            }
        }
        .task{
            do{
                try  hane.isSignIn = await hane.isLogin() ? true : false
                self.signInChecked = true
            } catch {
                print("Invalid URL")
            }

        }
        .alert(isPresented: $networkManager.showAlert){
            Alert(title: Text("Error"), message: Text("네트워크 연결 상태를 확인해주세요."),
            dismissButton: .default(Text("다시시도"), action: {
                networkManager.monitoringNetwork{ isConnected in
                }
            }))
        }
    }


}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(Hane())
    }
}
