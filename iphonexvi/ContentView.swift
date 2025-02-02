//
//  ContentView.swift
//  iphonexvi
//
//  Created by Lei Boyang on 2/2/25.
//

import SwiftUI

struct ContentView: View {
    @State private var brightness: Double = 1.0
    @State private var selectedColor = Color.white
    @State private var showingControls = true
    
    var body: some View {
        ZStack {
            // Full screen color background
            selectedColor
                .ignoresSafeArea()
            
            // Brightness overlay
            Color.black
                .opacity(1 - brightness)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showingControls.toggle()
                    }
                }
            
            VStack {
                // Preview window
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black)
                    .frame(width: 200, height: 260)
                    .overlay {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                
                Spacer()
                
                // Controls
                if showingControls {
                    VStack(spacing: 20) {
                        // Brightness control
                        HStack {
                            Image(systemName: "sun.min")
                            Slider(value: $brightness, in: 0...1)
                            Image(systemName: "sun.max")
                        }
                        
                        // Color picker
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
}

#Preview {
    ContentView()
}
