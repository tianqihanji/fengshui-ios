//
//  CompassData.swift
//  掌上风水罗盘 · 综合盘（三十一圈层）
//
//  盘面全部数据与角度关系集中在此文件，便于按师承校改。
//  所有角度：0° = 正北（子），顺时针递增。
//

import SwiftUI

// MARK: - 基础常量

enum GZ {
    static let gan: [String] = ["甲","乙","丙","丁","戊","己","庚","辛","壬","癸"]
    static let zhi: [String] = ["子","丑","寅","卯","辰","巳","午","未","申","酉","戌","亥"]

    static var jiazi: [String] {
        (0..<60).map { gan[$0 % 10] + zhi[$0 % 12] }
    }
}

enum Pan {
    /// 二十四山（子起 0°）
    static let shan: [String] = ["子","癸","丑","艮","寅","甲","卯","乙","辰","巽","巳","丙",
                                 "午","丁","未","坤","申","庚","酉","辛","戌","乾","亥","壬"]
    static let shanWuxing: [String] = ["水","水","土","土","木","木","木","木","土","木","火","火",
                                       "火","火","土","土","金","金","金","金","土","金","水","水"]
    /// 净阴净阳
    static let yinYang: [String] = shan.map {
        "乾坤艮巽甲庚丙壬子午卯酉".contains($0) ? "阳" : "阴"
    }

    static let houtian: [String] = ["坎","艮","震","巽","离","坤","兑","乾"]
    static let xiantian: [String] = ["坤","震","离","兑","乾","巽","坎","艮"]
    static let luoshu: [String]  = ["一白","八白","三碧","四绿","九紫","二黑","七赤","六白"]
    static let najia: [String]   = ["坎·戊","艮·丙","震·庚","巽·辛","离·己","坤·乙癸","兑·丁","乾·甲壬"]

    static let nayinName: [String] = ["海中金","炉中火","大林木","路旁土","剑锋金","山头火","涧下水","城头土",
                                      "白蜡金","杨柳木","泉中水","屋上土","霹雳火","松柏木","长流水","沙中金",
                                      "山下火","平地木","壁上土","金箔金","覆灯火","天河水","大驿土","钗钏金",
                                      "桑柘木","大溪水","沙中土","天上火","石榴木","大海水"]

    static let shuangshan: [String] = ["壬子·水","癸丑·金","艮寅·火","甲卯·木","乙辰·水","巽巳·金",
                                       "丙午·火","丁未·木","坤申·水","庚酉·金","辛戌·火","乾亥·木"]

    static let xiu: [String] = ["角","亢","氐","房","心","尾","箕","斗","牛","女","虚","危","室","壁",
                                "奎","娄","胃","昴","毕","觜","参","井","鬼","柳","星","张","翼","轸"]
    static let xiuDu: [Double] = [12,9,15,5,5,18,11, 26,8,12,10,17,16,9, 16,12,14,11,16,2,9,
                                  33,4,15,7,18,18,17]
    static let xiuQi: [String] = ["木","金","土","日","月","火","水","木","金","土","日","月","火","水",
                                  "木","金","土","日","月","火","水","木","金","土","日","月","火","水"]
    /// 角宿起点（辰宫 112.5°）。依师承可改。
    static let xiuStart: Double = 112.5

    static let jieqi: [String] = ["冬至","小寒","大寒","立春","雨水","惊蛰","春分","清明","谷雨","立夏","小满","芒种",
                                  "夏至","小暑","大暑","立秋","处暑","白露","秋分","寒露","霜降","立冬","小雪","大雪"]

    static let gua64: [String] = ["坤","复","颐","屯","益","震","噬嗑","随","无妄","明夷","贲","既济","家人","丰","离","革",
                                  "同人","临","损","节","中孚","归妹","睽","兑","履","泰","大畜","需","小畜","大壮","大有","夬",
                                  "乾","姤","大过","鼎","恒","巽","井","蛊","升","讼","困","未济","解","涣","坎","蒙",
                                  "师","遁","咸","旅","小过","渐","蹇","艮","谦","否","萃","晋","豫","观","比","剥"]

    static let changsheng: [String] = ["长生","沐浴","冠带","临官","帝旺","衰","病","死","墓","绝","胎","养"]
    static let jianchu: [String] = ["建","除","满","平","定","执","破","危","成","收","开","闭"]
    static let taisui: [String]  = ["岁建","太阳","丧门","太阴","官符","死符","岁破","龙德","白虎","福德","吊客","病符"]

    /// 八煞黄泉：山位 -> 煞方属卦
    static let bashan: [String:String] = ["辰":"坎","卯":"坤","申":"震","酉":"巽","午":"乾","巳":"兑","寅":"艮","亥":"离"]
    /// 八路黄泉：向位 -> 黄泉方
    static let huangquan: [String:String] = ["癸":"艮","甲":"艮","乙":"巽","丙":"巽","丁":"坤","庚":"坤","辛":"乾","壬":"乾"]
}

// MARK: - 圈层

enum RingMode { case tangential, radial }

struct XiuSeg {
    let a0: Double
    let a1: Double
    let name: String
    let du: Double
}

struct CompassRing: Identifiable {
    let id = UUID()
    var key: String
    var name: String
    var desc: String
    var count: Int
    var step: Double
    var center0: Double
    var labels: [String]        // 盘面刻字（可留空）
    var values: [String]        // 读数用（缺省同 labels）
    var mode: RingMode
    var weight: Double
    var hue: Double
    var sat: Double
    var bright: Double
    var fontName: String
        var isMain: Bool = false
    var isTickOnly: Bool = false
    var xiuSegs: [XiuSeg] = []

    /// 归一化到 [0,360)
    static func norm(_ d: Double) -> Double {
        let v = d.truncatingRemainder(dividingBy: 360)
        return v < 0 ? v + 360 : v
    }

    func index(at deg: Double) -> Int {
        if !xiuSegs.isEmpty {
            for (i, s) in xiuSegs.enumerated() {
                let len = CompassRing.norm(s.a1 - s.a0)
                let off = CompassRing.norm(deg - s.a0)
                if off < len || abs(off - len) < 1e-9 { return i }
            }
            return 0
        }
        guard count > 0 else { return 0 }
        let a = CompassRing.norm(deg - (center0 - step / 2))
        return Int(floor(a / step)) % count
    }

    func value(at deg: Double) -> String {
        let i = index(at: deg)
        if !xiuSegs.isEmpty {
            let s = xiuSegs[i]
            return key == "xiudu" ? String(format: "%.1f°", s.du) : s.name
        }
        let arr = values.isEmpty ? labels : values
        guard i < arr.count else { return "" }
        return arr[i]
    }
}

// MARK: - 生成器

enum CompassData {

    static let palette: [(Double, Double, Double)] = [
        (6, 52, 24), (30, 46, 22), (44, 38, 21), (150, 30, 19), (188, 34, 20), (212, 40, 21),
        (246, 34, 23), (284, 26, 22), (330, 28, 20), (168, 24, 17), (18, 10, 18), (36, 24, 15)
    ]

    static let fonts: [String] = ["SongtiSC-Regular", "KaitiSC-Regular", "STFangsong",
                                  "PingFangSC-Regular", "STHeitiSC-Light", "SongtiSC-Bold"]

    static func ring(_ key: String, _ name: String, _ desc: String,
                     count: Int, center0: Double = 0,
                     labels: [String], values: [String] = [],
                     mode: RingMode = .tangential, weight: Double = 0,
                     isMain: Bool = false, tickOnly: Bool = false) -> CompassRing {
        CompassRing(key: key, name: name, desc: desc,
                    count: count, step: 360.0 / Double(count), center0: center0,
                    labels: labels, values: values,
                    mode: mode, weight: weight, hue: 0, sat: 0, bright: 0,
                    fontName: "", isMain: isMain, isTickOnly: tickOnly)
    }

    static func sparse(_ n: Int, _ map: [String:String]) -> [String] {
        var a = Array(repeating: "", count: n)
        for (k, v) in map {
            if let idx = Pan.shan.firstIndex(of: k), idx < n { a[idx] = v }
        }
        return a
    }

    /// 分金：每山五格（3°），盘面只刻丙丁庚辛旺相
    static func fenjin(_ offset: Double, _ name: String, _ desc: String) -> CompassRing {
        let n = 120
        var labels = Array(repeating: "", count: n)
        var values = Array(repeating: "", count: n)
        let zhiOf = ["子","丑","丑","寅","寅","卯","卯","辰","辰","巳","巳","午",
                     "午","未","未","申","申","酉","酉","戌","戌","亥","亥","子"]
        for k in 0..<24 {
            let zhi = zhiOf[k]
            let stems = "子寅辰午申戌".contains(zhi)
                ? ["甲","丙","戊","庚","壬"] : ["乙","丁","己","辛","癸"]
            for j in 0..<5 {
                let i = 5 * k + j
                let gz = stems[j] + zhi
                let st: String
                if "戊己".contains(stems[j]) { st = "空亡" }
                else if "丙丁庚辛".contains(stems[j]) { st = "旺相" }
                else { st = "孤虚" }
                values[i] = gz + "·" + st
                if st == "旺相" { labels[i] = gz }
            }
        }
        return ring("fj\(offset)", name, desc, count: n, center0: offset - 6,
                    labels: labels, values: values, mode: .radial, weight: 0.46)
    }

    static func xiuRing(withDu: Bool) -> CompassRing {
        let total = Pan.xiuDu.reduce(0, +)
        let scale = 360.0 / total
        var segs: [XiuSeg] = []
        var acc = Pan.xiuStart
        for i in 0..<28 {
            let span = Pan.xiuDu[i] * scale
            segs.append(XiuSeg(a0: acc, a1: acc + span,
                               name: Pan.xiu[i] + Pan.xiuQi[i],
                               du: Pan.xiuDu[i]))
            acc += span
        }
        var r = ring(withDu ? "xiudu" : "xiu",
                     withDu ? "二十八宿宿度" : "二十八宿",
                     withDu ? "各宿所占度数（古度折合周天），用于消砂审星度吉凶。"
                            : "角至轸二十八宿，配七政五行；以之消砂，观砂峰所值何宿而断吉凶。",
                     count: 28, labels: Pan.xiu, mode: .tangential, weight: 0.95)
        r.xiuSegs = segs
        return r
    }

    static func build() -> [CompassRing] {
        var list: [CompassRing] = []

        list.append(ring("xt", "先天八卦",
          "伏羲先天八卦：乾南坤北、离东坎西，主对待之体，审龙脉祖宗、辨阴阳之祖。",
          count: 8, labels: Pan.xiantian, weight: 0.60))

        list.append(ring("ht", "后天八卦",
          "文王后天八卦：坎北离南、震东兑西，主流行之用，定方位、分九宫、起挨星皆本此。",
          count: 8, labels: Pan.houtian, weight: 0.60))

        list.append(ring("ls", "洛书紫白",
          "洛书九星配后天卦：一白坎、二黑坤、三碧震、四绿巽、六白乾、七赤兑、八白艮、九紫离，五黄寄中。",
          count: 8, labels: Pan.luoshu, weight: 0.60))

        list.append(ring("nj", "八卦纳甲",
          "乾纳甲壬、坤纳乙癸、震纳庚、巽纳辛、坎纳戊、离纳己、艮纳丙、兑纳丁；用以定来去水吉凶。",
          count: 8, labels: Pan.najia, weight: 0.60))

        list.append(ring("yy", "净阴净阳",
          "乾坤艮巽甲庚丙壬子午卯酉为阳，余十二山为阴；立向取净阴净阳，阴阳混杂则不纯。",
          count: 24, labels: Pan.yinYang, weight: 0.95))

        list.append(ring("bs", "八煞黄泉",
          "坎龙坤兔震山猴，巽鸡乾马兑蛇头，艮虎离猪为曜煞；此八方不宜开门、放水、立向。",
          count: 24,
          labels: sparse(24, Pan.bashan.mapValues { _ in "煞" }),
          values: sparse(24, Pan.bashan.mapValues { $0 + "煞" }),
          weight: 0.95))

        list.append(ring("shan0", "地盘正针二十四山",
          "二十四山正针，子午正中，格龙立向之主盘；每山十五度。",
          count: 24, labels: Pan.shan, mode: .tangential, weight: 1.0, isMain: true))

        list.append(ring("wx24", "二十四山正五行",
          "正五行：亥壬子癸水、寅甲卯乙巽木、巳丙午丁火、申庚酉辛乾金、辰戌丑未坤艮土。",
          count: 24, labels: Pan.shanWuxing, weight: 0.95))

        // 穿山七十二龙
        var l72 = Array(repeating: "", count: 72)
        var j = 0
        for i in 0..<72 {
            if i % 6 == 5 { l72[i] = "空亡" }
            else { l72[i] = GZ.jiazi[j % 60]; j += 1 }
        }
        list.append(ring("l72", "穿山七十二龙",
          "二十四山每山三龙、共七十二龙；戊己之位为龟甲空亡，立向避之。",
          count: 72, center0: 355, labels: l72, mode: .radial, weight: 1.30))

        // 透地六十龙
        list.append(ring("l60", "透地六十龙",
          "以天盘缝针下六十甲子，审穴内气脉，甲子起于壬中，挨星审气以定棺向。",
          count: 60, center0: -7.5, labels: GZ.jiazi, mode: .radial, weight: 1.22))

        list.append(fenjin(0, "一百二十分金·地盘",
          "每山五分金，一格三度；丙丁庚辛旺相可用，甲乙壬癸孤虚、戊己空亡皆不宜。"))

        list.append(ring("ss", "双山五行",
          "三合双山：壬子水、癸丑金、艮寅火、甲卯木、乙辰水、巽巳金、丙午火、丁未木、坤申水、庚酉金、辛戌火、乾亥木。",
          count: 12, center0: -7.5, labels: Pan.shuangshan, weight: 0.74))

        list.append(ring("shanRen", "人盘中针二十四山",
          "人盘中针较地盘半山（七度半），用于消砂，砂峰以中针五行论生克。",
          count: 24, center0: 7.5, labels: Pan.shan, weight: 0.95))

        list.append(ring("shanTian", "天盘缝针二十四山",
          "天盘缝针较地盘差半山，专用于纳水，水之来去以缝针双山三合论生旺墓。",
          count: 24, center0: -7.5, labels: Pan.shan, weight: 0.95))

        list.append(fenjin(7.5, "一百二十分金·人盘", "人盘中针之分金，随中针半山推移，用于消砂取用。"))
        list.append(fenjin(-7.5, "一百二十分金·天盘", "天盘缝针之分金，随缝针半山推移，用于纳水立向。"))

        list.append(ring("jz60", "六十甲子",
          "六十花甲一周，纪年纪月纪日纪时之序，罗盘以之配龙、配向、配砂水。",
          count: 60, labels: GZ.jiazi, mode: .radial, weight: 1.22))

        list.append(ring("ny", "纳音五行",
          "六十甲子纳音，两甲子共一音，金木水火土三十音；审龙气、配分金、定吉凶。",
          count: 60,
          labels: (0..<60).map { String(Pan.nayinName[$0 / 2].suffix(1)) },
          values: (0..<60).map { Pan.nayinName[$0 / 2] },
          mode: .radial, weight: 1.22))

        list.append(xiuRing(withDu: false))
        list.append(xiuRing(withDu: true))

        list.append(ring("jq", "二十四节气",
          "冬至起于子宫，一气十五度；用于太阳到山、择日乘气与四时旺衰。",
          count: 24, labels: Pan.jieqi, weight: 0.95))

        list.append(ring("g64", "六十四卦",
          "伏羲六十四卦圆图：坤在子、乾在午；玄空大卦、卦气抽爻换象皆本此。",
          count: 64, labels: Pan.gua64, mode: .radial, weight: 1.22))

        list.append(ring("cs0", "十二长生·火局", "寅午戌火局：长生寅、帝旺午、墓戌；生旺宜来、死墓宜去。",
          count: 12, center0: 60, labels: Pan.changsheng, weight: 0.74))
        list.append(ring("cs1", "十二长生·水局", "申子辰水局：长生申、帝旺子、墓辰。",
          count: 12, center0: 240, labels: Pan.changsheng, weight: 0.74))
        list.append(ring("cs2", "十二长生·金局", "巳酉丑金局：长生巳、帝旺酉、墓丑。",
          count: 12, center0: 150, labels: Pan.changsheng, weight: 0.74))
        list.append(ring("cs3", "十二长生·木局", "亥卯未木局：长生亥、帝旺卯、墓未。",
          count: 12, center0: 330, labels: Pan.changsheng, weight: 0.74))

        list.append(ring("hq", "八路黄泉",
          "庚丁坤上是黄泉，乙丙须防巽水先，甲癸向中忧见艮，辛壬水路怕乾当。",
          count: 24,
          labels: sparse(24, Pan.huangquan),
          values: sparse(24, Pan.huangquan.mapValues { $0 + "方黄泉" }),
          weight: 0.95))

        list.append(ring("jc", "十二建除", "建除满平定执破危成收开闭十二神，配月建轮值，择日定向。",
          count: 12, labels: Pan.jianchu, weight: 0.74))

        list.append(ring("ts", "十二太岁", "岁建、太阳、丧门、太阴、官符、死符、岁破、龙德、白虎、福德、吊客、病符。",
          count: 12, labels: Pan.taisui, weight: 0.74))

        list.append(ring("deg", "周天度数", "周天三百六十度，每十度一大格；磁针所指为磁方位，加磁偏角得真方位。",
          count: 36, labels: (0..<36).map { String($0 * 10) }, mode: .radial, weight: 0.30))

        list.append(ring("tick", "周天刻度", "一周天三百六十细格，每格一度，用于精确定位与读盘。",
          count: 360, labels: [], tickOnly: true, weight: 0.22))

        // 着色与字体：传统色谱轮转 + 同色系以明度分层
        for i in list.indices {
            let p = palette[i % palette.count]
            list[i].hue = p.0
            list[i].sat = p.1
            list[i].bright = p.2 + Double(i / palette.count) * 4.5
            list[i].fontName = fonts[i % fonts.count]
        }
        return list
    }
}
