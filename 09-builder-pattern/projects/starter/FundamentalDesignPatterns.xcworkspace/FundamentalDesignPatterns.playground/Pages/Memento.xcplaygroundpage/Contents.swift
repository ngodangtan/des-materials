/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Memento
 - - - - - - - - - -
 ![Memento Diagram](Memento_Diagram.png)
 
 The memento pattern allows an object to be saved and restored. It involves three parts:
 
 (1) The **originator** is the object to be saved or restored.
 
 (2) The **memento** is a stored state.
 
 (3) The **caretaker** requests a save from the originator, and it receives a memento in response. The care taker is responsible for persisting the memento, so later on, the care taker can provide the memento back to the originator to request the originator restore its state.
 
 ## Code Example
 */
/*
 1. Memento Pattern là gì?

 Thuộc nhóm Behavioral Patterns.

 Ý tưởng: lưu lại trạng thái (state) của object để sau này có thể phục hồi (restore) về đúng trạng thái đó, mà không để lộ chi tiết nội bộ của object.

 👉 Bạn có thể tưởng tượng:

 Memento = snapshot (ảnh chụp).

 Originator = đối tượng gốc (cần được lưu/khôi phục).

 Caretaker = người quản lý memento (giữ snapshot, nhưng không biết chi tiết bên trong).

 2. Khi nào nên dùng?

 Khi muốn có chức năng undo/redo (hoàn tác/làm lại).

 Khi cần lưu checkpoint trong game, editor, workflow.

 Khi cần lưu state tạm thời mà không phá vỡ encapsulation (object không để lộ hết nội bộ ra ngoài).
 */
import Foundation

// Originator
class Game {
    var playerName: String
    var level: Int
    var score: Int
    
    init(playerName: String, level: Int, score: Int) {
        self.playerName = playerName
        self.level = level
        self.score = score
    }
    
    func save() -> GameMemento {
        return GameMemento(playerName: playerName, level: level, score: score)
    }
    
    func restore(from memento: GameMemento) {
        self.playerName = memento.playerName
        self.level = memento.level
        self.score = memento.score
    }
}

// Memento (chỉ để Game tạo ra và dùng)
struct GameMemento {
    fileprivate let playerName: String
    fileprivate let level: Int
    fileprivate let score: Int
}

// Caretaker
class GameSystem {
    private var savedGames = [GameMemento]()
    
    func saveGame(_ memento: GameMemento) {
        savedGames.append(memento)
    }
    
    func loadGame(at index: Int) -> GameMemento {
        return savedGames[index]
    }
}

let game = Game(playerName: "Alice", level: 1, score: 100)

let system = GameSystem()

// Save checkpoint
system.saveGame(game.save())

// Chơi tiếp
game.level = 2
game.score = 500

// Save lần 2
system.saveGame(game.save())

// Khôi phục về checkpoint đầu
let checkpoint1 = system.loadGame(at: 0)
game.restore(from: checkpoint1)

print(game.level, game.score) // => 1, 100
