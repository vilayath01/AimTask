import SwiftUI
import CoreLocation

struct CustomAlertView: View {
    @Binding var isPresented: Bool
    @Binding var addTaskModel: [TaskModel]
    @ObservedObject var customAlertViewModel = CustomAlertViewModel()
    @StateObject var geocodingViewModel = AddTaskMapViewModel()
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
            
            CustomAlertListView(
                taskItem: taskItemBinding,
                isLast: isLast,
                isFirst: isFirst,
                onAdd: {
                    customAlertViewModel.addItem(to: &addTaskModel[index].taskItems)
                }, onRemove: {
                    customAlertViewModel.removeItem(at: taskIndex, from: &addTaskModel[index].taskItems)
                }, showRemoveButton: showRemoveButton
            )
        }
    }
    
    private func onSave(addTaskModel: [TaskModel]) {
        let selectedLocation = geocodingViewModel.region.center
        addTaskModel.forEach { model in
            let updatedItem = TaskModel(locationName: locationName, dateTime: Date(), taskItems: model.taskItems, coordinate: selectedLocation, documentID: "")
            fdbManager.addTask(updatedItem)
        }
        fdbManager.fetchTasks()
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
            CustomAlertView(isPresented: $showAlert, addTaskModel: $viewModel.taskItems, locationName: $geoModel.addressName)
        }
    }
}
