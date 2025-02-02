//
//  ContentView.swift
//  iphonexvi
//
//  Created by Lei Boyang on 2/2/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var brightness: Double = 1.0
    @State private var selectedColor = Color.white
    @State private var showingControls = true
    
    let defaultColors: [(String, Color)] = [
        ("Pure White", .white),
        ("Warm", Color(red: 1, green: 0.9, blue: 0.7)),
        ("Cool", Color(red: 0.8, green: 0.9, blue: 1)),
        ("Golden", Color(red: 1, green: 0.85, blue: 0.5)),
        ("Sunset", Color(red: 1, green: 0.8, blue: 0.8)),
        ("Sky", Color(red: 0.7, green: 0.9, blue: 1))
    ]
    
    func getContrastColor(for backgroundColor: Color) -> Color {
        let components = backgroundColor.cgColor?.components ?? [1, 1, 1, 1]
        let luminance = 0.299 * components[0] + 0.587 * components[1] + 0.114 * components[2]
        return luminance > 0.5 ? .black : .white
    }
    
    var body: some View {
        ZStack {
            selectedColor
                .ignoresSafeArea()
            
            Color.black
                .opacity(1 - brightness)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showingControls.toggle()
                    }
                }
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.black)
                        .frame(width: 200, height: 260)
                        .overlay {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                    
                    VStack {
                        Spacer()
                        Button {
                            takeQuickSnapshot()
                        } label: {
                            Image(systemName: "camera.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.5)))
                        }
                        .padding(.bottom, 10)
                    }
                }
                .frame(width: 200, height: 260)
                .padding(.top, 40)
                
                Spacer()
                
                if showingControls {
                    VStack(spacing: 20) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(defaultColors, id: \.0) { name, color in
                                    Button {
                                        selectedColor = color
                                    } label: {
                                        VStack {
                                            Circle()
                                                .fill(color)
                                                .frame(width: 60, height: 60)
                                                .overlay(
                                                    Circle()
                                                        .stroke(.white, lineWidth: selectedColor == color ? 3 : 0)
                                                )
                                                .shadow(radius: 3)
                                            Text(name)
                                                .font(.caption)
                                                .foregroundColor(getContrastColor(for: color))
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                        }
                        .frame(height: 100)
                        
                        HStack {
                            Image(systemName: "sun.min")
                            Slider(value: $brightness, in: 0...1)
                            Image(systemName: "sun.max")
                        }
                        
                        ColorPicker("Screen Color", selection: $selectedColor)
                            .labelsHidden()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                    .padding()
                }
            }
        }
    }
    
    func takeQuickSnapshot() {
        let session = AVCaptureSession()
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        let output = AVCapturePhotoOutput()
        session.addInput(input)
        session.addOutput(output)
        
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: QuickPhotoCapture())
    }
}

class QuickPhotoCapture: NSObject, AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

#Preview {
    ContentView()
}
