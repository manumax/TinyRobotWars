//
//  Interpreter.swift
//  TinyRobotWars
//
//  Created by Manuele Mion on 30/09/2017.
//  Copyright © 2017 manumax. All rights reserved.
//

import UIKit

// MARk:

class Interpreter: Visitor {
    
    var stack: [Int] = []
    var registers: [String: Int] = [:]
    
    func visit(_ node: Node) {
        switch node {
        case .number(let value):
            stack.append(value)
        case .register(let name):
            stack.append(registers[name] ?? 0)
        case .unaryOp:
            visit(unaryOp: node)
        case .binaryOp:
            visit(binaryOp: node)
        case .to:
            visit(to: node)
        }
    }
    
    func visit(unaryOp node: Node) {
        if case let .unaryOp(op, node) = node {
            visit(node)
            var value = stack.removeLast()
            if case .minus = op {
                value *= -1
            }
            stack.append(value)
        }
    }
    
    func visit(binaryOp node: Node) {
        if case let .binaryOp(op, left, right) = node {
            visit(left)
            visit(right)
            switch op {
            case .plus:
                stack.append(stack.removeLast() + stack.removeLast())
            case .minus:
                stack.append(stack.removeLast() - stack.removeLast())
            case .times:
                stack.append(stack.removeLast() * stack.removeLast())
            case .divide:
                stack.append(stack.removeLast() / stack.removeLast())
            }
        }
    }
    
    func visit(to node: Node) {
        if case let .to(register, registers) = node {
            visit(register)
            let value = stack.removeLast()
            for register in registers {
                if case let .register(key) = register {
                    self.registers[key] = value
                }
            }
        }
    }
}
