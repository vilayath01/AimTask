import SwiftUI

struct CustomAlertView: View {
    @Binding var isPresented: Bool
    @Binding var addTaskModel: [AddTaskModel]
    @ObservedObject var addingViewModel = AddingViewModel()
    @Binding var locationName: String
    var fdbManager = FDBManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add task Items @ \(locationName)")
                .font(.headline)
                .foregroundColor(Color.black)
            
            List {
                ForEach($addTaskModel.indices, id: \.self) { index in
                    createListItemView(for: index)
                }
            }
            .frame(maxHeight: 250)
            .cornerRadius(16)
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.trailing)
                
                Button("Save") {
                    onSave(addTaskModel: addTaskModel)
                    isPresented = false
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
    }
    
    @ViewBuilder
    private func createListItemView(for index: Int) -> some View {
        ForEach(addTaskModel[index].taskItems.indices, id: \.self) { taskIndex in
            // Create a binding for the individual task item
            let taskItemBinding = Binding<String>(
                get: { addTaskModel[index].taskItems[taskIndex] },
                set: { newValue in addTaskModel[index].taskItems[taskIndex] = newValue }
            )
            
            let isLast = taskIndex == addTaskModel[index].taskItems.count - 1
            let isFirst = taskIndex == 0
            let showRemoveButton = addTaskModel[index].taskItems.count > 1
            
            ListItemView(
                taskItem: taskItemBinding,
                isLast: isLast,
                isFirst: isFirst,
                onAdd: {
                    addingViewModel.addItem(to: &addTaskModel[index].taskItems)
                }, onRemove: {
                    addingViewModel.removeItem(at: taskIndex, from: &addTaskModel[index].taskItems)
                }, showRemoveButton: showRemoveButton
            )
        }
    }


    
    private func onSave(addTaskModel: [AddTaskModel]) {
        addTaskModel.forEach { addTaskModel in
            let updatedItem = AddTaskModel(locationName: locationName, dateTime: Date(), taskItems: addTaskModel.taskItems)
            fdbManager.addTask(updatedItem)
        }
    }  
}




struct ListItemView: View {
    @Binding var taskItem: String
    var isLast: Bool
    var isFirst: Bool
    var onAdd: (() -> Void)?
    var onRemove: (() -> Void)?
    var showRemoveButton: Bool
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 33, height: 33)
                .foregroundColor(.cyan)
                .overlay(Text("A").foregroundColor(.white))
            
            TextField("List item", text: $taskItem)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.leading, 4)
            
            Spacer()
            
            if isLast {
                Button(action: {
                    onAdd?()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .padding(.trailing, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if showRemoveButton  {
                Button(action: {
                    onRemove?()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .padding(.trailing, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 2)
    }
}


struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertViewPreviewWrapper()
    }
    
    struct AlertViewPreviewWrapper: View {
        @State private var showAlert = true
        @StateObject private var viewModel = ListViewModel()
        @State private var geoModel =  GeocodingViewModel()
        
        var body: some View {
            CustomAlertView(isPresented: $showAlert, addTaskModel: $viewModel.taskItems, locationName: $geoModel.addressName)
        }
    }
}

