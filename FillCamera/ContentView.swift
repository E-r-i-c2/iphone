//
//  ContentView.swift
//  FillCamera
//
//  Created by Legolas on 2/2/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var backgroundColor: Color = Color(red: 1, green: 0.9, blue: 0.9) // 默认浅粉色
    @State private var brightness: Double = 0.7
    @State private var selectedPreset: PresetLight = .natural
    @State private var isFlashOn: Bool = false
    @State private var selectedFilter: FilterType = .none
    @State private var mirrorMode: Bool = true
    @State private var isCameraActive: Bool = true
    @State private var showCameraPermissionAlert: Bool = false
    
    // 预设的补光方案 - 更新为粉色系
    enum PresetLight: String, CaseIterable {
        case natural = "自然粉"
        case warm = "暖粉色"
        case cool = "冷粉色"
        case peach = "蜜桃粉"
        case custom = "自定义"
        
        var color: Color {
            switch self {
            case .natural: return Color(red: 1, green: 0.9, blue: 0.9)
            case .warm: return Color(red: 1, green: 0.85, blue: 0.85)
            case .cool: return Color(red: 0.95, green: 0.9, blue: 0.95)
            case .peach: return Color(red: 1, green: 0.8, blue: 0.8)
            case .custom: return Color(red: 1, green: 0.9, blue: 0.9)
            }
        }
    }
    
    // 添加滤镜类型
    enum FilterType: String, CaseIterable {
        case none = "原图"
        case smooth = "柔滑"
        case fresh = "清新"
        case warm = "暖阳"
        case cool = "冷淡"
        
        var intensity: Double {
            switch self {
            case .none: return 0
            case .smooth: return 0.3
            case .fresh: return 0.4
            case .warm: return 0.5
            case .cool: return 0.4
            }
        }
    }
    
    var body: some View {
        ZStack {
            // 背景色
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // 取景框移到上方
                ZStack {
                    // 摄像头预览容器
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.1))
                        .frame(width: 300, height: 300)
                    
                    // 相机预览层
                    if isCameraActive {
                        CameraView(isPresented: $isCameraActive)
                            .frame(width: 300, height: 300)
                            .cornerRadius(15)
                            .clipped()
                    } else {
                        // 未开启相机时显示提示
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(red: 1, green: 0.7, blue: 0.7))
                            Text("点击下方相机按钮开启预览")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.4))
                        }
                    }
                }
                .shadow(color: Color(red: 1, green: 0.8, blue: 0.8).opacity(0.3), radius: 15)
                .scaleEffect(mirrorMode ? -1 : 1, anchor: .center)
                
                Spacer()
                
                // 使用新的控制面板
                controlPanel
                
                // 底部提示
                Text("✨ 将手机对准面部，调整距离获得最佳效果 ✨")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.4))
                    .padding(.bottom)
            }
        }
        .brightness(brightness - 1.0)
        .alert("需要相机权限", isPresented: $showCameraPermissionAlert) {
            Button("知道了", role: .cancel) {
                // 用户需要手动去设置里开启权限
            }
        } message: {
            Text("请在系统设置中允许访问相机")
        }
        .onAppear {
            checkCameraPermission()
        }
    }
    
    // 在底部控制面板中添加新功能
    var controlPanel: some View {
        VStack(spacing: 15) {
            // 预设方案选择器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(PresetLight.allCases, id: \.self) { preset in
                        Button(action: {
                            selectedPreset = preset
                            if preset != .custom {
                                backgroundColor = preset.color
                            }
                        }) {
                            Text(preset.rawValue)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(selectedPreset == preset ? 
                                    Color(red: 1, green: 0.7, blue: 0.7).opacity(0.3) : 
                                    Color.clear)
                                .cornerRadius(15)
                        }
                        .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.4))
                    }
                }
                .padding(.horizontal)
            }
            
            Divider()
                .background(Color(red: 1, green: 0.7, blue: 0.7))
            
            // 新增滤镜选择器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(FilterType.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                        }) {
                            VStack {
                                Text(filter.rawValue)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(selectedFilter == filter ? 
                                        Color(red: 1, green: 0.7, blue: 0.7).opacity(0.3) : 
                                        Color.clear)
                                    .cornerRadius(15)
                            }
                        }
                        .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.4))
                    }
                }
                .padding(.horizontal)
            }
            
            // 快捷功能按钮组
            HStack(spacing: 20) {
                // 闪光灯按钮
                Button(action: { isFlashOn.toggle() }) {
                    VStack {
                        Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 20))
                        Text("闪光灯")
                            .font(.caption2)
                    }
                }
                
                // 相机按钮
                Button(action: {
                    checkCameraPermission()
                }) {
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 1, green: 0.4, blue: 0.4))
                        Text("相机")
                            .font(.caption2)
                    }
                }
                
                // 镜像按钮
                Button(action: { mirrorMode.toggle() }) {
                    VStack {
                        Image(systemName: mirrorMode ? "arrow.left.and.right.righttriangle.left.righttriangle.right.fill" : "arrow.left.and.right.righttriangle.left.righttriangle.right")
                            .font(.system(size: 20))
                        Text("镜像")
                            .font(.caption2)
                    }
                }
            }
            .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.4))
            .padding(.vertical, 5)
            
            // 自定义颜色选择器
            if selectedPreset == .custom {
                ColorPicker("自定义颜色", selection: $backgroundColor)
                    .padding(.horizontal)
                    .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.4))
            }
            
            // 亮度调节
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "sun.min.fill")
                        .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.4))
                    Slider(value: $brightness, in: 0.3...1.0)
                        .tint(Color(red: 1, green: 0.7, blue: 0.7))
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.4))
                }
                Text("亮度调节")
                    .font(.caption)
                    .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.4))
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(red: 1, green: 0.95, blue: 0.95))
        .cornerRadius(20)
        .shadow(color: Color(red: 1, green: 0.8, blue: 0.8).opacity(0.5), radius: 10)
        .padding()
    }
    
    // 修改权限检查函数
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraActive = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        isCameraActive = true
                    }
                }
            }
        case .denied, .restricted:
            showCameraPermissionAlert = true
            isCameraActive = false
        @unknown default:
            isCameraActive = false
        }
    }
}

// 更新取景框四角的装饰bracket颜色
struct CornerBracket: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: -135, y: -135))
            path.addLine(to: CGPoint(x: -135, y: -115))
            path.move(to: CGPoint(x: -135, y: -135))
            path.addLine(to: CGPoint(x: -115, y: -135))
        }
        .stroke(Color(red: 1, green: 0.7, blue: 0.7).opacity(0.8), lineWidth: 2)
    }
}

// 添加相机视图
struct CameraView: View {
    @Binding var isPresented: Bool
    @StateObject private var camera = CameraModel()
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                CameraPreviewView(camera: camera)
                    .onAppear {
                        camera.start()
                    }
                    .onDisappear {
                        camera.stop()
                    }
            }
            
            // 添加拍照按钮
            VStack {
                Spacer()
                Button(action: {
                    camera.takePhoto()
                }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                .stroke(Color.pink, lineWidth: 2)
                                .frame(width: 60, height: 60)
                        )
                }
                .padding(.bottom, 20)
            }
        }
    }
}

// 添加相机预览视图
struct CameraPreviewView: UIViewRepresentable {
    let camera: CameraModel
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.bounds
        camera.preview.videoGravity = .resizeAspectFill
        camera.preview.cornerRadius = 15
        
        camera.preview.connection?.videoOrientation = .portrait
        
        view.layer.addSublayer(camera.preview)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            camera.preview.frame = uiView.bounds
            camera.preview.connection?.videoOrientation = .portrait
        }
    }
}

// 修改 CameraModel 类定义
class CameraModel: NSObject, ObservableObject {
    var session = AVCaptureSession()
    var preview: AVCaptureVideoPreviewLayer!
    private var photoOutput = AVCapturePhotoOutput()
    
    override init() {
        super.init()
        // 如果需要在初始化时做一些设置，可以在这里添加
    }
    
    func start() {
        setupCamera()
    }
    
    func stop() {
        session.stopRunning()
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func setupCamera() {
        do {
            session.beginConfiguration()
            
            // 使用前置摄像头
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, 
                                                     for: .video,
                                                     position: .front) else {
                print("无法访问前置摄像头")
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            // 添加照片输出
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
            
            // 设置视频质量
            session.sessionPreset = .high
            
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
            
        } catch {
            print("相机设置错误: \(error.localizedDescription)")
        }
    }
}

// 让 CameraModel 遵循 AVCapturePhotoCaptureDelegate 协议
extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {
            // 保存照片到相册
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
        }
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("保存失败: \(error.localizedDescription)")
        } else {
            print("照片已保存到相册")
        }
    }
}

#Preview {
    ContentView()
}
