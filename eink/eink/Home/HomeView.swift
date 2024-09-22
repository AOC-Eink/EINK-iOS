//
//  HomeView.swift
//  eink
//
//  Created by Aaron on 2024/9/4.
//

import SwiftUI

struct HomeView: View {
    
//    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.appRouter) var appRouter

//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
    
    let device:Device
    let desgins:[InkDesign]
    
    var body: some View {
        home
    }
    
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
    
    @ViewBuilder
    var home: some View {
        NavigationStack {
            ScrollView {
                VStack{
                    SliderView(images: device.deviceType.guideImage)
                    PresetGridView(device: device, designs: desgins, pageType: .preset)
                }
            }
            .navigationTitle(device.deviceName)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        appRouter.isConnected?.toggle()
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.plusbutton)
                    }
                }
//                ToolbarItem(placement: .principal) {
//                    Text(device.deviceName) // 设置导航栏的自定义标题
//                        .font(.title)
//                        .foregroundStyle(.mydevicestitle)
//                        
//                }
            }
        }
    }
}

#Preview {
    HomeView(device: DeviceManager().devices.first!, desgins: [])
}

//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()

