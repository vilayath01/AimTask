import SwiftUI
import CoreLocation

struct CustomAlertView: View {
    @Binding var isPresented: Bool
    @Binding var locationName: String
    @Binding var addTaskModel: [TaskModel]
    @ObservedObject var customAlertViewModel: CustomAlertViewModel
    @ObservedObject var addTaskMapViewModel: AddTaskMapViewModel
    
    var fdbManager = FDBManager()
    
    var body: some View {
        VStack(spacing: 20) {
            styledText(CustomAlertString.localized(CustomAlertString.addTaskItem.localized, locationName), fontSize: 20)
                
            
            List {
                ForEach($addTaskModel.indices, id: \.self) { index in
                    createListItemView(for: index)
                }
            }
            .frame(maxHeight: 250)
            .cornerRadius(16)
            
            HStack {
                Spacer()
                
                Button(CustomAlertString.cancel.localized) {
                    isPresented = false
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.trailing)
                
                Button(CustomAlertString.save.localized) {
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
        .background(Color(red: 105/255, green: 155/255, blue: 157/255))
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
    }
    
    @ViewBuilder
    private func createListItemView(for index: Int) -> some View {
        // Make sure the array exists and isn't modified during iteration
        let taskItems = addTaskModel[index].taskItems
        
        ForEach(taskItems.indices, id: \.self) { taskIndex in
            let taskItemBinding = Binding<String>(
                get: { addTaskModel[index].taskItems[safe: taskIndex] ?? ""  },
                set: { newValue in
                    if taskIndex < addTaskModel[index].taskItems.count {
                        addTaskModel[index].taskItems[taskIndex] = newValue
                    }
                }
            )
            
            let isLast = taskIndex == addTaskModel[index].taskItems.count - 1
            let isFirst = taskIndex == 0
            let showRemoveButton = addTaskModel[index].taskItems.count > 1
            
            CustomAlertListView(
                taskItem: taskItemBinding,
                isLast: isLast,
                isFirst: isFirst,
                onAdd: {
                    customAlertViewModel.addItem(to: &addTaskModel[index].taskItems)
                },
                onRemove: {
                    if taskIndex < addTaskModel[index].taskItems.count {
                        // Ensure the index is safe to remove
                        customAlertViewModel.removeItem(at: taskIndex, from: &addTaskModel[index].taskItems)
                    } else {
                        print("Index out of bounds during removal.")
                    }
                },
                showRemoveButton: showRemoveButton
            )
        }
        .onAppear {
            customAlertViewModel.removeAllButOneItem(from: &addTaskModel[index].taskItems)
        }
    }
    
    private func onSave(addTaskModel: [TaskModel]) {
        let selectedLocation = addTaskMapViewModel.regionFromViewModel.center
        guard !(selectedLocation.latitude == 0.0 && selectedLocation.longitude == 0.0) else {
            return
        }
        addTaskModel.forEach { model in
            let updatedItem = TaskModel(
                locationName: locationName,
                dateTime: Date(),
                taskItems: model.taskItems,
                coordinate: selectedLocation,
                documentID: "",
                enteredGeofence: model.enteredGeofence,
                saveHistory: model.saveHistory
            )
            fdbManager.addTask(updatedItem)
        }
        
        addTaskMapViewModel.searchTextFromCustomMap = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            fdbManager.fetchTasks()
            addTaskMapViewModel.fetchTasks()
        }
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertViewPreviewWrapper()
    }
    
    struct AlertViewPreviewWrapper: View {
        @State private var showAlert = true
        @StateObject private var viewModel = CustomAlertListViewModel()
        @State private var geoModel =  AddTaskMapViewModel()
        
        var body: some View {
            CustomAlertView(isPresented: $showAlert, locationName: $geoModel.addressName, addTaskModel: $viewModel.taskItems, customAlertViewModel: CustomAlertViewModel(), addTaskMapViewModel: geoModel)
        }
    }
}
