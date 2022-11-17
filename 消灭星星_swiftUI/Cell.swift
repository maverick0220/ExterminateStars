//
//  Cell.swift
//  消灭星星
//
//  Created by 周河晓 on 2019/3/20.
//  Copyright © 2019 周河晓. All rights reserved.
//

import Foundation
import SwiftUI

class Cell: ObservableObject{
    
    init(x: Int, y: Int, color: Int, mapSize: (y: Int, x: Int)){
        self.x = x
        self.y = y
        self.position = (y,x)
        self.color = color
        
        switch color{
        case 0: self.cellColor = Color.black
        case 1:self.cellColor = Color.red
        case 2:self.cellColor = Color.purple
        case 3:self.cellColor = Color.green
        case 4:self.cellColor = Color.yellow
        case 5:self.cellColor = Color.blue
        default: self.cellColor = Color.black
        }
        
        // getAttachedBy()
        if(x > 0){ attachedBy.append((y,x-1)) }
        if(x < mapSize.x - 1){ attachedBy.append((y,x+1)) }
        if(y > 0){ attachedBy.append((y-1,x)) }
        if(y < mapSize.y - 1){ attachedBy.append((y+1,x)) }
        
        // getNearby()
        if(x > 0){
            nearBy.append((y,x-1))
            if(y > 0){ nearBy.append((y-1,x-1)) }
            if(y < self.y - 1){ nearBy.append((y+1,x-1)) }
        }
        if(x < mapSize.x){
            nearBy.append((y,x+1))
            if(y > 0){ nearBy.append((y-1,x+1)) }
            if(y < self.y - 1){ nearBy.append((y+1,x+1)) }
        }
        if(y > 0){ nearBy.append((y-1,x)) }
        if(y < mapSize.y - 1){ nearBy.append((y+1,x)) }
        
    }
    
    var x: Int
    var y: Int
    var position: (y: Int, x: Int)
    
    @Published var color = 0{
        didSet{
            switch color{
            case 0: self.cellColor = Color.black
            case 1:self.cellColor = Color.red
            case 2:self.cellColor = Color.purple
            case 3:self.cellColor = Color.green
            case 4:self.cellColor = Color.yellow
            case 5:self.cellColor = Color.blue
            default: self.cellColor = Color.black
            }
        }
    }
    @Published var cellColor: Color
    //0: black
    //1: red
    //2: purper
    //3: green
    //4: yellow
    //5: blue
    
    var isMainPixel = false
    var isMarked = false
    
    var nearBy = [(Int,Int)]()//9 cells
    var attachedBy = [(Int,Int)]()//4 cells
    
    
}
