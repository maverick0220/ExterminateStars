//
//  Map.swift
//  消灭星星_swiftUI
//
//  Created by 周河晓 on 2022/11/16.
//

import Foundation
import SwiftUI


class Game: ObservableObject{
    init(mapSize: (Int, Int)){
        self.mapSize = mapSize
        self.points = 0.0
        self.highestPoints = 0.0
        self.restCellCount = mapSize.0 * mapSize.1
        
        self.createMap()
        self.refreshMap()
    }
    
    var mapSize: (y: Int, x: Int)
    @Published var map = [[Cell]]()
    @Published var restCellCount: Int
    @Published var points: Double{
        didSet{
            if self.highestPoints < points{
                highestPoints = points
            }
        }
    }
    @Published var highestPoints: Double
    
    private func createMap(){
        // create cells
        self.map.removeAll()
        var sub = [Cell]()
        for y in 0...self.mapSize.y{
            for x in 0...self.mapSize.x{
                let cell = Cell(x: x, y: y, color: 0, mapSize: self.mapSize)
                sub.append(cell)
            }
            self.map.append(sub)
            sub.removeAll()
        }
    }
        
    public func refreshMap(){
        //分块，每块定个主色
        //其他格子随机决定：1.是否与主色一致；2.如果不一致，该是什么颜色
        var count = 0
        for i in 0..<self.mapSize.y{
            for j in 0..<self.mapSize.x{
                self.map[i][j].isMainPixel = false
                if(Int.random(in: 1...10) < 3 && count < 4){
                    self.map[i][j].isMainPixel = true
                }
                self.map[i][j].color = Int.random(in: 1...5)//Int(arc4random()%5+1)
            }
            count = 0
        }
        
        var color = [Int]()
        for i in 0..<self.mapSize.y{
            for j in 0..<self.mapSize.x{
                if(self.map[i][j].isMainPixel){
                    for n in self.map[i][j].nearBy{
                        if(self.map[n.0][n.1].isMainPixel){
                            color.append(self.map[n.0][n.1].color)
                            //多添加一次
                        }
                        color.append(self.map[n.0][n.1].color)
                    }
                    
                    var c = [Int](repeating: 0, count: 6)//每个位置代表对应颜色出现次数
                    for i in color{
                        c[i] += 1
                    
                    }
                    
                    var t = 0
                    var m = 0
                    for i in 0..<c.count{
                        if(c[i] >= t){
                            m = i
                            t = c[i]
                        }
                    }
                    self.map[i][j].color = m//这个cell的颜色就是周围出现次数最多的颜色
                }
                
            }
        }
    }

    public func getTapAtCell(y: Int, x: Int){
        if self.verifyTap(y, x){
            self.operatTap(y, x)
        }
        
        if self.gameContinue() == false{
            self.restCellCount = self.getRestCellNum()
            
            self.points += self.calculateExtraPoints()
            if self.points > self.highestPoints{
                self.highestPoints = self.points
            }
            self.points = 0.0
            
            self.refreshMap()
        }
    }

    private func gameContinue()->Bool{
        for i in 0..<self.mapSize.y{
            for j in 0..<self.mapSize.x{
                if(self.map[i][j].color != 0){
                    for p in self.map[i][j].attachedBy{
                        if(self.map[i][j].color == self.map[p.0][p.1].color){
                            return true
                        }
                    }
                }
                
            }
        }
        return false
    }

    private func verifyTap(_ y: Int,_ x: Int)->Bool{
        if(self.map[y][x].color == 0){ return false }
        for n in self.map[y][x].attachedBy{
            if(self.getCellColor(at: n) == self.map[y][x].color){
                return true
            }
        }
        return false
        
    }
    
    private func getCellColor(at position: (y: Int, x: Int)) -> Int{
        return self.map[position.y][position.x].color
    }
    
    private func getCellMarkStatus(at position: (y: Int, x: Int)) -> Bool{
        return self.map[position.y][position.x].isMarked
    }
    
    private func setMarkerAt(at position: (y: Int, x: Int)){
        self.map[position.y][position.x].isMarked = true
    }
    
    private func calculatePoints(cellsCount: Int) -> Double{
        return log10(Double(cellsCount))
    }
    
    private func calculateExtraPoints() -> Double{
        let extra = Double(2 * self.mapSize.x - self.getRestCellNum())
        if extra > 0{ return extra }
        return 0.0
    }

    private func operatTap(_ y: Int,_ x: Int){
        //格子不能动，只能是格子的属性在移动
        
        var s = [Cell]()//search
        var t = [Cell]()//targets to clean
        
        let color = self.map[y][x].color
        s.append(self.map[y][x])
        
        repeat{
            if(s[0].color == color){
                t.append(s[0])
                self.setMarkerAt(at: s[0].position)
                for n in s[0].attachedBy{
                    if(self.getCellColor(at: n) == color && self.getCellMarkStatus(at: n) == false){
                        s.append(self.map[n.0][n.1])
                    }
                }
            }
            s.remove(at: 0)
        }while(s.count > 0)
        
        for i in 0..<t.count{
            t[i].color = 0
            t[i].isMarked = false
        }
        self.points += self.calculatePoints(cellsCount: t.count)
        
        //start clean up：
        //this is just a bubble_sort methond you jackass!
        var rear = 0
        
        //in ROW:
        for x in 0..<self.mapSize.x{
            for y in 0..<self.mapSize.y{
                if(self.map[y][x].color == 0){
                    rear = y
                    while(rear < self.mapSize.y){
                        if(self.map[rear][x].color != 0){
                            self.map[y][x].color = self.map[rear][x].color
                            self.map[rear][x].color = 0
                            break
                        }
                        rear += 1
                    }
                    
                }
            }
        }
        
        //among ROWS:
        for x in 0..<self.mapSize.x{
            if(self.map[0][x].color == 0){
                
                rear = x
                //print("from: \(rear)")
                while(rear < self.mapSize.x){
                    //print("\(rear): \(map[rear][0].color)")
                    if(self.map[0][rear].color != 0){ break }
                    rear += 1
                }
                for y in 0..<self.mapSize.y{
                    //print("to: \(rear)")
                    if(self.map[y][rear].color != 0){
                        self.map[y][x].color = self.map[y][rear].color
                        self.map[y][rear].color = 0
                    }else{
                        break
                    }
                }
                
            }
        }
        
    }

    public func getRestCellNum()->Int{
        var colors = [Int]()
        
        var counter = 0
        for i in 0..<self.mapSize.y{
            for j in 0..<self.mapSize.x{
                colors.append(self.map[i][j].color)
                if(self.map[i][j].color != 0){
                    counter += 1
                }
            }
        }
        print(counter, colors)
        return counter
    }

}
