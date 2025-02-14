//
//  ContentView.swift
//  test1
//
//  Created by Дмитрий Хомяков on 13.02.2025.
//

import SwiftUI


struct ContentView: View {
    
    @State var viewReloaded = false
    @State var island = Island(w: 30, h: 15)
    
    var body: some View {
        
        VStack {
            if viewReloaded{
                IslandView(island_new: island)
            }
            else{
                IslandView(island_new: island)
            }
            HStack {
                Button("Reload") {
                    island.allAnimalGo()
                    viewReloaded.toggle()
                }
                .buttonStyle(.bordered)
                .font(.system(size: 40))
                Text(String(island.x_q))
                    .font(.system(size: 40))
            }
            .padding()
        }
        .padding()
    }
}



struct IslandView: View {
    
    let island_new: Island
    
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
                                    .font(.system(size: 15))
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
