//
//  test1App.swift
//  island
//
//  Created by Дмитрий Хомяков on 13.02.2025.
//

import SwiftUI

class Island {
    
    public let width: Int;
    public let height: Int;
    
    public var islands: Array<Array<Array<Life>>> = []
    
    public var x_q: Int = 0
    public var y_q: Int = 0
    
    init(w: Int, h: Int) {
        width = w
        height = h
        
        for i in 0...w {
            islands.append([])
            for j in 0...h {
                islands[i].append([])
                if Int.random(in: 0...1) == 0 {
                    islands[i][j].append(Plant(x: i, y: j))
                }
                if Int.random(in: 0...10) == 0 {
                    islands[i][j].append(Wolf(x: i, y: j))
                }
            }
        }
    }
    
    public func plantInArray(w: Int, h:Int) -> Bool {
        for objectLife in islands[w][h] {
            if type(of: objectLife) == type(of: Plant(x: -1, y: -1)) {
                return true
            }
        }
        return false
    }
    
    public func getChars(w: Int, h: Int) -> String {
        var result = ""
        for k in 0..<(self.islands[w][h].count) {
            result += islands[w][h][k].getChar() != " " ? String(islands[w][h][k].getChar()) : ""
        }
        return result
    }
    
    public func allAnimalGo() {
        var count = 0
        for i in 0...self.width {
            for j in 0...self.height {
                for k in 0..<(self.islands[i][j].count) {
                    if type(of: islands[i][j][k]) == type(of: Wolf(x: -1, y: -1)) {
                        islands[i][j][k].go()
                        if count == 0 {
                            x_q = i
                            y_q = j
                            count += 1
                        }
                    }
                }
            }
        }
        updateIsland()
    }
    
    public func updateIsland() {
        var islandsNew: Array<Array<Array<Life>>> = []
        
        var allLife: Array<Life> = []
        
        for i in 0...width {
            for j in 0...height {
                allLife += islands[i][j]
            }
        }
        
        for i in 0...width {
            islandsNew.append([])
            for j in 0...height {
                islandsNew[i].append([])
                for l in allLife {
                    if l.x == i && l.y == j {
                        islandsNew[i][j].append(l)
                    }
                }
            }
        }
        
        islands = islandsNew
    }
    
    
}

// Основные виды живых существ
class Life {
    public var x: Int;
    public var y: Int;
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    public func go() {}
    public func getChar() -> Character {return " "}
}

class Plant: Life {
    
    override init(x: Int, y:Int) {
        super.init(x: x, y: y)
    }
    
    public func die() {}
    public func getColor() -> Color {return Color.green}
}

class Animal: Life {
    public var weight: Int = 0;
    public var maxEating: Int = 0;
    public var maxSpeed: Int = 0;
    
    override init(x: Int, y:Int) {
        super.init(x: x, y: y)
    }
    
    public override func go() {}
    public func eat(anim: Array<Animal>) -> Bool {return false}
    public func die() {}
    public func reproduction(partner: Animal) -> Bool {return false}
    public override func getChar() -> Character {return " "}
}

// разделение животных на хищников и травоядных
class Predator: Animal {
    
}

class Herbivore: Animal {
    
}

// Хищники:
class Wolf: Predator {
    override init(x: Int, y: Int) {
        super.init(x: x, y: y)
        self.weight = 50
        self.maxEating = 8
        self.maxSpeed = 3
    }
    
    public override func go() {
        let speedAnimal: Int = Int.random(in: 0...maxSpeed)
        for _ in 0...speedAnimal {
            let rotateWalk: Int = Int.random(in: 0...3)
            switch rotateWalk {
            case 0:
                self.y -= 1
            case 1:
                self.x += 1
            case 2:
                self.y += 1
            case 3:
                self.x -= 1
            default:
                break
            }
        }
    }
    
    public override func getChar() -> Character {return "🐺"}
}


@main
struct islandApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
