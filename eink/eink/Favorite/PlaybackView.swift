//
//  PlaybackView.swift
//  eink
//
//  Created by Aaron on 2024/10/12.
//

import SwiftUI
import AlertToast
enum PlaybackMode {
    case singlePlayback
    case allPlayback
    case randomPlayback
}

struct PlaybackView: View {
    
    let device:Device
    let designs:[Design]
    @Binding var showBottomSheet:Bool
    @State private var showToast = false
    
    @State private var isToggleOn = true
    @State private var selectedMinutes = 0
    @State private var selectedSeconds = 0
    @State private var selectedMode: PlaybackMode = .singlePlayback
    
    var body: some View {
        VStack(spacing: 20) {
            deviceInfoSection
            controlButtonsSection
            scheduledPlaybackSection
            timePickerSection
            actionButtonsSection
        }
        .padding()
        .padding(.top, 10)
        .background(.white)
        .toast(isPresenting: $showToast, duration: 1, alert: {
            AlertToast(type: .systemImage("checkmark.circle", .opButton), title: "Message Sent!")
        }, completion: {
            showToast = false
            showBottomSheet.toggle()
        })
        
        
    }
    
    var totalSeconds:Int {
        selectedMinutes*60 + selectedSeconds
    }
    
    private var deviceInfoSection: some View {
        HStack{
            
            Image(device.deviceImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 20, height: 20)
                .background(.deviceItemShadow)
            VStack(alignment: .leading, spacing: 5) {
                Text("Current playback device")
                    .font(.headline)
                Text(device.deviceName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
    }
    
    private var controlButtonsSection: some View {
        HStack {
//            ForEach([
//                   (PlaybackMode.singlePlayback, "arrow.clockwise"),
//                   (PlaybackMode.allPlayback, "arrow.2.circlepath"),
//                   (PlaybackMode.randomPlayback, "arrow.right.arrow.left")
//               ], id: \.0) { mode, iconName in
//                   Button(action: {
//                       selectedMode = mode
//                   }) {
//                       Image(systemName: iconName)
//                           .foregroundColor(selectedMode == mode ? .white : .gray)
//                           .frame(width: 50, height: 30)
//                           .background(selectedMode == mode ? .opButton : .white)
//                           .cornerRadius(20)
//                           .shadow(color: .deviceItemShadow, radius: 2, x: 0, y: 0)
//                   }
//               }
            Text("Show")
                .font(.sectionBoldTitle)
            Spacer()
            Toggle("", isOn: $isToggleOn)
                .labelsHidden()
                .toggleStyle(ColoredToggleStyle())
                
        }
    }
    
    private var scheduledPlaybackSection: some View {
        Text("Scheduled playback")
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var timePickerSection: some View {
        HStack(spacing: 20) {
            timePicker(for: $selectedMinutes, label: "min")
            Text("|").foregroundColor(.gray)
            timePicker(for: $selectedSeconds, label: "s")
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func timePicker(for binding: Binding<Int>, label: String) -> some View {
        VStack {
            Text(label)
                .font(.sectionBoldTitle)
                .foregroundColor(.gray)
            Picker("", selection: binding) {
                ForEach(0..<60) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 100)
            .clipped()
        }
        .padding()
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing:40) {
            CustomButton(title: "Cancel", bgColor: .deviceItemShadow) {
                showBottomSheet.toggle()
            }

            CustomButton(title: "Confirm", bgColor: .opButton) {
                if showToast { return }
                showToast.toggle()
                
                Task {
                    await device.deviceFuction?.sendTestPlayColors(device, designs: designs, gapTime: totalSeconds, isShow: isToggleOn)
                }
                
            }
        }
    }
}
    


struct ColoredToggleStyle: ToggleStyle {
    var onColor: Color = .opButton
    var offColor: Color = .deviceItemShadow
    var thumbColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            RoundedRectangle(cornerRadius: 16, style: .circular)
                .fill(configuration.isOn ? onColor : offColor)
                .frame(width: 50, height: 29)
                .overlay(
                    Circle()
                        .fill(thumbColor)
                        .shadow(radius: 1, x: 0, y: 1)
                        .padding(1.5)
                        .offset(x: configuration.isOn ? 10 : -10)
                )
                .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PlaybackView(device: Device(indentify: "", deviceName: "EINK Phone Case"), designs: [], showBottomSheet: .constant(true))
}
