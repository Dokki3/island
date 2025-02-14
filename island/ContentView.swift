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
    
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    var body: some View {
        
        VStack {
            IslandView(island_new: island, refresh: refresh)
                .onReceive(timer) {_ in
                    island.allAnimalGo()
                    refresh.toggle()
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
