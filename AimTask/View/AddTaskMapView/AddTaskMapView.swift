import SwiftUI
import MapKit

struct AddTaskMapView: View {
    @ObservedObject private var addTaskMapViewModel = AddTaskMapViewModel()
    @State private var showAlert = false
    @ObservedObject private var customAlertListViewModel = CustomAlertListViewModel()
    @State private var addressSelected: Bool = false
    @StateObject private var fdbManager = FDBManager()
    
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
                    Map(coordinateRegion: $addTaskMapViewModel.region, showsUserLocation: true, annotationItems: [addTaskMapViewModel.region.center]) { location in
                        MapMarker(coordinate: location, tint: .red)
                    }
                    .edgesIgnoringSafeArea(.horizontal)
                    .frame(maxHeight: .infinity)
                    
                    // Overlay with buttons
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Button(action: {
                                addTaskMapViewModel.centerOnUserLocation()
                            }) {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            
                            Spacer().frame(height: 10)
                            
                            VStack {
                                Button(action: {
                                    // Zoom in action
                                    addTaskMapViewModel.zoomInOption()
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.black)
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                }
                                
                                Divider().frame(width: 40)
                                
                                Button(action: {
                                    // Zoom out action
                                    addTaskMapViewModel.zoomOutOption()
                                    
                                }) {
                                    Image(systemName: "minus")
                                        .foregroundColor(.black)
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                }
                            }
                            .background(Color.clear)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        }
                        .padding()
                    }
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
