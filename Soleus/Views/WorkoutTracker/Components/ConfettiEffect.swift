import SwiftUI

private struct ConfettiParticle: Identifiable {
    let id: Int
    let symbol: String
    let color: Color
    let vx: CGFloat        // initial x velocity pts/sec
    let vy: CGFloat        // initial y velocity pts/sec (negative = up)
    let rotationSpeed: Double
    let scale: CGFloat
}

private struct ConfettiBurstView: View {
    let particles: [ConfettiParticle]

    private let gravity: CGFloat = 900
    private let duration: TimeInterval = 3.0

    @State private var startTime = Date.now

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(startTime)
            let t = CGFloat(elapsed)
            let fade = max(0, 1.0 - elapsed / duration)

            ZStack {
                ForEach(particles) { p in
                    Image(systemName: p.symbol)
                        .font(.system(size: 20 * p.scale))
                        .foregroundColor(p.color)
                        .rotationEffect(.degrees(p.rotationSpeed * elapsed))
                        .offset(
                            x: p.vx * t,
                            y: p.vy * t + 0.5 * gravity * t * t
                        )
                        .opacity(fade)
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { startTime = .now }
    }
}

private func makeParticles(
    symbols: [String],
    count: Int,
    radius: CGFloat
) -> [ConfettiParticle] {
    let colors: [String: [Color]] = [
        "dumbbell.fill": [.blue, .gray, .cyan],
        "trophy.fill": [.yellow, .orange, Color(red: 1.0, green: 0.84, blue: 0.0)]
    ]

    let baseSpeed = radius * 1.3
    return (0..<count).map { i in
        let symbol = symbols[i % symbols.count]
        let palette = colors[symbol] ?? [.white]
        let angle = Double.random(in: 0..<360) * .pi / 180
        let speed = baseSpeed * CGFloat.random(in: 0.3...1.0)

        return ConfettiParticle(
            id: i,
            symbol: symbol,
            color: palette[Int.random(in: 0..<palette.count)],
            vx: cos(angle) * speed,
            vy: sin(angle) * speed - 400,
            rotationSpeed: Double.random(in: -400...400),
            scale: CGFloat.random(in: 0.5...1.4)
        )
    }
}

struct ConfettiCannonModifier: ViewModifier {
    @Binding var counter: Int
    let symbols: [String]
    let particleCount: Int
    let radius: CGFloat

    @State private var particles: [ConfettiParticle]?
    @State private var burstId = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                if let particles {
                    ConfettiBurstView(particles: particles)
                        .id(burstId)
                }
            }
            .onChange(of: counter) {
                burstId += 1
                particles = makeParticles(
                    symbols: symbols,
                    count: particleCount,
                    radius: radius
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    particles = nil
                }
            }
    }
}

extension View {
    func confettiCannon(
        counter: Binding<Int>,
        symbols: [String] = ["dumbbell.fill", "trophy.fill"],
        particleCount: Int = 40,
        radius: CGFloat = 500
    ) -> some View {
        modifier(ConfettiCannonModifier(
            counter: counter,
            symbols: symbols,
            particleCount: particleCount,
            radius: radius
        ))
    }
}
