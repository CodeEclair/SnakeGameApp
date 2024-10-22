//
//  SnakeGameView.swift
//  SnakeGameApp
//
//  Created by Валерия Беленко on 22/10/2024.
//

import SwiftUI

struct SnakeGameView: View {
    private let rows = 20
    private let columns = 20
    private let gridSize = 20.0
    @State private var snakePositions = [CGPoint(x: 10, y: 10)]
    @State private var foodPosition = CGPoint(x: 5, y: 5)
    @State private var direction = Direction.right
    @State private var isGameOver = false
    
    private enum Direction {
        case up, down, left, right
    }
    
    private func moveSnake() {
        var newHead = snakePositions[0]
        switch direction {
        case .up: newHead.y -= 1
        case .down: newHead.y += 1
        case .left: newHead.x -= 1
        case .right: newHead.x += 1
        }
        
        snakePositions.insert(newHead, at: 0)
        
        if newHead == foodPosition {
            spawnFood()
        } else {
            snakePositions.removeLast()
        }
        
        if newHead.x < 0 || newHead.x >= CGFloat(columns) ||
            newHead.y < 0 || newHead.y >= CGFloat(rows) ||
            snakePositions[1...].contains(newHead) {
            isGameOver = true
        }
    }
    
    private func spawnFood() {
        foodPosition = CGPoint(x: CGFloat(Int.random(in: 0..<columns)),
                               y: CGFloat(Int.random(in: 0..<rows)))
    }
    
    private func changeDirection(to newDirection: Direction) {
        if (direction == .up && newDirection != .down) ||
           (direction == .down && newDirection != .up) ||
           (direction == .left && newDirection != .right) ||
           (direction == .right && newDirection != .left) {
            direction = newDirection
        }
    }
    
    var body: some View {
        VStack {
            if isGameOver {
                Text("Game Over")
                    .font(.largeTitle)
                    .padding()
                Button("Restart") {
                    snakePositions = [CGPoint(x: 10, y: 10)]
                    direction = .right
                    isGameOver = false
                    spawnFood()
                }
            } else {
                GeometryReader { geometry in
                    ZStack {
                        // Drawing snake
                        ForEach(snakePositions, id: \.self) { position in
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: gridSize, height: gridSize)
                                .position(x: position.x * gridSize + gridSize / 2,
                                          y: position.y * gridSize + gridSize / 2)
                        }
                        
                        // Drawing food
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: gridSize, height: gridSize)
                            .position(x: foodPosition.x * gridSize + gridSize / 2,
                                      y: foodPosition.y * gridSize + gridSize / 2)
                    }
                }
                .background(Color.black)
                .frame(width: gridSize * CGFloat(columns), height: gridSize * CGFloat(rows))
                .onAppear(perform: spawnFood)
                .gesture(DragGesture()
                            .onEnded { value in
                                let horizontalMovement = value.translation.width
                                let verticalMovement = value.translation.height
                                if abs(horizontalMovement) > abs(verticalMovement) {
                                    if horizontalMovement > 0 {
                                        changeDirection(to: .right)
                                    } else {
                                        changeDirection(to: .left)
                                    }
                                } else {
                                    if verticalMovement > 0 {
                                        changeDirection(to: .down)
                                    } else {
                                        changeDirection(to: .up)
                                    }
                                }
                            })
                .onReceive(Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()) { _ in
                    moveSnake()
                }
            }
        }
    }
}

struct SnakeGameView_Previews: PreviewProvider {
    static var previews: some View {
        SnakeGameView()
    }
}

