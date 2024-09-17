import SwiftUI
import MapKit

struct AddTaskMapView: View {
    @ObservedObject private var addTaskMapViewModel = AddTaskMapViewModel()
    @State private var showAlert = false
    @ObservedObject private var customAlertListViewModel = CustomAlertListViewModel()
    @ObservedObject private var networkMonitor = NetworkMonitor()
    @State private var showSomethingWentWrong = false
    @State private var addressSelected: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Label {
                    styledText(MapViewString.title.localized, fontSize: 20)
                } icon: {
                    // Icon if needed
                }
                VStack {
                    
                    if !addTaskMapViewModel.errorMessage.isEmpty {
                        ErrorBarView(errorMessage: $addTaskMapViewModel.errorMessage, isPositive: $addTaskMapViewModel.isPositve)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.easeInOut, value: addTaskMapViewModel.errorMessage)
                    }
                    
                    VStack {
                        HStack {
                            HStack {
                                ZStack(alignment: .trailing) {
                                    TextField(MapViewString.searchPlaceholder.localized, text: $addTaskMapViewModel.searchTextFromCustomMap)
                                        .padding(12)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .font(.custom("Avenir", size: 16))
                                        .bold()
                                        .onChange(of: addTaskMapViewModel.searchTextFromCustomMap) {
                                            if addTaskMapViewModel.searchTextFromCustomMap.isEmpty {
                                                addTaskMapViewModel.suggestions.removeAll()
                                            } else {
                                                addTaskMapViewModel.updateSearchSuggestions(query: addTaskMapViewModel.searchTextFromCustomMap)
                                            }
                                        }

                                    if !addTaskMapViewModel.searchTextFromCustomMap.isEmpty {
                                        Button(action: {
                                            addTaskMapViewModel.searchTextFromCustomMap = ""
                                            addTaskMapViewModel.suggestions.removeAll()
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                                .padding(.trailing, 8)
                                                .background(Color(.systemGray6))
                                        }
                                    }
                                }
                                .padding(.horizontal, 8)
                            }
                            Button(action: {
                                if !addTaskMapViewModel.searchTextFromCustomMap.isEmpty {
                                    Task {
                                        await addTaskMapViewModel.searchForPlaces()
                                    }
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.black)
                                    .padding(.trailing, 8)
                                    .bold()
                            }
                            
                            Button(action: {
                                if networkMonitor.isConnected {
                                    showAlert = true
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                } else {
                                    showSomethingWentWrong = true
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.black)
                                    .padding(.trailing, 4)
                                    .bold()
                            }
                        }
                        .padding(.horizontal, 8)
                        
                        // Display address suggestion list if there are suggestions
                        if !addTaskMapViewModel.suggestions.isEmpty {
                            List(addTaskMapViewModel.suggestions, id: \.self) { suggestion in
                                VStack(alignment: .leading) {
                                   Text(suggestion.title)
                                        .font(.custom("Avenir", size: 16))
                                        .bold()
                                    styledText(suggestion.subtitle, fontSize: 14, textColor: .gray)
                                      
                                       
                                }
                                .onTapGesture {
                                    addTaskMapViewModel.searchTextFromCustomMap = "\(suggestion.title), \(suggestion.subtitle)"
                                    addTaskMapViewModel.suggestions.removeAll()
                                    
                                    Task {
                                        await addTaskMapViewModel.searchForPlaces()
                                    }
                                    
                                }
                            }
                            .frame(height: 150)
                            .cornerRadius(20)
                        }
                    }
                }
                .padding()
                
                // Middle section with map
                ZStack {
                    
                    CustomMapView(addTaskMapViewModel: addTaskMapViewModel)
                        .ignoresSafeArea()
                }
                .frame(maxHeight: .infinity)
            }
            
            
            .background(Color.aimTaskBackground)
            
            
            if showAlert {
                CustomAlertView(isPresented: $showAlert,
                                locationName: $addTaskMapViewModel.addressName, addTaskModel: $customAlertListViewModel.taskItems,
                                customAlertViewModel: CustomAlertViewModel(),
                                addTaskMapViewModel: addTaskMapViewModel)
                .transition(.opacity)
                .animation(.easeInOut)
            }
            
            if showSomethingWentWrong {
                SomethingWentWrongView {
                    if networkMonitor.isConnected {
                        showSomethingWentWrong = false
                    }
                }
            }
            
        }
        .onAppear {
            addTaskMapViewModel.fetchTasks()
            addTaskMapViewModel.suggestions.removeAll()
            addTaskMapViewModel.searchTextFromCustomMap = ""
        }
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskMapView()
    }
}
