//
//  ContentView.swift
//  iphonexvi
//
//  Created by Lei Boyang on 2/2/25.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {}
}

struct ContentView: View {
    @State private var brightness: Double = 1.0
    @State private var selectedColor = Color.white
    @State private var showingControls = true
    @State private var captureSession: AVCaptureSession?
    
    let defaultColors: [(String, Color)] = [
        ("Pure White", .white),
        ("Warm", Color(red: 1, green: 0.9, blue: 0.7)),
        ("Cool", Color(red: 0.8, green: 0.9, blue: 1)),
        ("Golden", Color(red: 1, green: 0.85, blue: 0.5)),
        ("Sunset", Color(red: 1, green: 0.8, blue: 0.8)),
        ("Sky", Color(red: 0.7, green: 0.9, blue: 1))
    ]
    
    func getContrastColor(for backgroundColor: Color) -> Color {
        // Simple luminance calculation
        let components = backgroundColor.cgColor?.components ?? [1, 1, 1, 1]
        let luminance = 0.299 * components[0] + 0.587 * components[1] + 0.114 * components[2]
        return luminance > 0.5 ? .black : .white
    }
    
    func setupCaptureSession() {
        guard captureSession == nil else { return }
        
        let session = AVCaptureSession()
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        session.beginConfiguration()
        session.addInput(input)
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
        
        captureSession = session
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
                            if let session = captureSession {
                                CameraPreview(session: session)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                            } else {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                        }
                    
                    VStack {
                        Spacer()
                        Button {
                            takeSnapshot()
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
                .onAppear {
                    setupCaptureSession()
                }
                
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
    
    func takeSnapshot() {
        guard let session = captureSession else { return }
        
        let output = AVCapturePhotoOutput()
        session.beginConfiguration()
        session.addOutput(output)
        session.commitConfiguration()
        
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: PhotoCaptureDelegate())
    }
}

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

#Preview {
    ContentView()
}
