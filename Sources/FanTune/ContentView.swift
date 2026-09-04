import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: ThermalModel
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.08, green: 0.09, blue: 0.13), Color(red: 0.035, green: 0.04, blue: 0.06)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    header
                    chipPicker
                    HStack(alignment: .top, spacing: 16) {
                        TemperatureCard()
                        FanCard()
                    }
                    HStack(alignment: .top, spacing: 16) {
                        ProfileCard()
                        HealthCard()
                    }
                    footer
                }
                .padding(30)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) { Label("FanTune", systemImage: "fan.fill").font(.system(size: 12, weight: .semibold)) }
            ToolbarItem(placement: .primaryAction) { Button(action: openSettings.callAsFunction) { Image(systemName: "gearshape") } }
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 7) {
                Label("系统状态良好", systemImage: "circle.fill").font(.caption2).foregroundStyle(.green)
                Text("温度尽在掌控").font(.system(size: 30, weight: .bold, design: .rounded))
                Text("智能平衡温度、性能与噪音。").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Picker("调速模式", selection: $model.mode) {
                ForEach(ControlMode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented).frame(width: 180)
        }
    }

    private var chipPicker: some View {
        HStack(spacing: 8) {
            ForEach(model.chips) { chip in
                Button { model.selectedChipID = chip.id; model.history = Array(repeating: chip.temperature, count: 15) } label: {
                    HStack(spacing: 12) {
                        Image(systemName: chip.id == "ssd" ? "internaldrive.fill" : "cpu.fill")
                            .frame(width: 34, height: 34).background(chip.color.opacity(0.14)).foregroundStyle(chip.color).clipShape(RoundedRectangle(cornerRadius: 9))
                        VStack(alignment: .leading, spacing: 3) { Text(chip.subtitle).font(.system(size: 9)).foregroundStyle(.secondary); Text(chip.name).font(.caption.weight(.semibold)) }
                        Spacer(); Text("\(Int(chip.temperature))°").font(.caption.weight(.bold))
                    }
                    .padding(.horizontal, 13).frame(maxWidth: .infinity, minHeight: 62)
                    .background(model.selectedChipID == chip.id ? Color.white.opacity(0.075) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 11))
                }.buttonStyle(.plain)
            }
        }
        .padding(6).background(Color.white.opacity(0.025)).overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.07)))
    }

    private var footer: some View {
        HStack { Label("后台监控已开启", systemImage: "circle.fill").foregroundStyle(.secondary); Spacer(); Text("上次更新：刚刚").foregroundStyle(.tertiary) }.font(.system(size: 9)).padding(.top, 4)
    }
}

struct Panel<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View { content.padding(22).background(LinearGradient(colors: [.white.opacity(0.07), .white.opacity(0.035)], startPoint: .topLeading, endPoint: .bottomTrailing)).clipShape(RoundedRectangle(cornerRadius: 16)).overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.075))) }
}

struct TemperatureCard: View {
    @EnvironmentObject private var model: ThermalModel
    var body: some View {
        Panel {
            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) { Text("\(model.selectedChip.name) 温度").sectionLabel(); Text("\(Int(model.selectedChip.temperature))°").font(.system(size: 48, weight: .semibold, design: .rounded)) + Text("C").font(.title3).foregroundColor(.secondary) }
                    Spacer(); VStack(alignment: .trailing) { Text("↘ 3°").foregroundStyle(.green); Text("过去 5 分钟").font(.caption2).foregroundStyle(.secondary) }
                }
                ChartLine(values: model.history).frame(height: 158)
                HStack { ForEach(["10:20","10:25","10:30","10:35","现在"], id: \.self) { Text($0); if $0 != "现在" { Spacer() } } }.font(.system(size: 8)).foregroundStyle(.tertiary)
            }
        }.frame(maxWidth: .infinity, minHeight: 290)
    }
}

struct ChartLine: View {
    let values: [Double]
    var body: some View {
        GeometryReader { geo in
            let lo = (values.min() ?? 20) - 5, hi = (values.max() ?? 80) + 5
            let points = values.enumerated().map { i, v in CGPoint(x: geo.size.width * CGFloat(i) / CGFloat(max(1, values.count - 1)), y: geo.size.height * CGFloat(1 - (v-lo)/max(1,hi-lo))) }
            ZStack {
                VStack { ForEach(0..<4) { _ in Divider().overlay(.white.opacity(0.06)); Spacer() } }
                Path { p in guard let first = points.first else { return }; p.move(to: first); for point in points.dropFirst() { p.addLine(to: point) } }.stroke(LinearGradient(colors: [.blue.opacity(.75), .cyan], startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)).shadow(color: .blue.opacity(.4), radius: 5)
            }
        }
    }
}

struct FanCard: View {
    @EnvironmentObject private var model: ThermalModel
    var body: some View {
        Panel {
            VStack(spacing: 17) {
                HStack { VStack(alignment: .leading, spacing: 4) { Text("风扇转速").sectionLabel(); Text("\(model.currentRPM.formatted()) ") .font(.title2.bold()) + Text("RPM").font(.caption).foregroundColor(.secondary) }; Spacer(); Text(model.mode.rawValue).font(.caption2).padding(.horizontal, 9).padding(.vertical, 5).background(.blue.opacity(.14)).foregroundStyle(.blue).clipShape(Capsule()) }
                HStack { Image(systemName: "fan.fill").font(.system(size: 64)).foregroundStyle(.blue.gradient).rotationEffect(.degrees(model.mode == .manual ? model.manualRPM / 10 : Double(model.currentRPM) / 10)).animation(.linear(duration: .4), value: model.currentRPM); Spacer(); VStack(alignment: .leading, spacing: 5) { Label("安静运行", systemImage: "speaker.wave.1.fill").font(.caption.bold()); Text("24 dB · 几乎听不见").font(.caption2).foregroundStyle(.secondary) } }
                Slider(value: $model.manualRPM, in: 1000...5200, step: 10).disabled(model.mode == .automatic)
                HStack { Text("1,000"); Spacer(); Text("\(model.currentRPM.formatted()) RPM"); Spacer(); Text("5,200") }.font(.system(size: 8)).foregroundStyle(.secondary)
            }
        }.frame(width: 320, minHeight: 290)
    }
}

struct ProfileCard: View {
    @EnvironmentObject private var model: ThermalModel
    var body: some View {
        Panel { VStack(alignment: .leading, spacing: 17) { Text("温控策略").sectionLabel(); Text(model.profile.rawValue).font(.title3.bold()); HStack(spacing: 8) { ForEach(ThermalProfile.allCases, id: \.self) { profile in Button { model.profile = profile } label: { VStack(alignment: .leading, spacing: 7) { Image(systemName: icon(profile)); Text(profile.rawValue).font(.caption.bold()); Text(subtitle(profile)).font(.system(size: 8)).foregroundStyle(.secondary) }.frame(maxWidth: .infinity, alignment: .leading).padding(11).background(model.profile == profile ? .blue.opacity(.14) : .white.opacity(.03)).overlay(RoundedRectangle(cornerRadius: 10).stroke(model.profile == profile ? .blue.opacity(.5) : .white.opacity(.07))).clipShape(RoundedRectangle(cornerRadius: 10)) }.buttonStyle(.plain) } } } }
        .frame(maxWidth: .infinity, minHeight: 180)
    }
    private func icon(_ p: ThermalProfile) -> String { p == .quiet ? "moon.fill" : (p == .balanced ? "diamond.fill" : "bolt.fill") }
    private func subtitle(_ p: ThermalProfile) -> String { p == .quiet ? "低噪音优先" : (p == .balanced ? "日常使用推荐" : "保持峰值性能") }
}

struct HealthCard: View {
    var body: some View { Panel { VStack(alignment: .leading, spacing: 17) { Text("散热系统").sectionLabel(); Label("一切正常", systemImage: "checkmark.circle.fill").font(.headline).foregroundStyle(.green); Text("所有传感器和风扇运行正常").font(.caption2).foregroundStyle(.secondary); Divider(); HStack { stat("2","风扇"); Spacer(); stat("12","传感器"); Spacer(); stat("18°C","温度余量") } } }.frame(width: 320, minHeight: 180) }
    private func stat(_ value: String, _ label: String) -> some View { VStack(alignment: .leading) { Text(value).font(.caption.bold()); Text(label).font(.system(size: 8)).foregroundStyle(.secondary) } }
}

struct SettingsView: View {
    @EnvironmentObject private var model: ThermalModel
    var body: some View { Form { Toggle("登录时启动", isOn: $model.launchAtLogin); Toggle("菜单栏显示温度", isOn: $model.showMenuTemperature) }.formStyle(.grouped).padding().frame(width: 430, height: 220) }
}

extension View { func sectionLabel() -> some View { self.font(.system(size: 10, weight: .semibold)).foregroundStyle(.secondary).textCase(.uppercase) } }
