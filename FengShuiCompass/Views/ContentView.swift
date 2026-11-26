//
//  ContentView.swift
//  上 2/3 盘面 · 下 1/3 实时说明
//

import SwiftUI

struct ContentView: View {

    @StateObject private var compass = HeadingService()
    private let rings = CompassData.build()

    @State private var autoMode = true
    @State private var manualAngle: Double = 0
    @State private var zoom: CGFloat = 1
    @State private var lastZoom: CGFloat = 1
    @State private var declination: Double = -9.5
    @State private var toast: String? = nil

    private var plateAngle: Double {
        autoMode ? compass.magneticHeading : manualAngle
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                plateArea(height: geo.size.height * 2 / 3)
                ReadoutPanel(rings: rings, angle: plateAngle,
                             declination: $declination)
                    .frame(height: geo.size.height / 3)
            }
            .background(Color(hex: 0x0B0906))
            .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
        .onAppear { compass.start() }
        .onDisappear { compass.stop() }
    }

    // MARK: - 盘面区

    private func plateArea(height: CGFloat) -> some View {
        ZStack {
            RadialGradient(colors: [Color(hex: 0x17110A), Color(hex: 0x0B0906)],
                           center: .top, startRadius: 20, endRadius: height * 1.2)

            ZStack {
                PlateCanvas(rings: rings, detail: zoom >= 1.25)
                NeedleView()
            }
            .aspectRatio(1, contentMode: .fit)
            .rotationEffect(.degrees(-plateAngle))
            .scaleEffect(zoom)

            CrosshairView()
                .aspectRatio(1, contentMode: .fit)
                .allowsHitTesting(false)

            VStack {
                topBar
                Spacer()
                hud
            }
            .padding(.horizontal, 14)

            if let toast {
                Text(toast)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(hex: 0xEFE6D4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: 0x0E0A06).opacity(0.92)))
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.89, green: 0.73, blue: 0.41).opacity(0.22), lineWidth: 1))
                    .frame(maxWidth: 260)
            }
        }
        .frame(height: height)
        .clipped()
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 6)
                .onChanged { value in
                    if autoMode {
                        manualAngle = compass.magneticHeading
                        autoMode = false
                    }
                    manualAngle = manualAngle - Double(value.translation.width) * 0.55
                }
                .onEnded { _ in
                    manualAngle = CompassRing.norm(manualAngle)
                }
        )
        .simultaneousGesture(
            MagnificationGesture()
                .onChanged { v in
                    zoom = min(3.6, max(1, lastZoom * v))
                }
                .onEnded { _ in lastZoom = zoom }
        )
    }

    private var topBar: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("掌上羅盤")
                    .font(.custom("SongtiSC-Regular", size: 15))
                    .tracking(3)
                    .foregroundStyle(Color(hex: 0xF8E2A6).opacity(0.92))
                Text("综合盘 · 三十一圈层")
                    .font(.system(size: 9))
                    .tracking(1.6)
                    .foregroundStyle(Color(hex: 0xA89F8C))
            }

            Spacer()

            Button {
                toggleMode()
            } label: {
                Text(autoMode ? "自动指北" : "手动转盘")
                    .font(.system(size: 11, weight: autoMode ? .semibold : .regular))
                    .tracking(1)
                    .foregroundStyle(autoMode ? Color(hex: 0x0B0906) : Color(hex: 0xE3BB69))
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(
                        Capsule().fill(autoMode
                                       ? LinearGradient(colors: [Color(hex: 0xF5D98F), Color(hex: 0xCFA14A)],
                                                        startPoint: .top, endPoint: .bottom)
                                       : LinearGradient(colors: [Color(hex: 0x140F09), Color(hex: 0x140F09)],
                                                        startPoint: .top, endPoint: .bottom))
                    )
                    .overlay(Capsule().stroke(Color(red: 0.89, green: 0.73, blue: 0.41).opacity(0.5),
                                              lineWidth: 1))
            }
        }
        .padding(.top, 8)
    }

    private var hud: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "磁 %.1f°", CompassRing.norm(plateAngle)))
                Text(String(format: "真 %.1f°", CompassRing.norm(plateAngle - declination)))
                Text(String(format: "%@ · %.1fx", autoMode ? "自动指北" : "手动转盘", zoom))
            }
            .font(.system(size: 10))
            .foregroundStyle(Color(hex: 0xA89F8C))
            .padding(.horizontal, 9).padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: 0x0E0A06).opacity(0.66)))
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 0.89, green: 0.73, blue: 0.41).opacity(0.14), lineWidth: 1))

            Spacer()

            HStack(spacing: 6) {
                zoomButton("−") { zoom = max(1, zoom - 0.25); lastZoom = zoom }
                zoomButton("+") { zoom = min(3.6, zoom + 0.25); lastZoom = zoom }
                zoomButton("⌖") { zoom = 1; lastZoom = 1 }
            }
        }
        .padding(.bottom, 10)
    }

    private func zoomButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(Color(hex: 0xE3BB69))
                .frame(width: 34, height: 34)
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: 0x120D08).opacity(0.78)))
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(red: 0.89, green: 0.73, blue: 0.41).opacity(0.22), lineWidth: 1))
        }
    }

    // MARK: - 模式

    private func toggleMode() {
        if autoMode {
            autoMode = false
            show("已切换手动转盘：单指拖动盘面")
            return
        }
        if compass.hasHeading {
            autoMode = true
            show("自动指北已开启：请平端手机，远离磁性物体")
        } else {
            compass.start()
            autoMode = true
            show("正在获取磁航向；若长时间无读数，请检查定位授权或到室外重试")
        }
    }

    private func show(_ text: String) {
        withAnimation { toast = text }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation { toast = nil }
        }
    }
}

// MARK: - 预览

#Preview {
    ContentView()
}
