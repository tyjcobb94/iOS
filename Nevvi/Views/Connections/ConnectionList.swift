//
//  ConnectionList.swift
//  Nevvi
//
//  Created by Tyler Cobb on 12/29/22.
//

import SwiftUI

struct ConnectionList: View {
    @EnvironmentObject var connectionsStore: ConnectionsStore
    @EnvironmentObject var usersStore: UsersStore
    
    @ObservedObject var connectionStore: ConnectionStore
    
    @State private var toBeDeleted: IndexSet?
    @State private var showDeleteAlert: Bool = false
    @StateObject var nameFilter = DebouncedText()
        
    var body: some View {
        NavigationView {
            List {
                if self.connectionsStore.connectionCount == 0 {
                    HStack {
                        Spacer()
                        if self.connectionsStore.loading {
                            ProgressView()
                        } else {
                            VStack {
                                Image(systemName: "person.2.slash")
                                    .resizable()
                                    .frame(width: 120, height: 100)
                                Text("No connections found")
                            }
                        }
                        Spacer()
                    }
                    .padding([.top], 100)
                } else {
                    ForEach(self.connectionsStore.connections) { connection in
                        NavigationLink {
                            NavigationLazyView(
                                RefreshableView(onRefresh: {
                                    self.connectionStore.load(connectionId: connection.id) { (result: Result<Connection, Error>) in
                                        switch result {
                                        case .success(_):
                                            print("Got connection \(connection.id)")
                                        case .failure(let error):
                                            print("Something bad happened", error)
                                        }
                                    }
                                }, view: ConnectionDetail(connectionStore: self.connectionStore)
                                    .onAppear {
                                        self.connectionStore.load(connectionId: connection.id) { (result: Result<Connection, Error>) in
                                            switch result {
                                            case .success(_):
                                                print("Got connection \(connection.id)")
                                            case .failure(let error):
                                                print("Something bad happened", error)
                                            }
                                        }
                                    }
                                )
                            )
                        } label: {
                            ConnectionRow(connection: connection)
                        }
                    }
                    .onDelete(perform: self.delete)
                    .redacted(when: self.connectionsStore.loading, redactionType: .customPlaceholder)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Connections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                NavigationLink {
                    UserSearch()
                        .navigationBarTitleDisplayMode(.inline)
                        .padding([.top], -100)
                } label: {
                    Image(systemName: "plus").foregroundColor(.blue)
                }
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
                                print("Something bad happened", error)
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
            .searchable(text: self.$nameFilter.text)
            .disableAutocorrection(true)
            .onChange(of: self.nameFilter.debouncedText) { text in
                self.connectionsStore.load(nameFilter: text)
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
    static let usersStore = UsersStore(users: modelData.connectionResponse.users)
    static let connectionsStore = ConnectionsStore(connections: modelData.connectionResponse.users,
                                                   requests: modelData.requests,
                                                   blockedUsers: modelData.connectionResponse.users)
    static let connectionStore = ConnectionStore()
    
    static var previews: some View {
        ConnectionList(connectionStore: connectionStore)
            .environmentObject(connectionsStore)
            .environmentObject(usersStore)
    }
}
