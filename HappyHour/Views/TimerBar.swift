
import SwiftUI

struct TimerStarter: View {
    @EnvironmentObject var timer: TaskTimer
    @Binding var popupVisible: Bool
    
    func start(_ minutes: Int) {
        timer.start(minutes: minutes)
        popupVisible = false
    }
    
    var body: some View {
        VStack {
            Text ("Start Focus Timer:")
            HStack {
                Button(action: { start( 5) }) { Text( "5m") }
                Button(action: { start(10) }) { Text("10m") }
                Button(action: { start(15) }) { Text("15m") }
                Button(action: { start(20) }) { Text("20m") }
                Button(action: { start(30) }) { Text("30m") }
                Button(action: { start(45) }) { Text("45m") }
                Button(action: { start(55) }) { Text("55m") }
            }
        }
        .padding()
    }
}

struct TimerBar: View {
    @EnvironmentObject var timer: TaskTimer
    
    var body: some View {
        Group {
            if timer.status == .running {
                HStack {
                    Text("Focus Timer is running: \(timer.duration) min")
                    Spacer()
                    Button(action: { timer.reset() }) { Text("Cancel") }
                        .foregroundColor(.accentColor)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondary)
                .cornerRadius(15)
            } else if timer.status == .finished {
                HStack {
                    Text("Focus Timer Finished:")
                    Spacer()
                    Button(action: { timer.start(minutes: timer.duration) }) {
                        Text("Repeat: \(timer.duration)m")
                    }
                    Button(action: { timer.reset() }) { Text("Okay!") }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(15)
            }
        }
    }
}

struct TimerBar_Previews: PreviewProvider {
    static let envs = [
        TaskTimer.Status.idle: TaskTimer(),
        TaskTimer.Status.running: {
            let t = TaskTimer()
            t.status = .running
            t.duration = 10
            return t
        }(),
        TaskTimer.Status.finished: {
            let t = TaskTimer()
            t.status = .finished
            t.duration = 10
            return t
        }()
    ]
    
    static var previews: some View {
        Group {
            TimerStarter(popupVisible: .constant(true)).environmentObject(envs[.idle]!)
            TimerBar().environmentObject(envs[.running]!)
            TimerBar().environmentObject(envs[.finished]!)
        }
    }
}