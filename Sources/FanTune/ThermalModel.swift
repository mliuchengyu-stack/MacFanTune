import Foundation
import SwiftUI

enum ControlMode: String, CaseIterable { case automatic = "自动", manual = "手动" }
enum ThermalProfile: String, CaseIterable { case quiet = "静音", balanced = "平衡", performance = "性能" }

struct Chip: Identifiable, Hashable {
    let id: String
    let subtitle: String
    let name: String
    var temperature: Double
    let color: Color
}

@MainActor
final class ThermalModel: ObservableObject {
    @Published var chips = [
        Chip(id: "cpu", subtitle: "Apple M3 Max", name: "CPU", temperature: 47, color: .blue),
        Chip(id: "gpu", subtitle: "40 核", name: "GPU", temperature: 43, color: .purple),
        Chip(id: "ssd", subtitle: "2 TB", name: "SSD", temperature: 36, color: .cyan)
    ]
    @Published var selectedChipID = "cpu"
    @Published var mode: ControlMode = .automatic
    @Published var profile: ThermalProfile = .balanced
    @Published var manualRPM = 1840.0
    @Published var launchAtLogin = true
    @Published var showMenuTemperature = true
    @Published var history: [Double] = [38,39,41,40,39,43,42,44,43,46,44,47,45,48,47]

    private var timer: Timer?

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    deinit { timer?.invalidate() }

    var selectedChip: Chip { chips.first(where: { $0.id == selectedChipID }) ?? chips[0] }
    var currentRPM: Int {
        if mode == .manual { return Int(manualRPM) }
        let base = 1050 + max(0, selectedChip.temperature - 30) * 47
        let multiplier: Double = profile == .quiet ? 0.82 : (profile == .performance ? 1.35 : 1)
        return min(5200, max(1000, Int(base * multiplier)))
    }

    private func tick() {
        guard let index = chips.firstIndex(where: { $0.id == selectedChipID }) else { return }
        chips[index].temperature = min(82, max(29, chips[index].temperature + Double.random(in: -1.2...1.1)))
        history.append(chips[index].temperature)
        if history.count > 28 { history.removeFirst() }
    }
}
