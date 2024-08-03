import SwiftUI

struct CustomAlertView: View {
    @Binding var isPresented: Bool
    @Binding var items: [ListItem]
   @ObservedObject var addingViewModel = AddingViewModel()
    
    
    var onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add task Items @ Location Name")
                .font(.headline)
            
            List {
                ForEach($items.indices, id: \.self) { index in
                    ListItemView(item: $items[index], isLast: index == items.count - 1) {
                       addingViewModel.addItem()
                    }
                    
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
                    onSave()
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
        
}



struct ListItemView: View {
    @Binding var item: ListItem
   @ObservedObject var addingViewModel = AddingViewModel()
    var isLast: Bool
    var onAdd: (() -> Void)?
    
    var body: some View {
        HStack {
            Circle()
                .frame(width: 33, height: 33)
                .foregroundColor(.cyan)
                .overlay(Text(addingViewModel.alphabet(for: addingViewModel.getIndex(of: item.id))).foregroundColor(.white))
            
            TextField("List item", text: $item.text)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.leading, 4)
            
            Spacer()
            
            if isLast {
                Button(action: {
                    onAdd!()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
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

        var body: some View {
            CustomAlertView(isPresented: $showAlert, items: $viewModel.items) {
                // Handle save action for preview
                print("Items saved in preview:", viewModel.items)
            }
        }
    }
}

