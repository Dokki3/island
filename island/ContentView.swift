//
//  ContentView.swift
//  test1
//
//  Created by Дмитрий Хомяков on 13.02.2025.
//

import SwiftUI


struct ContentView: View {
    
    @State var refresh = false
    @State var island = Island(w: 30, h: 15)
    
    @State var timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
    @State var timerPause = false
    
    var body: some View {
        
        VStack {
            IslandView(island_new: island, refresh: refresh)
                .onReceive(timer) {_ in
                    if Int.random(in: 0...1) == 0 {
                        island.allAnimalGo()
                    } else {
                        island.allAnimalEat()
                    }
                    island.updateIsland()
                    refresh.toggle()
                }
            HStack {
                Text(String(island.countWolf()))
                    .padding()
                    .font(.system(size: 15))
                
                Button("playpause", systemImage: "playpause.fill") {
                    if !timerPause {
                        timer = Timer.publish(every: 999999, on: .current, in: .common).autoconnect()
                        timerPause.toggle()
                    } else {
                        timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
                        timerPause.toggle()
                    }
                }
                .buttonStyle(.bordered)
                .padding()
                .font(.system(size: 15))
                
                Text(String(island.countHorse()))
                    .padding()
                    .font(.system(size: 15))
            }
        }
        .background(Color.green)
        .padding()
    }
}



struct IslandView: View {
    
    let island_new: Island
    
    @State var refresh: Bool
    
    /*init(island_new: Island) {
        self.island_new = island_new
    }*/
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<30) {i in
                HStack(spacing: 0) {
                    ForEach(0..<15){j in
                        Rectangle()
                            .frame(width: 25, height: 25)
                            .foregroundColor(island_new.plantInArray(w: i, h: j) ? Color.green : Color.gray)
                            .overlay(
                                Text(island_new.getChars(w: i, h: j))
                                    .font(.system(size: 7))
                            )
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
