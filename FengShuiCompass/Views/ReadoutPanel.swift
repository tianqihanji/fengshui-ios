//
//  ReadoutPanel.swift
//  下部 1/3：随盘面刻度滚动的实时方位说明
//

import SwiftUI

struct ReadoutPanel: View {
    let rings: [CompassRing]
    let angle: Double            // 当前刻度（磁方位）
    @Binding var declination: Double
    @State private var expandedKey: String? = nil

    private var norm: Double { CompassRing.norm(angle) }

    private var shanIndex: Int {
        Int(floor(CompassRing.norm(norm + 7.5) / 15.0)) % 24
    }

    private var shan: String { Pan.shan[shanIndex] }
    private var shanWx: String { Pan.shanWuxing[shanIndex] }
    private var yinYang: String { Pan.yinYang[shanIndex] }
    private var gua: String { Pan.houtian[Int(round(norm / 45.0)) % 8] }
    private var xianGua: String { Pan.xiantian[Int(round(norm / 45.0)) % 8] }

    private var xiuName: String {
        rings.first(where: { $0.key == "xiu" })?.value(at: norm) ?? ""
    }
    private var gua64: String {
        rings.first(where: { $0.key == "g64" })?.value(at: norm) ?? ""
    }

    private var direction8: String {
        ["正北","东北","正东","东南","正南","西南","正西","西北"][Int(round(norm / 45.0)) % 8]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            chips
            Divider().overlay(Color(red: 0.89, green: 0.73, blue: 0.41).opacity(0.12))
            rowsList
            declinationBar
        }
        .background(LinearGradient(colors: [Color(hex: 0x141009), Color(hex: 0x0A0805)],
                                   startPoint: .top, endPoint: .bottom))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color(red: 0.89, green: 0.73, blue: 0.41).opacity(0.28))
                .frame(height: 1)
        }
    }

    // MARK: - 头部

    private var header: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Text(shan)
                .font(.custom("SongtiSC-Bold", size: 34))
                .foregroundStyle(Color(hex: 0xF8E2A6))
                .shadow(color: Color(red: 0.89, green: 0.73, blue: 0.41).opacity(0.45), radius: 10)

            VStack(alignment: .leading, spacing: 3) {
                Text("\(shan)山 · \(direction8) · \(yinYang) · 五行\(shanWx) · 后天\(gua)卦 · 先天\(xianGua)卦")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: 0xA89F8C))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(String(format: "磁 %.1f°　真 %.1f°　宿 %@　卦 %@",
                            norm, CompassRing.norm(norm - declination), xiuName, gua64))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(hex: 0xE3BB69))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                chip(direction8)
                chip("五行 \(shanWx)")
                chip("\(yinYang)山")
                chip("\(gua)卦")
                chip("\(xiuName)")
                chip("\(gua64)卦")
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 24)
        .padding(.bottom, 2)
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10))
            .foregroundStyle(Color(hex: 0xD9CBA9))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(RoundedRectangle(cornerRadius: 6)
                .fill(Color(red: 0.89, green: 0.73, blue: 0.41).opacity(0.06)))
            .overlay(RoundedRectangle(cornerRadius: 6)
                .stroke(Color(red: 0.89, green: 0.73, blue: 0.41).opacity(0.18), lineWidth: 1))
    }

    // MARK: - 圈层读数

    private var rowsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(rings.enumerated()), id: \.element.id) { idx, ring in
                    row(ring: ring, odd: idx % 2 == 0)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }

    private func row(ring: CompassRing, odd: Bool) -> some View {
        let isOpen = expandedKey == ring.key
        let value = ring.value(at: norm)
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color(hue: ring.hue / 360,
                                saturation: max(0.45, (ring.sat + 20) / 100),
                                brightness: min(0.72, (ring.bright + 34) / 100)))
                    .frame(width: 6, height: 6)

                Text(ring.name)
                    .font(.system(size: 11))
                    .foregroundStyle(ring.isMain ? Color(hex: 0xE3BB69) : Color(hex: 0x8D8474))
                    .lineLimit(1)

                Spacer(minLength: 6)

                Text(value.isEmpty ? "—" : value)
                    .font(.custom("SongtiSC-Regular", size: ring.isMain ? 15 : 13))
                    .foregroundStyle(ring.isMain ? Color(hex: 0xF8E2A6) : Color(hex: 0xF0E7D4))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 6)
            .background(RoundedRectangle(cornerRadius: 7)
                .fill(isOpen
                      ? Color(red: 0.89, green: 0.73, blue: 0.41).opacity(0.14)
                      : (odd ? Color.white.opacity(0.018) : Color.clear)))

            if isOpen {
                Text(ring.desc)
                    .font(.system(size: 11))
                    .foregroundStyle(Color(hex: 0x9B917E))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.18)) {
                expandedKey = isOpen ? nil : ring.key
            }
        }
    }

    // MARK: - 磁偏角

    private var declinationBar: some View {
        HStack(spacing: 10) {
            Text("磁偏角")
                .font(.system(size: 10.5))
                .foregroundStyle(Color(hex: 0x8D8474))

            Slider(value: $declination, in: -30...30, step: 0.1)
                .tint(Color(red: 0.85, green: 0.68, blue: 0.34))

            Text(String(format: "%+.1f°", declination))
                .font(.custom("SongtiSC-Regular", size: 11))
                .foregroundStyle(Color(hex: 0xE3BB69))
                .frame(width: 48, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color(red: 0.89, green: 0.73, blue: 0.41).opacity(0.10))
                .frame(height: 1)
        }
    }
}
