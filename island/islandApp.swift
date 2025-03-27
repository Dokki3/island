import SwiftUI
import Combine

final class Island: ObservableObject {
    static var shared: Island?
    
    let width: Int
    let height: Int
    
    @Published private(set) var plantCount: [[Int]]
    @Published private(set) var animals: [[Animal?]]
    @Published private(set) var animalCounts: [String: Int] = [:]
    
    private var simulationQueue = DispatchQueue(label: "island.simulation",
                                              qos: .userInitiated,
                                              attributes: .concurrent)
    private var timer: AnyCancellable?
    
    
    let maxAnimalsPerType = 15
    let maxAnimalsPerCell = 4
    
    init(w: Int, h: Int) {
        self.width = w
        self.height = h
        self.plantCount = Array(repeating: Array(repeating: 0, count: h), count: w)
        self.animals = Array(repeating: Array(repeating: nil, count: h), count: w)
        Island.shared = self
        initializeIsland()
    }
    
    private func initializeIsland() {
        for x in 0..<width {
            for y in 0..<height {
                plantCount[x][y] = Int.random(in: 1...3)
                
                if Int.random(in: 0..<10) == 0 {
                    animals[x][y] = AnimalFactory.createRandomAnimal(x: x, y: y)
                }
            }
        }
        updateCounts()
    }
    
    func startSimulation(interval: TimeInterval = 1.0) {
        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateIsland()
            }
    }
    
    private func updateIsland() {
        simulationQueue.async { [weak self] in
            guard let self = self else { return }
            
            var newAnimals = self.animals
            var newPlants = self.plantCount
            var needsUpdate = false
            
            // 1. Обновление состояния животных
            for x in 0..<self.width {
                for y in 0..<self.height {
                    if var animal = newAnimals[x][y] {
                        animal.update()
                        
                        if !animal.isAlive {
                            newAnimals[x][y] = nil
                            needsUpdate = true
                            continue
                        }
                        
                        let oldX = animal.x
                        let oldY = animal.y
                        animal.move(w: self.width, h: self.height)
                        
                        if oldX != animal.x || oldY != animal.y {
                            newAnimals[oldX][oldY] = nil
                            
                            if newAnimals[animal.x][animal.y] == nil {
                                newAnimals[animal.x][animal.y] = animal
                                needsUpdate = true
                            } else {
                                animal.x = oldX
                                animal.y = oldY
                                newAnimals[oldX][oldY] = animal
                            }
                        }
                        
                        if animal.tryToEat(plants: &newPlants[animal.x][animal.y],
                                          animals: &newAnimals) {
                            needsUpdate = true
                        }
                    }
                    
                    if newPlants[x][y] < 3 && Int.random(in: 0..<5) == 0 {
                        newPlants[x][y] += 1
                        needsUpdate = true
                    }
                }
            }
            
            // 2. Размножение
            if self.processReproduction(animals: &newAnimals) {
                needsUpdate = true
            }
            
            // 3. Обновление UI
            if needsUpdate {
                DispatchQueue.main.async {
                    self.animals = newAnimals
                    self.plantCount = newPlants
                    self.updateCounts()
                }
            }
        }
    }

    private func processReproduction(animals: inout [[Animal?]]) -> Bool {
        var reproduced = false
        
        for x in 0..<width {
            for y in 0..<height {
                guard let animal = animals[x][y],
                      animal.energy > animal.maxEnergy * 0.6,
                      animalCounts[String(animal.emoji)] ?? 0 < maxAnimalsPerType,
                      Int.random(in: 0..<100) < 8 else { continue }
                
                // Проверяем количество животных в текущей клетке
                var animalsInCell = 0
                for dx in -1...1 {
                    for dy in -1...1 {
                        let nx = max(0, min(x + dx, width - 1))
                        let ny = max(0, min(y + dy, height - 1))
                        if animals[nx][ny] != nil {
                            animalsInCell += 1
                        }
                    }
                }
                
                guard animalsInCell < maxAnimalsPerCell else { continue }
                
                // Поиск партнера для размножения
                for dx in -1...1 {
                    for dy in -1...1 {
                        let nx = max(0, min(x + dx, width - 1))
                        let ny = max(0, min(y + dy, height - 1))
                        
                        if let partner = animals[nx][ny],
                           type(of: animal) == type(of: partner),
                           partner.energy > partner.maxEnergy * 0.6 {
                            
                            // Ищем свободное место для потомка
                            for _ in 0..<3 {
                                let babyX = max(0, min(x + Int.random(in: -1...1), width - 1))
                                let babyY = max(0, min(y + Int.random(in: -1...1), height - 1))
                                
                                if animals[babyX][babyY] == nil {
                                    let baby = animal.reproduce()
                                    baby.energy = baby.maxEnergy * 0.5
                                    animals[babyX][babyY] = baby
                                    animal.energy *= 0.7
                                    partner.energy *= 0.7
                                    reproduced = true
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
        return reproduced
    }

    
    private func updateCounts() {
        var counts = [String: Int]()
        for x in 0..<width {
            for y in 0..<height {
                if let animal = animals[x][y] {
                    counts[String(animal.emoji), default: 0] += 1
                }
            }
        }
        animalCounts = counts
    }
    
    func getCharsAt(x: Int, y: Int) -> String {
        guard x >= 0, x < width, y >= 0, y < height,
              let animal = animals[x][y] else { return "" }
        return String(animal.emoji)
    }
}

// MARK: - Фабрика животных
struct AnimalFactory {
    private static let animalTypes: [(Int, Int) -> Animal] = [
        Wolf.init, Boa.init, Fox.init, Bear.init, Eagle.init,
        Horse.init, Deer.init, Rabbit.init, Mouse.init,
        Goat.init, Sheep.init, Boar.init, Buffalo.init,
        Duck.init, Caterpillar.init
    ]
    
    static func createRandomAnimal(x: Int, y: Int) -> Animal {
        return animalTypes.randomElement()!(x, y)
    }
    
    static func createAnimal(type: Animal.Type, x: Int, y: Int) -> Animal {
        switch type {
        case is Wolf.Type: return Wolf(x: x, y: y)
        case is Boa.Type: return Boa(x: x, y: y)
        case is Fox.Type: return Fox(x: x, y: y)
        case is Bear.Type: return Bear(x: x, y: y)
        case is Eagle.Type: return Eagle(x: x, y: y)
        case is Horse.Type: return Horse(x: x, y: y)
        case is Deer.Type: return Deer(x: x, y: y)
        case is Rabbit.Type: return Rabbit(x: x, y: y)
        case is Mouse.Type: return Mouse(x: x, y: y)
        case is Goat.Type: return Goat(x: x, y: y)
        case is Sheep.Type: return Sheep(x: x, y: y)
        case is Boar.Type: return Boar(x: x, y: y)
        case is Buffalo.Type: return Buffalo(x: x, y: y)
        case is Duck.Type: return Duck(x: x, y: y)
        case is Caterpillar.Type: return Caterpillar(x: x, y: y)
        default: return Wolf(x: x, y: y)
        }
    }
}

// MARK: - Базовый класс животного
class Animal: Identifiable, Equatable {
    var id = UUID()
    var x: Int
    var y: Int
    var kills = 0
    let emoji: Character
    let moveSpeed: Int
    
    var energy: Double
    let maxEnergy: Double
    var age = 0
    var isAlive = true
    
    init(x: Int, y: Int, emoji: Character, moveSpeed: Int, maxEnergy: Double) {
        self.x = x
        self.y = y
        self.emoji = emoji
        self.moveSpeed = moveSpeed
        self.maxEnergy = maxEnergy
        self.energy = maxEnergy * Double.random(in: 0.5...1.0)
    }
    
    func move(w: Int, h: Int) {
        guard isAlive else { return }
        
        energy -= 0.2
        guard Int.random(in: 0...100) < Int(energy/maxEnergy * 100) else { return }
        
        let directions = [(0, -1), (1, 0), (0, 1), (-1, 0)].shuffled()
        
        for _ in 0..<moveSpeed {
            if let (dx, dy) = directions.first {
                let newX = max(0, min(x + dx, w - 1))
                let newY = max(0, min(y + dy, h - 1))
                
                if newX != x || newY != y {
                    x = newX
                    y = newY
                    break
                }
            }
        }
    }
    
    func update() {
        guard isAlive else { return }
        
        age += 1
        energy -= 0.1
        
        if age > 100 || energy <= 0 {
            isAlive = false
        }
    }
    
    func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        return false
    }
    
    func canEat(_ other: Animal) -> Bool {
        return false
    }
    
    func reproduce() -> Animal {
        return AnimalFactory.createAnimal(type: type(of: self), x: x, y: y)
    }
    
    static func == (lhs: Animal, rhs: Animal) -> Bool {
        lhs.id == rhs.id
    }
    
    func checkCellCapacity(animals: [[Animal?]]) -> Bool {
            guard let island = Island.shared else { return false }
            
            var count = 0
            for dx in -1...1 {
                for dy in -1...1 {
                    let nx = max(0, min(x + dx, animals.count - 1))
                    let ny = max(0, min(y + dy, animals[0].count - 1))
                    if animals[nx][ny] != nil {
                        count += 1
                    }
                }
            }
            return count < island.maxAnimalsPerCell
        }
        
        func performEating(prey: Animal, energyGain: Double, plants: inout Int, animals: inout [[Animal?]]) -> Bool {
            energy = min(maxEnergy, energy + energyGain)
            prey.isAlive = false
            animals[x][y] = self
            kills += 1
            
            // 30% chance to spawn plant when prey is killed
            if plants < 4 && Int.random(in: 0..<3) == 0 {
                plants += 1
            }
            
            return true
        }
}

// MARK: - Базовые типы
protocol Predator {}
protocol Herbivore {}
protocol Omnivore {}

// MARK: - Хищники
final class Wolf: Animal, Predator {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, emoji: "🐺", moveSpeed: 2, maxEnergy: 100)
    }

    override func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        guard checkCellCapacity(animals: animals) else { return false }
        
        if let prey = animals[x][y], canEat(prey) {
            return performEating(prey: prey, energyGain: 25, plants: &plants, animals: &animals)
        }
        return false
    }

    override func canEat(_ other: Animal) -> Bool {
        other is Rabbit || other is Deer || other is Mouse || other is Sheep || other is Goat
    }
}

final class Boa: Animal, Predator {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, emoji: "🐍", moveSpeed: 1, maxEnergy: 70)
    }

    override func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        guard checkCellCapacity(animals: animals) else { return false }
        
        if let prey = animals[x][y], canEat(prey) {
            return performEating(prey: prey, energyGain: 20, plants: &plants, animals: &animals)
        }
        return false
    }

    override func canEat(_ other: Animal) -> Bool {
        other is Rabbit || other is Mouse || other is Duck
    }
}

final class Fox: Animal, Predator {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, emoji: "🦊", moveSpeed: 3, maxEnergy: 60)
    }

    override func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        if let prey = animals[x][y], canEat(prey), checkCellCapacity(animals: animals) {
            return performEating(prey: prey, energyGain: 15, plants: &plants, animals: &animals)
        }
        
        // Лисы могут есть растения при недостатке пищи
        if plants > 0 && energy < maxEnergy * 0.3 {
            plants -= 1
            energy = min(maxEnergy, energy + 5)
            return true
        }
        return false
    }

    override func canEat(_ other: Animal) -> Bool {
        other is Rabbit || other is Mouse || other is Duck || other is Caterpillar
    }
}

final class Bear: Animal, Omnivore {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, emoji: "🐻", moveSpeed: 2, maxEnergy: 150)
    }

    override func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        if let prey = animals[x][y], canEat(prey), checkCellCapacity(animals: animals) {
            return performEating(prey: prey, energyGain: 40, plants: &plants, animals: &animals)
        }
        
        // Медведи всеядны - едят растения
        if plants > 0 && energy < maxEnergy * 0.7 {
            plants -= 1
            energy = min(maxEnergy, energy + 10)
            return true
        }
        return false
    }

    override func canEat(_ other: Animal) -> Bool {
        other is Boa || other is Deer || other is Rabbit || other is Boar
    }
}

final class Eagle: Animal, Predator {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, emoji: "🦅", moveSpeed: 4, maxEnergy: 50)
    }

    override func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        guard checkCellCapacity(animals: animals) else { return false }
        
        if let prey = animals[x][y], canEat(prey) {
            return performEating(prey: prey, energyGain: 20, plants: &plants, animals: &animals)
        }
        return false
    }

    override func canEat(_ other: Animal) -> Bool {
        other is Rabbit || other is Mouse || other is Fox || other is Duck
    }
}

// MARK: - Травоядные
final class Horse: Animal, Herbivore {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, emoji: "🐴", moveSpeed: 4, maxEnergy: 120)
    }

    override func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        guard plants > 0 else { return false }
        plants -= 1
        energy = min(maxEnergy, energy + 15)
        return true
    }
}

final class Deer: Animal, Herbivore {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, emoji: "🦌", moveSpeed: 4, maxEnergy: 90)
    }

    override func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        guard plants > 0 else { return false }
        plants -= 1
        energy = min(maxEnergy, energy + 12)
        return true
    }
}

final class Rabbit: Animal, Herbivore {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, emoji: "🐰", moveSpeed: 3, maxEnergy: 50)
    }

    override func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        guard plants > 0 else { return false }
        plants -= 1
        energy = min(maxEnergy, energy + 8)
        return true
    }
}

final class Mouse: Animal, Omnivore {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, emoji: "🐭", moveSpeed: 2, maxEnergy: 30)
    }

    override func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        if let prey = animals[x][y], prey is Caterpillar, checkCellCapacity(animals: animals) {
            return performEating(prey: prey, energyGain: 5, plants: &plants, animals: &animals)
        }
        
        if plants > 0 {
            plants -= 1
            energy = min(maxEnergy, energy + 5)
            return true
        }
        return false
    }
}

final class Goat: Animal, Herbivore {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, emoji: "🐐", moveSpeed: 3, maxEnergy: 80)
    }

    override func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        guard plants > 0 else { return false }
        plants -= 1
        energy = min(maxEnergy, energy + 10)
        return true
    }
}

final class Sheep: Animal, Herbivore {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, emoji: "🐑", moveSpeed: 3, maxEnergy: 85)
    }

    override func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        guard plants > 0 else { return false }
        plants -= 1
        energy = min(maxEnergy, energy + 10)
        return true
    }
}

final class Boar: Animal, Omnivore {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, emoji: "🐗", moveSpeed: 2, maxEnergy: 110)
    }

    override func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        if let prey = animals[x][y], (prey is Caterpillar || prey is Mouse), checkCellCapacity(animals: animals) {
            return performEating(prey: prey, energyGain: 10, plants: &plants, animals: &animals)
        }
        
        if plants > 0 {
            plants -= 1
            energy = min(maxEnergy, energy + 12)
            return true
        }
        return false
    }
}

final class Buffalo: Animal, Herbivore {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, emoji: "🐃", moveSpeed: 3, maxEnergy: 150)
    }

    override func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        guard plants > 0 else { return false }
        plants -= 1
        energy = min(maxEnergy, energy + 20)
        return true
    }
}

final class Duck: Animal, Omnivore {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, emoji: "🦆", moveSpeed: 4, maxEnergy: 40)
    }

    override func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        if let prey = animals[x][y], prey is Caterpillar, checkCellCapacity(animals: animals) {
            return performEating(prey: prey, energyGain: 5, plants: &plants, animals: &animals)
        }
        
        if plants > 0 {
            plants -= 1
            energy = min(maxEnergy, energy + 5)
            return true
        }
        return false
    }
}

final class Caterpillar: Animal, Herbivore {
    init(x: Int, y: Int) {
        super.init(x: x, y: y, emoji: "🐛", moveSpeed: 0, maxEnergy: 10)
    }

    override func tryToEat(plants: inout Int, animals: inout [[Animal?]]) -> Bool {
        guard plants > 0 else { return false }
        plants -= 1
        energy = min(maxEnergy, energy + 2)
        return true
    }
}

@main
struct IslandApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
