//
//  PermissionGroupDetail.swift
//  Nevvi
//
//  Created by Tyler Cobb on 1/15/23.
//

import SwiftUI

struct PermissionGroupDetail: View {
    
    @State var group: PermissionGroup = PermissionGroup(name: "", fields: [])
    
    @State var groupName: String = ""
    @State var enableEmail: Bool = false
    @State var enablePhone: Bool = false
    @State var enableAddress: Bool = false
    @State var enableMailingAddress: Bool = false
    @State var enableBirthday: Bool = false
    
    var callback: (PermissionGroup) -> Void
    
    var body: some View {
        VStack {
            if self.group.name == "" {
                TextField("Group Name", text: self.$groupName)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.secondary, style: StrokeStyle(lineWidth: 1.0)))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding([.bottom], 30)
            } else {
                Text(self.group.name)
                    .font(.title2)
                    .padding([.bottom], 30)
            }
            
            Toggle("Email", isOn: self.$enableEmail)
                .onChange(of: self.enableEmail) { newValue in
                    handleToggle(newValue: newValue, field: "email")
                }
                .tint(ColorConstants.primary)
            
            Toggle("Phone Number", isOn: self.$enablePhone)
                .onChange(of: self.enablePhone) { newValue in
                    handleToggle(newValue: newValue, field: "phoneNumber")
                }
                .tint(ColorConstants.primary)
            
            Toggle("Address", isOn: self.$enableAddress)
                .onChange(of: self.enableAddress) { newValue in
                    handleToggle(newValue: newValue, field: "address")
                }
                .tint(ColorConstants.primary)
            
            Toggle("Mailing Address", isOn: self.$enableMailingAddress)
                .onChange(of: self.enableMailingAddress) { newValue in
                    handleToggle(newValue: newValue, field: "mailingAddress")
                }
                .tint(ColorConstants.primary)
            
            Toggle("Birthday", isOn: self.$enableBirthday)
                .onChange(of: self.enableBirthday) { newValue in
                    handleToggle(newValue: newValue, field: "birthday")
                }
                .tint(ColorConstants.primary)
            
            Spacer()
            
            saveButton
        }
        .onAppear {
            self.groupName = self.group.name
            self.enableEmail = self.group.fields.contains("email")
            self.enablePhone = self.group.fields.contains("phoneNumber")
            self.enableAddress = self.group.fields.contains("address")
            self.enableMailingAddress = self.group.fields.contains("mailingAddress")
            self.enableBirthday = self.group.fields.contains("birthday")
        }
        .padding()
    }
    
    var saveButton: some View {
        Button(action: {
            group.name = self.groupName
            callback(group)
        }, label: {
            Text("Save".uppercased())
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundColor(ColorConstants.primary)
                )
                .opacity(self.groupName == "" ? 0.5 : 1.0)
        })
        .disabled(self.groupName == "")
    }
    
    func handleToggle(newValue: Bool, field: String) {
        if newValue && !group.fields.contains(field) {
            group.fields.append(field)
        } else if (!newValue) {
            group.fields.removeAll { (fieldName: String) in
                fieldName == field
            }
        }
    }
}

struct PermissionGroupDetail_Previews: PreviewProvider {
    static let modelData = ModelData()
    static var previews: some View {
        PermissionGroupDetail(group: modelData.user.permissionGroups[1]) { (group: PermissionGroup) in
            print("Saving group", group)
        }
    }
}
