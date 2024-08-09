import SwiftUI

struct CustomAlertView: View {
    @Binding var isPresented: Bool
    @Binding var items: [ListItem]
    @ObservedObject var addingViewModel = AddingViewModel()
    var taskViewModel = TaskViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add task Items @ Location Name")
                .font(.headline)
                .foregroundColor(Color.black)
            
            List {
                ForEach($items.indices, id: \.self) { index in
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
                    onSave(items)
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
        ListItemView(
            item: $items[index],
            isLast: index == items.count - 1,
            isFirst: index == 0,
            onAdd: {
                addingViewModel.addItem(to: &items)
            },
            onRemove: {
                addingViewModel.removeItem(at: index, from: &items)
            },
            showRemoveButton: items.count > 1
        )
    }
    var onSave: ([ListItem]) -> Void = { items in
        items.forEach { item in
            TaskViewModel().addListItem(item)
        }
        
    }
    
}




struct ListItemView: View {
    @Binding var item: ListItem
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
                .overlay(Text(item.letter?.prefix(1) ?? "A").foregroundColor(.white))
            
            TextField("List item", text: $item.text)
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
        
        var body: some View {
            CustomAlertView(isPresented: $showAlert, items: $viewModel.items) {_ in
                // Handle save action for preview
                print("Items saved in preview:", viewModel.items)
            }
        }
    }
}

