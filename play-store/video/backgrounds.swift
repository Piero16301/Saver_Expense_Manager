// Renders per-scene background PNGs (text + realistic smartphone frame + chapter bar) and rounded screen mask.
// Usage: backgrounds <height> <outDir> [logoPath]
//   height 1080 => 1920x1080, 2160 => 3840x2160
import AppKit

let H = CGFloat(Int(CommandLine.arguments[1])!)
let out = CommandLine.arguments[2]
let logoPath = CommandLine.arguments.count > 3 ? CommandLine.arguments[3] : ""
let k = H / 1080.0
let Wd = 1920 * k

func C(_ x: String, _ a: CGFloat = 1) -> NSColor {
    let v = UInt32(x.dropFirst(), radix: 16)!
    return NSColor(
        red: CGFloat(v >> 16 & 255) / 255,
        green: CGFloat(v >> 8 & 255) / 255,
        blue: CGFloat(v & 255) / 255,
        alpha: a
    )
}

struct Scene {
    let g0, g1, acc, pillText, tag, h1, h2, desc: String
    let bullets: [String]
}

let scenes: [Scene] = [
    Scene(
        g0: "#042420", g1: "#0f8c73", acc: "#5eead4", pillText: "#052e27",
        tag: "💰  AI EXPENSE MANAGER",
        h1: "SAVER", h2: "Master every dollar, effortlessly.",
        desc: "Track spending, scan receipts and get Gemini AI savings tips — even offline.",
        bullets: ["🤖  Gemini AI Tips (Online & Offline)", "📷  Instant AI Receipt Scanner", "🆓  100% Free · No Ads · Private"]
    ),
    Scene(
        g0: "#052e2b", g1: "#0d9488", acc: "#67e8f9", pillText: "#083344",
        tag: "📊  EXPENSE TRACKING",
        h1: "See where every", h2: "dollar goes",
        desc: "Instant category breakdowns with percentages and your full daily timeline.",
        bullets: ["Interactive category breakdown bar", "Custom icons & brand visuals", "Fast, clean Material Design UI"]
    ),
    Scene(
        g0: "#082840", g1: "#0284c7", acc: "#7dd3fc", pillText: "#082f49",
        tag: "📈  CATEGORY TRENDS",
        h1: "Spot spending", h2: "trends early",
        desc: "Explore monthly curves per category and inspect every single movement.",
        bullets: ["Interactive touch trend charts", "Tap any point for exact totals", "Full category movement history"]
    ),
    Scene(
        g0: "#1a0e42", g1: "#7c3aed", acc: "#c4b5fd", pillText: "#2e1065",
        tag: "🤖  POWERED BY GEMINI AI",
        h1: "Smart savings tips,", h2: "tailored to you",
        desc: "Gemini analyzes your real habits to highlight avoidable expenses and savings.",
        bullets: ["Spot avoidable everyday spending", "Actionable personalized advice", "Works online & offline with Gemini Nano"]
    ),
    Scene(
        g0: "#0d1b3e", g1: "#2563eb", acc: "#93c5fd", pillText: "#172554",
        tag: "🔍  SMART FILTERS",
        h1: "Find any expense", h2: "in seconds",
        desc: "Filter your full movement history by type, category or date effortlessly.",
        bullets: ["Filter by Expense or Income", "Drill down into any category", "Instant, clutter-free results"]
    ),
    Scene(
        g0: "#101638", g1: "#3b5bdb", acc: "#ffd43b", pillText: "#1e1b4b",
        tag: "⚖️  FINANCIAL SUMMARY",
        h1: "Income vs. expenses,", h2: "at a glance",
        desc: "Compare incomes, expenses and net balance on one interactive chart.",
        bullets: ["Live Incomes, Balance & Expenses", "Tap chart points for exact figures", "Toggle series for focused views"]
    ),
    Scene(
        g0: "#421905", g1: "#ea580c", acc: "#fde047", pillText: "#431407",
        tag: "🏆  YEARLY INSIGHTS",
        h1: "Track your growth", h2: "year over year",
        desc: "Zoom out to multi-year trends and see your top spending categories ranked.",
        bullets: ["Switch Month & Year views live", "Multi-year balance trajectories", "Ranked Top Categories breakdown"]
    ),
    Scene(
        g0: "#470726", g1: "#db2777", acc: "#f9a8d4", pillText: "#500724",
        tag: "📷  AI RECEIPT SCANNER",
        h1: "Snap a receipt,", h2: "skip the typing",
        desc: "Point your camera at any receipt — Saver frames, enhances and reads it automatically.",
        bullets: ["Auto-framing document scanner", "Scan camera, gallery or PDF files", "Powered by Gemini Flash vision"]
    ),
    Scene(
        g0: "#270d52", g1: "#9333ea", acc: "#5eead4", pillText: "#2e1065",
        tag: "⚡  INSTANT AI AUTO-FILL",
        h1: "Every detail filled", h2: "automatically",
        desc: "Title, description, date, category, amount and company — ready in one tap.",
        bullets: ["Extracts amount, date & merchant", "Auto-assigns the right category", "Attaches receipt image automatically"]
    ),
    Scene(
        g0: "#450a1f", g1: "#e11d48", acc: "#fde047", pillText: "#4c0519",
        tag: "🎨  THEMES & 6 LANGUAGES",
        h1: "Make Saver", h2: "truly yours",
        desc: "Switch Light or Dark mode, pick your accent color and change language live.",
        bullets: ["Light, Dark & System themes", "15+ accent colors & custom fonts", "🇬🇧 EN · 🇪🇸 ES · 🇮🇹 IT · 🇩🇪 DE · 🇫🇷 FR · 🇵🇹 PT"]
    ),
    Scene(
        g0: "#042420", g1: "#0f8c73", acc: "#5eead4", pillText: "#052e27",
        tag: "🚀  START SAVING SMARTER",
        h1: "Download Saver", h2: "Your money. Your rules.",
        desc: "Get full control of your finances today — free on Google Play.",
        bullets: ["100% Free — No Subscriptions or Ads", "Privacy-First · Offline Capable", "Free on Google Play"]
    ),
]

func newCtx(_ w: Int, _ h: Int) -> (NSBitmapImageRep, CGContext) {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!
    let g = NSGraphicsContext(bitmapImageRep: rep)!
    g.cgContext.translateBy(x: 0, y: CGFloat(h))
    g.cgContext.scaleBy(x: 1, y: -1)
    let f = NSGraphicsContext(cgContext: g.cgContext, flipped: true)
    NSGraphicsContext.current = f
    return (rep, f.cgContext)
}

func save(_ rep: NSBitmapImageRep, _ name: String) {
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(out)/\(name)"))
}

func fitText(
    _ s: String, maxSize: CGFloat, maxWidth: CGFloat,
    _ w: NSFont.Weight, _ col: NSColor, _ x: CGFloat, _ y: CGFloat, shadow: Bool = false
) {
    var sz = maxSize
    while sz > 32 {
        let test = NSAttributedString(string: s, attributes: [.font: NSFont.systemFont(ofSize: sz * k, weight: w)])
        if test.size().width <= maxWidth * k { break }
        sz -= 2
    }
    var a: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: sz * k, weight: w),
        .foregroundColor: col,
    ]
    if shadow {
        let sh = NSShadow()
        sh.shadowColor = NSColor.black.withAlphaComponent(0.36)
        sh.shadowBlurRadius = 18 * k
        sh.shadowOffset = NSSize(width: 0, height: -5 * k)
        a[.shadow] = sh
    }
    let dy = (maxSize - sz) * 0.35
    NSAttributedString(string: s, attributes: a).draw(at: NSPoint(x: x * k, y: (y + dy) * k))
}

// Smartphone geometry (design units @ 1080p, matching 1344x2992 source ratio ~0.4492)
let sw: CGFloat = 418
let sh: CGFloat = 930
let bz: CGFloat = 16
let pw = sw + 2 * bz   // 450
let ph = sh + 2 * bz   // 962
let pcx: CGFloat = 385
let pcy: CGFloat = 540
let outerR: CGFloat = 56
let innerR: CGFloat = 42

let vx = Int(round((pcx - sw / 2) * k))
let vy = Int(round((pcy - sh / 2) * k))
let vw = Int(round(sw * k))
let vh = Int(round(sh * k))
print("VIDEO_X \(vx) VIDEO_Y \(vy) VIDEO_W \(vw) VIDEO_H \(vh)")

let logoImg: NSImage? = (!logoPath.isEmpty && FileManager.default.fileExists(atPath: logoPath))
    ? NSImage(contentsOfFile: logoPath)
    : nil

let tx: CGFloat = 710
let maxColW: CGFloat = 1110  // right margin = 100px

for (i, s) in scenes.enumerated() {
    let (rep, cg) = newCtx(Int(Wd), Int(H))

    // Rich radial gradient backdrop
    NSGradient(starting: C(s.g1), ending: C(s.g0))!.draw(
        fromCenter: NSPoint(x: 340 * k, y: 140 * k), radius: 0,
        toCenter: NSPoint(x: 340 * k, y: 140 * k), radius: 2150 * k,
        options: [.drawsAfterEndingLocation]
    )

    // Subtle geometric bokeh circles
    for (x, y, z, a) in [
        (1780.0, 120.0, 620.0, 0.08),
        (1340.0, 1000.0, 700.0, 0.06),
        (70.0, 980.0, 440.0, 0.07),
    ] {
        C("#ffffff", CGFloat(a)).setFill()
        NSBezierPath(ovalIn: NSRect(x: (x - z / 2) * k, y: (y - z / 2) * k, width: z * k, height: z * k)).fill()
    }

    // Subtle decorative hairline arc behind phone
    C("#ffffff", 0.07).setStroke()
    let deco = NSBezierPath(ovalIn: NSRect(x: (pcx - 420) * k, y: (pcy - 420) * k, width: 840 * k, height: 840 * k))
    deco.lineWidth = 2 * k
    deco.stroke()

    let px = (pcx - pw / 2) * k
    let py = (pcy - ph / 2) * k

    // Side hardware buttons (power + volume rocker on right edge)
    let powerBtn = NSRect(x: px + pw * k - 2 * k, y: py + 235 * k, width: 7 * k, height: 74 * k)
    let volBtn = NSRect(x: px + pw * k - 2 * k, y: py + 335 * k, width: 7 * k, height: 132 * k)
    NSGradient(starting: C("#8e95a3"), ending: C("#2d3138"))!.draw(in: NSBezierPath(roundedRect: powerBtn, xRadius: 3 * k, yRadius: 3 * k), angle: 0)
    NSGradient(starting: C("#8e95a3"), ending: C("#2d3138"))!.draw(in: NSBezierPath(roundedRect: volBtn, xRadius: 3 * k, yRadius: 3 * k), angle: 0)

    // Phone body + vibrant accent glow
    let outerPath = NSBezierPath(roundedRect: NSRect(x: px, y: py, width: pw * k, height: ph * k), xRadius: outerR * k, yRadius: outerR * k)
    cg.saveGState()
    cg.setShadow(offset: CGSize(width: 0, height: 18 * k), blur: 84 * k, color: C(s.acc, 0.50).cgColor)
    C("#181b20").setFill()
    outerPath.fill()
    cg.restoreGState()

    // Metallic titanium phone chassis
    NSGradient(starting: C("#555c69"), ending: C("#16191f"))!.draw(in: outerPath, angle: 135)

    // Subtle bright rim highlight
    C("#c8ced9", 0.48).setStroke()
    let rimPath = NSBezierPath(
        roundedRect: NSRect(x: px + 2.5 * k, y: py + 2.5 * k, width: (pw - 5) * k, height: (ph - 5) * k),
        xRadius: (outerR - 2.5) * k, yRadius: (outerR - 2.5) * k
    )
    rimPath.lineWidth = 3 * k
    rimPath.stroke()

    // Inner matte bezel ring
    C("#090b0d").setFill()
    let innerBezel = NSBezierPath(
        roundedRect: NSRect(x: px + 7 * k, y: py + 7 * k, width: (pw - 14) * k, height: (ph - 14) * k),
        xRadius: (outerR - 6) * k, yRadius: (outerR - 6) * k
    )
    innerBezel.fill()

    // Pure black screen cutout
    C("#000000").setFill()
    NSBezierPath(
        roundedRect: NSRect(x: CGFloat(vx), y: CGFloat(vy), width: CGFloat(vw), height: CGFloat(vh)),
        xRadius: innerR * k, yRadius: innerR * k
    ).fill()

    // Right column: Tag pill (+ optional app icon on Intro & Outro)
    let isHero = (i == 0 || i == scenes.count - 1)
    var tagX = tx
    if isHero, let img = logoImg {
        let lsz: CGFloat = 62
        let lr = NSRect(x: tx * k, y: 146 * k, width: lsz * k, height: lsz * k)
        cg.saveGState()
        NSBezierPath(roundedRect: lr, xRadius: 15 * k, yRadius: 15 * k).addClip()
        img.draw(in: lr, from: .zero, operation: .sourceOver, fraction: 1.0, respectFlipped: true, hints: nil)
        cg.restoreGState()
        tagX = tx + lsz + 18
    }

    let tagAt: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 25 * k, weight: .heavy),
        .foregroundColor: C("#ffffff", 0.96),
    ]
    let tagStr = NSAttributedString(string: s.tag, attributes: tagAt)
    let tagSz = tagStr.size()
    C("#ffffff", 0.14).setFill()
    NSBezierPath(roundedRect: NSRect(x: tagX * k, y: 153 * k, width: tagSz.width + 42 * k, height: 48 * k), xRadius: 24 * k, yRadius: 24 * k).fill()
    tagStr.draw(at: NSPoint(x: tagX * k + 21 * k, y: 162 * k))

    // Headlines (auto-fitted so they NEVER clip!)
    let h1Size: CGFloat = (i == 0) ? 130 : 92
    let h2Size: CGFloat = (i == 0) ? 58 : 92
    fitText(s.h1, maxSize: h1Size, maxWidth: maxColW, .black, .white, tx, 226, shadow: true)
    fitText(s.h2, maxSize: h2Size, maxWidth: maxColW, .black, C(s.acc), tx, (i == 0) ? 368 : 328, shadow: true)

    // Description
    let descY: CGFloat = (i == 0) ? 462 : 454
    let para = NSMutableParagraphStyle()
    para.lineBreakMode = .byWordWrapping
    para.lineSpacing = 6 * k
    NSAttributedString(
        string: s.desc,
        attributes: [
            .font: NSFont.systemFont(ofSize: 35 * k, weight: .medium),
            .foregroundColor: C("#ffffff", 0.92),
            .paragraphStyle: para,
        ]
    ).draw(in: NSRect(x: tx * k, y: descY * k, width: maxColW * k, height: 120 * k))

    // Feature pills
    let startY: CGFloat = 598
    for (j, b) in s.bullets.enumerated() {
        let by = (startY + CGFloat(j) * 78) * k
        let label = (i == 0) ? b : "✓  " + b
        let at: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 30 * k, weight: .heavy),
            .foregroundColor: C(s.pillText),
        ]
        let a = NSAttributedString(string: label, attributes: at)
        let z = a.size()
        cg.saveGState()
        cg.setShadow(offset: CGSize(width: 0, height: 6 * k), blur: 16 * k, color: NSColor.black.withAlphaComponent(0.30).cgColor)
        C("#ffffff", 0.96).setFill()
        NSBezierPath(roundedRect: NSRect(x: tx * k, y: by, width: z.width + 50 * k, height: 58 * k), xRadius: 29 * k, yRadius: 29 * k).fill()
        cg.restoreGState()
        a.draw(at: NSPoint(x: tx * k + 25 * k, y: by + 12 * k))
    }

    // Subtle chapter progress indicator at bottom right
    let dotY: CGFloat = 955 * k
    var dotX: CGFloat = tx * k
    for idx in 0..<scenes.count {
        let active = (idx == i)
        let dw: CGFloat = (active ? 46 : 16) * k
        let dh: CGFloat = 10 * k
        (active ? C(s.acc) : C("#ffffff", idx < i ? 0.48 : 0.22)).setFill()
        NSBezierPath(roundedRect: NSRect(x: dotX, y: dotY, width: dw, height: dh), xRadius: 5 * k, yRadius: 5 * k).fill()
        dotX += dw + 10 * k
    }

    save(rep, "bg_\(i).png")
}

// Rounded rectangle mask for the smartphone screen (white on black), size = vw x vh
let (mrep, _) = newCtx(vw, vh)
C("#000000").setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: vw, height: vh)).fill()
C("#ffffff").setFill()
NSBezierPath(
    roundedRect: NSRect(x: 0, y: 0, width: vw, height: vh),
    xRadius: innerR * k, yRadius: innerR * k
).fill()
save(mrep, "mask.png")
