import SwiftUI

struct ContentView: View {
    @StateObject private var island = Island(w: 20, h: 15)
    @State private var timerPause = true
    
    var speedSimulation = 1
    
    var body: some View {
        VStack {
            IslandView(island: island)
                    
            Spacer()
            
            VStack {
                
                Text("Population: \(island.animalCounts.values.reduce(0, +))")
                
                Spacer()
                
                HStack {
                    
                    Button("", systemImage: "playpause.fill") {
                        timerPause.toggle()
                        island.startSimulation(interval: timerPause ? 0.5 : 99999999999)
                    }
                    .font(.system(size: 30))
                    
                    Spacer()
                    
                    Menu {
                        ForEach(island.animalCounts.sorted(by: { $0.key < $1.key }), id: \.key) { emoji, count in
                            Text("\(emoji): \(count)")
                        }
                    } label: {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 30))
                    }
                }
            }
            .padding()
        }
        .background(Color.cyan)
        .onAppear {
            island.startSimulation(interval: timerPause ? 0.5 : 99999999999) // Установка скорости 1 секунда
        }
    }
}

struct IslandView: View {
    @ObservedObject var island: Island
    let colors = [Color(red: 1, green: 1, blue: 0), Color(red: 0, green: 0.8, blue: 0), Color(red: 0, green: 0.6, blue: 0), Color(red: 0, green: 0.4, blue: 0), Color(red: 0, green: 0.2, blue: 0)]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<island.width, id: \.self) { x in
                HStack(spacing: 0) {
                    ForEach(0..<island.height, id: \.self) { y in
                        CellView(island: island, x: x, y: y, colors: colors)
                    }
                }
            }
        }
        .padding(2)
    }
}

struct CellView: View {
    @ObservedObject var island: Island
    let x: Int
    let y: Int
    let colors: [Color]
    
    var body: some View {
        Rectangle()
            .frame(width: 25, height: 25)
            .foregroundColor(colors[min(island.plantCount[x][y], colors.count - 1)])
            .overlay(
                Text(island.getCharsAt(x: x, y: y))
                    .font(.system(size: 7))
            )
    }
}

#Preview{
    ContentView()
}
