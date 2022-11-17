import SwiftUI

@main
struct ExterminateStars: App {
    var body: some Scene {
        WindowGroup {
            let game = Game(mapSize: (14, 9))
            ContentView(game: game)
        }
    }
}
