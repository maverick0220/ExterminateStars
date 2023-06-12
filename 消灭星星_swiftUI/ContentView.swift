//
//  ContentView.swift
//  消灭星星_swiftUI
//
//  Created by Maverick on 2022/11/16.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var game: Game
    var body: some View {
        VStack{
            HStack{
                VStack{
                    Text("   Best: \(game.highestPoints)")
                    Text("Points: \(game.points)")
                }
                .frame(alignment: .leading)
                Text("\t\t\t\t\t Rest: \(game.restCellCount)")
                    .frame(alignment: .trailing)
                    
            }
            MapView(game: game)
            
            Button("reset"){
                game.refreshMap()
            }
            
        }
        .padding()
    }
}

struct MapView: View{
    @ObservedObject var game: Game
    
    var body: some View{
        GeometryReader{ geo in
            self.body(g: geo)
        }
    }
    
    @ViewBuilder
    func body(g: GeometryProxy) -> some View{
        VStack(spacing: 1){
            ForEach(0..<game.mapSize.y){ y in
                HStack(spacing: 1){
                    ForEach(0..<game.mapSize.x){ x in
                        CellView(cell: game.map[game.mapSize.y - 1 - y][x])
                            .onTapGesture {
                                game.getTapAtCell(y: game.mapSize.y - 1 - y, x: x)
                            }
                    }
                }
            }
        }
    }
}


struct CellView: View{
    @ObservedObject var cell: Cell
    
    var body: some View{
        GeometryReader{ geo in
            self.body(g: geo)
        }
    }
    
    @ViewBuilder
    func body(g: GeometryProxy) -> some View{
        ZStack{
            RoundedRectangle(cornerRadius: 2.0)
                .fill(cell.cellColor)
        }
    }
    
}
