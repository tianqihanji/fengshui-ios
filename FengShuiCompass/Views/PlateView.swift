//
//  PlateView.swift
//  盘面绘制：31 圈层 + 天池 + 分金/宿度/卦气
//

import SwiftUI

struct PlateCanvas: View {
    let rings: [CompassRing]
    var detail: Bool = false          // false = 远观层（只刻疏圈文字）

    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            let R = min(size.width, size.height) / 2 - 4
            let rTC = R * 0.152
            let rIn0 = rTC + R * 0.0145
            let rOut = R * 0.9767

            // 底盘
            ctx.fill(Path(ellipseIn: CGRect(x: cx - R, y: cy - R, width: R * 2, height: R * 2)),
                     with: .radialGradient(
                        Gradient(colors: [Color(hex: 0x2B2316), Color(hex: 0x1E1810),
                                          Color(hex: 0x15100A), Color(hex: 0x0C0906)]),
                        center: .init(x: cx, y: cy), startRadius: rTC * 0.2, endRadius: R))

            // 半径分配
            let weights = rings.map { weightOf($0) }
            let totalW = weights.reduce(0, +)
            let span = rOut - rIn0
            var acc = rIn0
            var bounds: [(Double, Double)] = []
            for w in weights {
                let b = acc + span * w / totalW
                bounds.append((acc, b))
                acc = b
            }

            for (i, ring) in rings.enumerated() {
                let r0 = bounds[i].0, r1 = bounds[i].1
                drawRing(ctx: &ctx, ring: ring, cx: cx, cy: cy, rIn: r0, rOut: r1, detail: detail)
            }

            // 天池
            ctx.fill(Path(ellipseIn: CGRect(x: cx - rTC - 4, y: cy - rTC - 4,
                                            width: (rTC + 4) * 2, height: (rTC + 4) * 2)),
                     with: .color(Color(red: 0.955, green: 0.918, blue: 0.827)))
            ctx.stroke(Path(ellipseIn: CGRect(x: cx - rTC - 4, y: cy - rTC - 4,
                                              width: (rTC + 4) * 2, height: (rTC + 4) * 2)),
                       with: .color(Color(red: 0.78, green: 0.64, blue: 0.36)), lineWidth: 2)

            // 天池十字红线
            var cross = Path()
            cross.move(to: CGPoint(x: cx, y: cy - rTC - 2))
            cross.addLine(to: CGPoint(x: cx, y: cy + rTC + 2))
            cross.move(to: CGPoint(x: cx - rTC - 2, y: cy))
            cross.addLine(to: CGPoint(x: cx + rTC + 2, y: cy))
            ctx.stroke(cross, with: .color(Color(red: 0.58, green: 0.11, blue: 0.08).opacity(0.8)),
                       lineWidth: 1.6)

            // 天池四正
            let tf = rTC * 0.80
            let tc = Color(red: 0.46, green: 0.09, blue: 0.07)
            let tfont = Font.custom("SongtiSC-Bold", size: rTC * 0.20)
            for (txt, pt) in [("子", CGPoint(x: cx, y: cy - tf)), ("午", CGPoint(x: cx, y: cy + tf)),
                              ("卯", CGPoint(x: cx - tf, y: cy)), ("酉", CGPoint(x: cx + tf, y: cy))] {
                ctx.draw(Text(txt).font(tfont).foregroundStyle(tc),
                         at: pt, anchor: .center)
            }

            // 外框
            ctx.stroke(Path(ellipseIn: CGRect(x: cx - R + 3, y: cy - R + 3,
                                              width: (R - 3) * 2, height: (R - 3) * 2)),
                       with: .color(Color(red: 0.89, green: 0.73, blue: 0.41).opacity(0.55)),
                       lineWidth: 6)
        }
    }

    func weightOf(_ r: CompassRing) -> Double {
        if r.isTickOnly { return 0.22 }
        if r.isMain { return 1.90 }
        if r.weight > 0 { return r.weight }
        switch r.count {
        case ...8:  return 0.60
        case 9...12: return 0.74
        case 13...28: return 0.95
        case 29...48: return 1.00
        case 49...64: return 1.22
        case 65...72: return 1.30
        case 73...120: return 0.46
        default: return 0.30
        }
    }

    private func drawRing(ctx: inout GraphicsContext, ring r: CompassRing,
                          cx: CGFloat, cy: CGFloat,
                          rIn: Double, rOut: Double, detail: Bool) {
        // 环带
        var band = Path()
        band.addArc(center: CGPoint(x: cx, y: cy), radius: rOut,
                    startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        band.addArc(center: CGPoint(x: cx, y: cy), radius: rIn,
                    startAngle: .degrees(360), endAngle: .degrees(0), clockwise: true)
        band.closeSubpath()

        if r.isMain {
            ctx.fill(band, with: .color(Color(red: 0.44, green: 0.16, blue: 0.10).opacity(0.85)))
        } else {
            ctx.fill(band, with: .color(Color(hue: r.hue / 360,
                                             saturation: r.sat / 100,
                                             brightness: max(0.06, r.bright / 100),
                                             opacity: r.isTickOnly ? 0.5 : 0.9)))
        }

        // 色边
        let edge = Color(hue: r.hue / 360,
                         saturation: min(1, (r.sat + 16) / 100),
                         brightness: max(0.1, min(0.75, (r.bright + 24) / 100)),
                         opacity: r.isMain ? 0.95 : 0.40)
        for rad in [rIn, rOut] {
            ctx.stroke(Path(ellipseIn: CGRect(x: cx - rad, y: cy - rad,
                                              width: rad * 2, height: rad * 2)),
                       with: .color(edge), lineWidth: r.isMain ? 2.4 : 1.1)
        }

        let rMid = (rIn + rOut) / 2
        let bandW = rOut - rIn

        // 格线
        if r.isTickOnly {
            for i in 0..<360 {
                let a = Double(i)
                let major = i % 10 == 0
                strokeLine(ctx: &ctx, cx: cx, cy: cy, angle: a,
                           r1: major ? rIn : rIn + bandW * 0.35, r2: rOut,
                           color: Color(red: 0.89, green: 0.73, blue: 0.41).opacity(major ? 0.4 : 0.18),
                           width: major ? 1.4 : 0.7)
            }
        } else if !r.xiuSegs.isEmpty {
            let c2 = Color(hue: r.hue / 360, saturation: min(1, (r.sat + 20) / 100),
                           brightness: max(0.2, min(0.8, (r.bright + 26) / 100)), opacity: 0.3)
            for s in r.xiuSegs {
                strokeLine(ctx: &ctx, cx: cx, cy: cy, angle: s.a0, r1: rIn, r2: rOut,
                           color: c2, width: 0.9)
            }
        } else if r.step >= 3 {
            let c2 = Color(hue: r.hue / 360, saturation: min(1, (r.sat + 12) / 100),
                           brightness: max(0.2, min(0.8, (r.bright + 26) / 100)),
                           opacity: r.step >= 15 ? 0.32 : 0.16)
            for i in 0..<r.count {
                let a = r.center0 + Double(i) * r.step - r.step / 2
                strokeLine(ctx: &ctx, cx: cx, cy: cy, angle: a, r1: rIn, r2: rOut,
                           color: c2, width: r.step >= 15 ? 1.1 : 0.7)
            }
        }

        // 刻字
        let showText = detail || r.count <= 28 || r.isMain
        guard showText, !r.isTickOnly else { return }

        let textColor = r.isMain
            ? Color(red: 1.0, green: 0.85, blue: 0.54)
            : Color(hue: r.hue / 360,
                    saturation: max(0.3, (r.sat + 16) / 100),
                    brightness: min(0.92, 0.74 + (r.bright - 20) / 200))

        for i in 0..<r.count {
            let txt: String
            let ang: Double
            if !r.xiuSegs.isEmpty {
                let s = r.xiuSegs[i]
                txt = r.key == "xiudu" ? String(format: "%.1f", s.du) : Pan.xiu[i]
                ang = CompassRing.norm(s.a0 + (s.a1 - s.a0) / 2)
            } else {
                txt = r.labels[i]
                ang = r.center0 + Double(i) * r.step
            }
            if txt.isEmpty { continue }
            if r.count >= 100 && txt.count > 2 { continue }

            let f = fontSize(ring: r, bandW: bandW, len: txt.count, rMid: rMid,
                             step: r.xiuSegs.isEmpty ? r.step : 12)
            drawLabel(ctx: &ctx, cx: cx, cy: cy, text: txt,
                      angle: ang, rMid: rMid, font: Font.custom(r.fontName, size: f),
                      color: textColor, radial: r.mode == .radial)
        }
    }

    private func fontSize(ring r: CompassRing, bandW: Double, len: Int,
                          rMid: Double, step: Double) -> Double {
        let arc = rMid * step * .pi / 180
        let f = r.mode == .radial
            ? min(bandW / (Double(len) * 1.06), arc * 0.86)
            : min(bandW * 0.62, arc * 0.92)
        return max(6, min(f, r.isMain ? 26 : 20))
    }

    private func drawLabel(ctx: inout GraphicsContext, cx: CGFloat, cy: CGFloat,
                           text: String, angle: Double, rMid: Double,
                           font: Font, color: Color, radial: Bool) {
        var c = ctx
        c.translateBy(x: cx, y: cy)
        if radial {
            c.rotate(by: .degrees(angle - 90))
            c.draw(Text(text).font(font).foregroundStyle(color),
                   at: CGPoint(x: rMid, y: 0), anchor: .center)
        } else {
            c.rotate(by: .degrees(angle))
            c.draw(Text(text).font(font).foregroundStyle(color),
                   at: CGPoint(x: 0, y: -rMid), anchor: .center)
        }
    }

    private func strokeLine(ctx: inout GraphicsContext, cx: CGFloat, cy: CGFloat,
                            angle: Double, r1: Double, r2: Double,
                            color: Color, width: CGFloat) {
        let a = angle * .pi / 180
        let ux = sin(a), uy = -cos(a)
        var p = Path()
        p.move(to: CGPoint(x: cx + ux * r1, y: cy + uy * r1))
        p.addLine(to: CGPoint(x: cx + ux * r2, y: cy + uy * r2))
        ctx.stroke(p, with: .color(color), lineWidth: width)
    }
}

// MARK: - 金针

struct NeedleView: View {
    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            let r = min(size.width, size.height) / 2 * 0.152 * 0.90
            let w = r * 0.115

            // 北段
            var north = Path()
            north.move(to: CGPoint(x: cx, y: cy - r))
            north.addQuadCurve(to: CGPoint(x: cx + w, y: cy - r * 0.06),
                               control: CGPoint(x: cx + w * 1.35, y: cy - r * 0.42))
            north.addLine(to: CGPoint(x: cx - w, y: cy - r * 0.06))
            north.addQuadCurve(to: CGPoint(x: cx, y: cy - r),
                               control: CGPoint(x: cx - w * 1.35, y: cy - r * 0.42))
            north.closeSubpath()
            ctx.fill(north, with: .linearGradient(
                Gradient(colors: [Color(hex: 0x7A5718), Color(hex: 0xE0B25C),
                                  Color(hex: 0xFFF6D8), Color(hex: 0xE8BF6A), Color(hex: 0x8A6522)]),
                startPoint: CGPoint(x: cx - w, y: cy), endPoint: CGPoint(x: cx + w, y: cy)))
            ctx.stroke(north, with: .color(Color(hex: 0x302008).opacity(0.8)), lineWidth: 1.4)

            // 南段
            var south = Path()
            south.move(to: CGPoint(x: cx, y: cy + r))
            south.addQuadCurve(to: CGPoint(x: cx + w, y: cy + r * 0.06),
                               control: CGPoint(x: cx + w * 1.35, y: cy + r * 0.42))
            south.addLine(to: CGPoint(x: cx - w, y: cy + r * 0.06))
            south.addQuadCurve(to: CGPoint(x: cx, y: cy + r),
                               control: CGPoint(x: cx - w * 1.35, y: cy + r * 0.42))
            south.closeSubpath()
            ctx.fill(south, with: .linearGradient(
                Gradient(colors: [Color(hex: 0x5B3F10), Color(hex: 0xB9863A), Color(hex: 0x5B3F10)]),
                startPoint: CGPoint(x: cx - w, y: cy), endPoint: CGPoint(x: cx + w, y: cy)))
            ctx.stroke(south, with: .color(Color(hex: 0x302008).opacity(0.8)), lineWidth: 1.4)

            // 中心金珠
            let ball = r * 0.135
            ctx.fill(Path(ellipseIn: CGRect(x: cx - ball, y: cy - ball,
                                            width: ball * 2, height: ball * 2)),
                     with: .radialGradient(
                        Gradient(colors: [Color(hex: 0xFFFAEA), Color(hex: 0xE9C272), Color(hex: 0x8A6522)]),
                        center: CGPoint(x: cx - ball * 0.3, y: cy - ball * 0.3),
                        startRadius: 1, endRadius: ball))
            ctx.stroke(Path(ellipseIn: CGRect(x: cx - ball, y: cy - ball,
                                              width: ball * 2, height: ball * 2)),
                       with: .color(Color(hex: 0x302008).opacity(0.85)), lineWidth: 1.6)
        }
    }
}

// MARK: - 天心十道（固定在盘架，不随盘转）

struct CrosshairView: View {
    var body: some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            var p = Path()
            p.move(to: CGPoint(x: cx, y: 0))
            p.addLine(to: CGPoint(x: cx, y: size.height))
            p.move(to: CGPoint(x: 0, y: cy))
            p.addLine(to: CGPoint(x: size.width, y: cy))
            ctx.stroke(p, with: .color(Color(red: 0.84, green: 0.25, blue: 0.19).opacity(0.62)),
                       lineWidth: 1.6)

            // 顶端指标
            var tri = Path()
            tri.move(to: CGPoint(x: cx, y: 4))
            tri.addLine(to: CGPoint(x: cx - 9, y: 22))
            tri.addLine(to: CGPoint(x: cx + 9, y: 22))
            tri.closeSubpath()
            ctx.fill(tri, with: .color(Color(red: 0.97, green: 0.89, blue: 0.65)))
        }
    }
}

// MARK: - Color(hex:)

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}
