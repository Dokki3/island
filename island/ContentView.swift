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
                Button("", systemImage: "playpause.fill") {
                    if !timerPause {
                        timer = Timer.publish(every: 999999, on: .current, in: .common).autoconnect()
                        timerPause.toggle()
                    } else {
                        timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
                        timerPause.toggle()
                    }
                }
                .padding()
                .font(.system(size: 30))
                
                @State var countAnimal = island.count()
                
                Spacer()
                
                Menu("", systemImage: "exclamationmark.circle.fill") {
                    ForEach(countAnimal.keys, id: \.self) { emoji in
                        Button("\(emoji): \(countAnimal[emoji]!)") {}
                    }
                }
                .font(.system(size: 30))
                
            }
            .padding()
        }
        .background(Color(red: 0, green: 255, blue: 0))
        .padding()
    }
}

struct IslandView: View {
    
    let island_new: Island
    
    let colors_green: [Color] = [Color.gray, Color(red: 0, green: 0.8, blue: 0), Color(red: 0, green: 0.6, blue: 0), Color(red: 0, green: 0.4, blue: 0), Color(red: 0, green: 0.2, blue: 0)]
    
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
                            .foregroundColor(colors_green[island_new.plantInArray(w: i, h: j)])
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
