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
        switch node.op {
        case Token.op(.plus):
            return node.left.accept(visitor: self) + node.right.accept(visitor: self)
        case Token.op(.minus):
            return node.left.accept(visitor: self) - node.right.accept(visitor: self)
        case Token.op(.times):
            return node.left.accept(visitor: self) * node.right.accept(visitor: self)
        case Token.op(.divide):
            return node.left.accept(visitor: self) / node.right.accept(visitor: self)
        default:
            // This shouldn't never happen.
            return 0
        }
    }
}

