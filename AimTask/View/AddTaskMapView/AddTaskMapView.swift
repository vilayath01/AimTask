import SwiftUI
import MapKit

struct AddTaskMapView: View {
    @ObservedObject private var addTaskMapViewModel = AddTaskMapViewModel()
    @State private var showAlert = false
    @ObservedObject private var customAlertListViewModel = CustomAlertListViewModel()
    @State private var addressSelected: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Label {
                    Text("Add Task").bold()
                } icon: {
                    // Icon if needed
                }
                
                HStack {
                    HStack {
                        TextField("Enter address", text: $addTaskMapViewModel.searchText)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .onChange(of: addTaskMapViewModel.searchText) { newValue in
                                if newValue.isEmpty {
                                    addTaskMapViewModel.searchResults.removeAll()
                                    addressSelected = false
                                }
                            }
                        Button(action: {
                            if !addTaskMapViewModel.searchText.isEmpty {
                                addTaskMapViewModel.searchResults.removeAll()
                                addTaskMapViewModel.performGeocoding(for: addTaskMapViewModel.searchText)
                            }
                            
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.primary)
                                .padding(.trailing, 8)
                        }
                        
                    }
                    .padding(.horizontal, 8)
                    
                    Button(action: {
                        showAlert = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.primary)
                            .padding(.trailing, 4)
                    }
                }
                .padding()
                
                if !addTaskMapViewModel.searchResults.isEmpty && !addressSelected {
                    
                    List(addTaskMapViewModel.searchResults, id: \.self) { result in
                        Button(action: {
                            addTaskMapViewModel.selectCompletion(result)
                            addTaskMapViewModel.searchResults.removeAll()
                            addressSelected = true
                        }) {
                            VStack(alignment: .leading) {
                                Text(result.title).font(.headline)
                                Text(result.subtitle).font(.subheadline).foregroundColor(.gray)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .frame(maxHeight: 200)
                }

                // Middle section with map
                ZStack {
                    
                    CustomMapView(addTaskMapViewModel: addTaskMapViewModel)
                    .ignoresSafeArea()
                }
                
                HStack {
                    Spacer()
                }
            }
            .background(Color(red: 105/255, green: 155/255, blue: 157/255))
            
            
            if showAlert {
                CustomAlertView(isPresented: $showAlert,
                                locationName: $addTaskMapViewModel.addressName, addTaskModel: $customAlertListViewModel.taskItems,
                                customAlertViewModel: CustomAlertViewModel(),
                                addTaskMapViewModel: addTaskMapViewModel)
                .transition(.opacity)
                .animation(.easeInOut)
            }
            
        }
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskMapView()
    }
}
