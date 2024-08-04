import SwiftUI
import MapKit

struct AddTaskView: View {
    @State private var searchText = ""
    @StateObject private var geocodingViewModel = GeocodingViewModel(region: MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -37.86494, longitude: 145.09402),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
   
    
    @State private var showAlert = false
    @StateObject private var viewModel = ListViewModel()
    
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
                        TextField("Enter address", text: $geocodingViewModel.searchText)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        Button(action: {
                            geocodingViewModel.performGeocoding(for: geocodingViewModel.searchText)
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
                
                if !geocodingViewModel.searchResults.isEmpty {
                    List(geocodingViewModel.searchResults, id: \.self) { result in
                        Button(action: {
                            geocodingViewModel.selectCompletion(result)
                            geocodingViewModel.searchText = "\(result.title), \(result.subtitle)"
                            geocodingViewModel.searchResults.removeAll()
                                
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
                    Map(coordinateRegion: $geocodingViewModel.region)
                        .edgesIgnoringSafeArea(.horizontal)
                        .frame(maxHeight: .infinity)
                    
                    // Overlay with buttons
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Button(action: {
                                geocodingViewModel.currentUserLocation()
                            }) {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.primary)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            
                            Spacer().frame(height: 10)
                            
                            VStack {
                                Button(action: {
                                    // Zoom in action
                                    geocodingViewModel.region.span.latitudeDelta /= 2
                                    geocodingViewModel.region.span.longitudeDelta /= 2
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.primary)
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                }
                                
                                Divider().frame(width: 40)
                                
                                Button(action: {
                                    // Zoom out action
                                    geocodingViewModel.region.span.latitudeDelta *= 2
                                    geocodingViewModel.region.span.longitudeDelta *= 2
                                }) {
                                    Image(systemName: "minus")
                                        .foregroundColor(.primary)
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
                
                // Bottom section with background color
                HStack {
                    Spacer()
                }
            }
            .background(Color(red: 105/255, green: 155/255, blue: 157/255))
            
          
            if showAlert {
                CustomAlertView(isPresented: $showAlert, items: $viewModel.items) {
                    print("Items saved:", viewModel.items)
                }
                .transition(.opacity)
                .animation(.easeInOut)
            }
        }
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView()
    }
}
