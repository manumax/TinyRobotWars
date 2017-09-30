//
//  AST.swift
//  TinyRobotWars
//
//  Created by Manuele Mion on 21/02/2017.
//  Copyright © 2017 manumax. All rights reserved.
//

import Foundation

/**
 Grammar:
 
 <expr> ::= <term> ((<plus> | <minus>) <term>)*
 <term> ::= <factor> ((<mul> | <div>) <factor>)*
 <factor> ::= (<plus> | <minus>) <factor> | <number>
 
 <number> ::= ([0-9])+
 <plus>  ::= '+'
 <minus> ::= '-'
 <mult>  ::= '*'
 <div>   ::= '/'
 */

/**
 Yet to implement:

 <register> ::= [A..Z] | 'AIM' | 'SHOOT' | 'RADAR' | 'DAMAGE' | 'SPEEDX' | 'SPEEDY' | 'RANDOM' | 'INDEX'

 <program> ::= <statement> | <statement> <program>

 <statement> ::= <to> | <if> | <goto> | <gosub> | <endsub> | <label>
 <to> ::= <expr> 'TO' <register>
 <if> ::= 'IF' <expr> <cond> <expr> <goto>
 <goto> ::= 'GOTO' <label>
 <gosub> ::= 'GOSUB' <label>
 <endsub> ::= 'ENDSUB'
 <term> ::= <digit> | <register>
 <cond> ::= '=' | '#' | '<' | '>'
 label> ::= [A..Z]+
 <register> ::= [A..Z] | 'AIM' | 'SHOOT' | 'RADAR', 'DAMAGE', 'SPEEDX', 'SPEEDY', 'RANDOM', 'INDEX's
*/

protocol NodeVisitor {
    func visit(node: NumberNode) -> Int
    func visit(node: UnaryOp) -> Int
    func visit(node: BinOpNode) -> Int
    func visit(node: Node) -> Int
}

extension NodeVisitor {
    func visit(node: Node) -> Int {
        return node.accept(visitor: self)
    }
}

protocol Visitable {
    func accept(visitor: NodeVisitor) -> Int
}

// MARK: - AST

protocol Node: Visitable {
    func isEqualTo(other: Node) -> Bool
}

extension Node where Self : Equatable {
    func isEqualTo(other: Node) -> Bool {
        if let other = other as? Self {
            return self == other
        }
        return false
    }
}

// MARK: - Number

class NumberNode: Node {
    let value: Int
    
    init(_ value: Int) {
        self.value = value
    }
}

extension NumberNode: Visitable {
    func accept(visitor: NodeVisitor) -> Int {
        return visitor.visit(node: self)
    }
}

extension NumberNode: Equatable {
    public static func ==(lhs: NumberNode, rhs: NumberNode) -> Bool {
        return lhs.value == rhs.value
    }
}

extension NumberNode: CustomStringConvertible {
    var description: String {
        return "\(value)"
    }
}

// MARK: Unary Op

class UnaryOp: Node {
    let op: Token
    let expr: Node
    
    init(op: Token, expr: Node) {
        self.op = op
        self.expr = expr
    }
}

extension UnaryOp: Visitable {
    func accept(visitor: NodeVisitor) -> Int {
        return visitor.visit(node: self)
    }
}

extension UnaryOp: Equatable {
    public static func ==(lhs: UnaryOp, rhs: UnaryOp) -> Bool {
        guard case let Token.op(lop) = lhs.op, case let Token.op(rop) = rhs.op else {
            return false
        }
        return lhs.expr.isEqualTo(other: rhs.expr) && lop.rawValue == rop.rawValue
    }
}
extension UnaryOp: CustomStringConvertible {
    var description: String {
        if case let Token.op(op) = self.op {
            return "\(op.rawValue) \(self.expr)"
        }
        return ""
    }
}

// MARK: - Binary Op

class BinOpNode: Node {
    let left: Node
    let op: Token
    let right: Node
    
    init(left: Node, op: Token, right: Node) {
        self.left = left
        self.op = op
        self.right = right
    }
}

extension BinOpNode: Visitable {
    func accept(visitor: NodeVisitor) -> Int {
        return visitor.visit(node: self)
    }
}

extension BinOpNode: Equatable {
    public static func ==(lhs: BinOpNode, rhs: BinOpNode) -> Bool {
        guard case let Token.op(lop) = lhs.op, case let Token.op(rop) = rhs.op else {
            return false
        }
        return lhs.left.isEqualTo(other: rhs.left) &&
               lhs.right.isEqualTo(other: rhs.right) &&
               lop.rawValue == rop.rawValue
    }
}

extension BinOpNode: CustomStringConvertible {
    var description: String {
        if case let Token.op(op) = self.op {
            return "\(self.left) \(op.rawValue) \(self.right)"
        }
        return ""
    }
}

// MARK: - Parser

enum ParserError: Error {
    case invalidSyntaxError
    case unexpectedTokenError
}

class Parser {
    private let lexer: Lexer
    private var currentToken: Token?

    init(withLexer lexer: Lexer) {
        self.lexer = lexer
        self.currentToken = lexer.next()
    }

    func eat() {
        self.currentToken = self.lexer.next()
    }
    
    func factor() throws -> Node {
        // <factor> ::= (<plus> | <minus>) <factor> | <number>
        guard let token = self.currentToken else {
            throw ParserError.unexpectedTokenError
        }
        
        switch token {
        case .op(.plus): fallthrough
        case .op(.minus):
            self.eat()
            return UnaryOp(op: token, expr: try self.factor())
        case .number(let value):
            self.eat()
            return NumberNode(value)
        default:
            throw ParserError.unexpectedTokenError
        }
    }
    
    func term() throws -> Node {
        // <term> ::= <factor> ((<mul> | <div>) <factor>)*
        guard let node = try? self.factor(), let token = self.currentToken, case let Token.op(op) = token else {
            throw ParserError.unexpectedTokenError
        }
        
        switch op {
        case .times: fallthrough
        case .divide:
            self.eat()
            return BinOpNode(left: node, op: token, right: try self.factor())
        default:
            return node
        }
    }

    func expr() throws -> Node {
        // <expr> ::= <term> ((<plus> | <minus>) <term>)*
        let node = try self.term()
        
        guard let token = self.currentToken else {
            return node
        }
        guard case let Token.op(op) = token else {
            throw ParserError.unexpectedTokenError
        }
        
        switch op {
        case .plus: fallthrough
        case .minus:
            self.eat()
            return BinOpNode(left: node, op: token, right: try self.term())
        default:
            return node
        }
    }

    func parse() throws -> Node {
        return try self.expr()
    }
}
