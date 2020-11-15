
import SwiftUI

struct TimerBar: View {
    @EnvironmentObject var timer: TaskTimer
    
    func statusColor(_ stat:TaskTimer.Status) -> Color {
        switch stat {
        case .idle: return Color.clear
        case .running: return Color.gray
        case .finished: return Color.blue
        }
    }
    
    var body: some View {
        HStack {
            if self.timer.status == .idle {
                Text("Focus Timer:")
                Spacer()
                Button(action: { self.timer.start(minutes:  5) }) { Text( "5m") }
                Button(action: { self.timer.start(minutes: 10) }) { Text("10m") }
                Button(action: { self.timer.start(minutes: 15) }) { Text("15m") }
                Button(action: { self.timer.start(minutes: 20) }) { Text("20m") }
                Button(action: { self.timer.start(minutes: 30) }) { Text("30m") }
                Button(action: { self.timer.start(minutes: 45) }) { Text("45m") }
                Button(action: { self.timer.start(minutes: 55) }) { Text("55m") }
            } else if self.timer.status == .running {
                Text("Focus Timer is running: \(self.timer.duration) min")
                Spacer()
                Button(action: { self.timer.reset() }) { Text("Cancel") }
            } else { // status is .finished
                Text("Focus Timer Finished:")
                Spacer()
                Button(action: { self.timer.start(minutes: self.timer.duration) }) {
                    Text("Repeat: \(self.timer.duration)m")
                }
                Button(action: { self.timer.reset() }) { Text("Okay!") }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(statusColor(self.timer.status))
        .border(Color.secondary, width: 4)
    }
}

struct TimerBar_Previews: PreviewProvider {
    static var previews: some View {
        TimerBar()
    }
}
