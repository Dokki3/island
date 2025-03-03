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
    
    public var islands: Array<Array<Array<Object>>> = []
    
    public var x_q: Int = 0
    public var y_q: Int = 0
    
    init(w: Int, h: Int) {
        width = w
        height = h
        
        for i in 0...w {
            islands.append([])
            for j in 0...h {
                islands[i].append([])
                for _ in 0...Int.random(in: 0...4) {
                    islands[i][j].append(Plant(x: i, y: j))
                }
                if Int.random(in: 0...10) == 0 {
                    switch Int.random(in: 0...4) {
                    case 0: islands[i][j].append(Wolf(x: i, y: j))
                    case 1: islands[i][j].append(Horse(x: i, y: j))
                    case 2: islands[i][j].append(Bear(x: i, y: j))
                    case 3: islands[i][j].append(Fox(x: i, y: j))
                    case 4: islands[i][j].append(Rabbit(x: i, y: j))
                    default: continue
                    }
                }
            }
        }
    }
    
    public func plantInArray(w: Int, h:Int) -> Int {
        var c: Int = 0
        for objectLife in islands[w][h] {
            if ((objectLife as? Plant) != nil)  {
                c += 1
            }
        }
        return c
    }
    
    public func getChars(w: Int, h: Int) -> String {
        var result = ""
        for k in 0..<(self.islands[w][h].count) {
            result += islands[w][h][k].getChar() != " " ? String(islands[w][h][k].getChar()) : ""
        }
        return result
    }
    
    public func allAnimalGo() {
        for i in 0...self.width {
            for j in 0...self.height {
                for k in 0..<(self.islands[i][j].count) {
                    islands[i][j][k].go(w: width, h: height)
                }
            }
        }
    }
    
    public func allAnimalEat() {
        for i in 0...self.width {
            for j in 0...self.height {
                for k in islands[i][j] {
                    if Int.random(in: 0...1) == 0 {
                        let eatingObject: Object? = k.eat(anim: islands[i][j])
                        if eatingObject != nil {
                            var ind: Int = -1
                            for (index, obj) in islands[i][j].enumerated() {
                                if obj == eatingObject {
                                    ind = index
                                    //print("\(k.getChar()) (\(String(describing: k.id))) съел \(islands[i][j][ind].getChar() != " " ? islands[i][j][ind].getChar() : "🟩") (\(String(describing: islands[i][j][ind].id))) а хотел съесть \(String(describing: eatingObject?.getChar() != " " ? eatingObject?.getChar() : "🟩")) (\(String(describing: eatingObject?.id)))")
                                    break
                                }
                            }
                            if ind != -1 {
                                islands[i][j].remove(at: ind)
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func updateIsland() {
        var islandsNew: Array<Array<Array<Object>>> = []
        
        var allLife: Array<Object> = []
        
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
    
    public func countWolf() -> Int {
        var count: Int = 0
        for i in 0...width {
            for j in 0...height {
                for l in islands[i][j] {
                    if ((l as? Wolf) != nil) {
                        count += 1
                    }
                }
            }
        }
        return count
    }

    public func countHorse() -> Int {
        var count: Int = 0
        for i in 0...width {
            for j in 0...height {
                for l in islands[i][j] {
                    if ((l as? Horse) != nil) {
                        count += 1
                    }
                }
            }
        }
        return count
    }

}

// общий класс
class Object {
    public var x: Int;
    public var y: Int;
    public var id: UnsafeMutableRawPointer? = nil;
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
        self.id = Unmanaged.passUnretained(self).toOpaque()
    }
    
    public func go(w: Int, h: Int) {}
    public func eat(anim: Array<Object>) -> Object? {return nil}
    public func die() {}
    public func reproduction(partner: Animal) -> Bool {return false}
    public func getChar() -> Character {return " "}
    public func getColor() -> Color {return Color.white}
}

// Расширение пользовательского типа
extension Object: Equatable {
    static func == (left: Object, right: Object) -> Bool {
        if left.x == right.x && left.y == right.y && left.id == right.id {
            return true
        } else {
            return false
        }
    }
}

// Основные виды живых существ
class Plant: Object {
    
    var c: Color = Color.green
    
    override init(x: Int, y:Int) {
        super.init(x: x, y: y)
    }
    
    public override func die() {c = Color.red}
    public override func getColor() -> Color {return c}
}

class Animal: Object {
    public var weight: Double = 0;
    public var maxEating: Double = 0;
    public var maxSpeed: Int = 0;
    
    override init(x: Int, y:Int) {
        super.init(x: x, y: y)
    }
    
    public override func go(w: Int, h: Int) {
        let speedAnimal: Int = Int.random(in: 0...maxSpeed)
        for _ in 0...speedAnimal {
            let rotateWalk: Int = Int.random(in: 0...3)
            switch rotateWalk {
            case 0:
                if self.y - 1 >= 0 {
                    self.y -= 1
                }
            case 1:
                if self.x + 1 < w {
                    self.x += 1
                }
            case 2:
                if self.y + 1 < h {
                    self.y += 1
                }
            case 3:
                if self.x - 1 >= 0 {
                    self.x -= 1
                }
            default:
                break
            }
        }
    }
    
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
    
    public override func eat(anim: Array<Object>) -> Object? {
        var q: Int;
        q = Int.random(in: 0...100)
        var randHors: Bool = 0 < q && q < 91
        q = Int.random(in: 0...100)
        var randRabbit: Bool = 0 < q && q < 61
        
        for i in anim {
            if randHors && randRabbit {
                if Int.random(in: 0...1) == 0 {
                    if ((i as? Horse?) != nil) {
                        //print("\(self.getChar()) съел \(i.getChar() != " " ? i.getChar() : "🟩")")
                        return i
                    }
                } else {
                    if ((i as? Rabbit?) != nil) {
                        //print("\(self.getChar()) съел \(i.getChar() != " " ? i.getChar() : "🟩")")
                        return i
                    }
                }
            } else {
                if randHors {
                    if ((i as? Horse?) != nil) {
                        //print("\(self.getChar()) съел \(i.getChar() != " " ? i.getChar() : "🟩")")
                        return i
                    }
                }
                if randRabbit {
                    if ((i as? Rabbit?) != nil) {
                        //print("\(self.getChar()) съел \(i.getChar() != " " ? i.getChar() : "🟩")")
                        return i
                    }
                }
            }
            
        }
        return nil
    }
    
    public override func getChar() -> Character {return "🐺"}
}

class Bear: Predator {
    override init(x: Int, y: Int) {
        super.init(x: x, y: y)
        self.weight = 500
        self.maxEating = 80
        self.maxSpeed = 2
    }
    
    public override func eat(anim: Array<Object>) -> Object? {
        var q: Int;
        q = Int.random(in: 0...100)
        var randHors: Bool = 0 < q && q < 41
        q = Int.random(in: 0...100)
        var randRabbit: Bool = 0 < q && q < 81
        
        for i in anim {
            if randHors && randRabbit {
                if Int.random(in: 0...1) == 0 {
                    if ((i as? Horse?) != nil) {
                        //print("\(self.getChar()) съел \(i.getChar() != " " ? i.getChar() : "🟩")")
                        return i
                    }
                } else {
                    if ((i as? Rabbit?) != nil) {
                        //print("\(self.getChar()) съел \(i.getChar() != " " ? i.getChar() : "🟩")")
                        return i
                    }
                }
            } else {
                if randHors {
                    if ((i as? Horse?) != nil) {
                        //print("\(self.getChar()) съел \(i.getChar() != " " ? i.getChar() : "🟩")")
                        return i
                    }
                }
                if randRabbit {
                    if ((i as? Rabbit?) != nil) {
                        //print("\(self.getChar()) съел \(i.getChar() != " " ? i.getChar() : "🟩")")
                        return i
                    }
                }
            }
            
        }
        return nil
    }
    
    public override func getChar() -> Character {return "🐻"}
}

class Fox: Predator {
    override init(x: Int, y: Int) {
        super.init(x: x, y: y)
        self.weight = 8
        self.maxEating = 2
        self.maxSpeed = 2
    }
    
    public override func eat(anim: Array<Object>) -> Object? {
        var q: Int;
        q = Int.random(in: 0...100)
        var randRabbit: Bool = 0 < q && q < 71
        
        for i in anim {
            if randRabbit {
                if ((i as? Rabbit?) != nil) {
                    //print("\(self.getChar()) съел \(i.getChar() != " " ? i.getChar() : "🟩")")
                    return i
                }
            }
            
        }
        return nil
    }
    
    public override func getChar() -> Character {return "🦊"}
}


// Травоядные:
class Horse: Herbivore {
    
    var ch: Character = "🐴"
    
    override init(x: Int, y: Int) {
        super.init(x: x, y: y)
        self.weight = 400
        self.maxEating = 60
        self.maxSpeed = 4
    }
    
    public override func eat(anim: Array<Object>) -> Object? {
        for i in anim {
            if ((i as? Plant?) != nil) {
                //print("\(self.getChar()) съел \(i.getChar() != " " ? i.getChar() : "🟩")")
                return i
            }
        }
        return nil
    }
    
    public override func getChar() -> Character {return ch}
    
    public override func die() {ch = "❌"}
}

class Rabbit: Herbivore {
    
    var ch: Character = "🐰"
    
    override init(x: Int, y: Int) {
        super.init(x: x, y: y)
        self.weight = 2
        self.maxEating = 0.45
        self.maxSpeed = 2
    }
    
    public override func eat(anim: Array<Object>) -> Object? {
        for i in anim {
            if ((i as? Plant?) != nil) {
                //print("\(self.getChar()) съел \(i.getChar() != " " ? i.getChar() : "🟩")")
                return i
            }
        }
        return nil
    }
    
    public override func getChar() -> Character {return ch}
    
    public override func die() {ch = "❌"}
}


@main
struct islandApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
