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
    let designs:[Design]
    let customDesigns:[Design]
    @State private var showBottomSheet = false
    
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
                    //SliderView(images: device.deviceType.guideImage)
                    
                    
                    
                    PresetGridView(device: device, designs: designs, pageType: .preset, sectionName: "Preset pattern")
                    
                    PresetGridView(device: device, designs: customDesigns, pageType: .preset, sectionName: "Custom pattern")
                    
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showBottomSheet.toggle()
                    
                    }) {
                        Image(systemName: "play.circle")
                            .foregroundColor(.plusbutton)
                    }
                }
            }
        }
        .sheet(isPresented: $showBottomSheet) {
            PlaybackView(device: device, designs: designs + customDesigns, showBottomSheet: $showBottomSheet)
        }
    }
}

#Preview {
    HomeView(device: DeviceManager().showDevices.first!, designs: [], customDesigns: [])
}

//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()

