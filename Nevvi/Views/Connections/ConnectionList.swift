//
//  ConnectionList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionList: View {
    @ObservedObject var accountStore: AccountStore
    @ObservedObject var usersStore: UsersStore
    @ObservedObject var connectionsStore: ConnectionsStore
    @ObservedObject var connectionStore: ConnectionStore
    
    @State private var toBeDeleted: IndexSet?
    @State private var showDeleteAlert: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.connectionsStore.connections) { connection in
                    NavigationLink {
                        NavigationLazyView(
                            ConnectionDetail(accountStore: self.accountStore, connectionStore: self.connectionStore)
                                .onAppear {
                                    self.connectionStore.load(connectionId: connection.id)
                                }
                        )
                    } label: {
                        ConnectionRow(connection: connection)
                    }
                }
                .onDelete(perform: self.delete)
            }
            .navigationTitle("Connections")
            .navigationBarTitleDisplayMode(.automatic)
            .navigationBarItems(trailing: NavigationLink {
                ConnectionSearch(accountStore: self.accountStore, usersStore: self.usersStore)
                    .navigationBarTitleDisplayMode(.inline)
                    .padding([.top], -100)
            } label: {
                Image(systemName: "plus").foregroundColor(.blue)
            })
            .alert(isPresented: self.$showDeleteAlert) {
                Alert(title: Text("Delete confirmation"), message: Text("Are you sure you want to remove this connection?"), primaryButton: .destructive(Text("Delete")) {
                        for index in self.toBeDeleted! {
                            let connectionid = self.connectionsStore.connections[index].id
                            self.connectionStore.delete(connectionId: connectionid) { (result: Result<Bool, Error>) in
                                switch result {
                                case.success(_):
                                    self.connectionsStore.load()
                                case .failure(let error):
                                    print(error)
                                }
                            }
                        }
                    
                        self.toBeDeleted = nil
                        self.showDeleteAlert = false
                    }, secondaryButton: .cancel() {
                        self.toBeDeleted = nil
                        self.showDeleteAlert = false
                    }
                )
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        self.toBeDeleted = offsets
        self.showDeleteAlert = true
    }
}

struct ConnectionList_Previews: PreviewProvider {
    static let modelData = ModelData()
    static let accountStore = AccountStore(user: modelData.user)
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users, requests: modelData.requests)
    static let connectionStore = ConnectionStore()
    
    static var previews: some View {
        ConnectionList(accountStore: accountStore, usersStore: usersStore, connectionsStore: connectionsStore, connectionStore: connectionStore).environmentObject(modelData)
    }
}
