//
//  Interpreter.swift
//  TinyRobotWars
//
//  Created by Manuele Mion on 30/09/2017.
//  Copyright © 2017 manumax. All rights reserved.
//

import UIKit

// MARk:

class Interpreter: NodeVisitor {
    
    var registers: [String: Int] = [:]

    func visit(node: NumberNode) -> Int {
        return node.value
    }

    func visit(node: UnaryOp) -> Int {
        switch node.op {
        case Token.op(.plus):
            return node.expr.accept(visitor: self)
        case Token.op(.minus):
            return -1 * node.expr.accept(visitor: self)
        default:
            // This shouldn't never happen.
            return 0
        }
    }

    func visit(node: BinOpNode) -> Int {
        guard case let Token.op(op) = node.op else {
            // FIXME: throw
            return 0
        }
        switch op {
        case .plus:
            return node.left.accept(visitor: self) + node.right.accept(visitor: self)
        case .minus:
            return node.left.accept(visitor: self) - node.right.accept(visitor: self)
        case .times:
            return node.left.accept(visitor: self) * node.right.accept(visitor: self)
        case .divide:
            return node.left.accept(visitor: self) / node.right.accept(visitor: self)
        }
    }
    
    func visit(node: ToNode) -> Int {
        guard case let Token.register(register) = node.register else {
            // FIXME: throw
            return 0
        }
        let value = node.expr.accept(visitor: self)
        self.registers[register] = value
        return value
    }
}

