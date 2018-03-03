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
 
 <statement> ::= <to>
 <to> ::= <expr> ('TO' <register>)+
 <expr> ::= <term> ((<plus> | <minus>) <expr>)*
 <term> ::= <factor> ((<mul> | <div>) <factor>)*
 <factor> ::= (<plus> | <minus>) <factor> | <register> | <number>
 
 <number> ::= ([0-9])+
 <plus>  ::= '+'
 <minus> ::= '-'
 <mult>  ::= '*'
 <div>   ::= '/'
 
 <register> ::= [A..Z] | 'AIM' | 'SHOOT' | 'RADAR' | 'DAMAGE' | 'SPEEDX' | 'SPEEDY' | 'RANDOM' | 'INDEX'
 */

protocol NodeVisitor {
    func visit(node: NumberNode) -> Int
    func visit(node: UnaryOpNode) -> Int
    func visit(node: BinOpNode) -> Int
    func visit(node: ToNode) -> Int
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

class RegisterNode: Node {
    let name: String
    init(_ name: String) {
        self.name = name
    }
}

extension RegisterNode: Visitable {
    func accept(visitor: NodeVisitor) -> Int {
        return visitor.visit(node: self)
    }
}

extension RegisterNode: Equatable {
    public static func ==(lhs: RegisterNode, rhs: RegisterNode) -> Bool {
        return lhs.name == rhs.name
    }
}

extension RegisterNode: CustomStringConvertible {
    var description: String {
        return "r:\(name)"
    }
}

// MARK: Unary Op

class UnaryOpNode: Node {
    let op: Token
    let expr: Node
    
    init(op: Token, expr: Node) {
        self.op = op
        self.expr = expr
    }
}

extension UnaryOpNode: Visitable {
    func accept(visitor: NodeVisitor) -> Int {
        return visitor.visit(node: self)
    }
}

extension UnaryOpNode: Equatable {
    public static func ==(lhs: UnaryOpNode, rhs: UnaryOpNode) -> Bool {
        guard case let Token.op(lop) = lhs.op, case let Token.op(rop) = rhs.op else {
            return false
        }
        return lhs.expr.isEqualTo(other: rhs.expr) && lop.rawValue == rop.rawValue
    }
}

extension UnaryOpNode: CustomStringConvertible {
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

// MARK: `TO` node

class ToNode: Node {
    let expr: Node
    let registers: [String]
    
    init(expr: Node, registers: [String]) {
        self.expr = expr
        self.registers = registers
    }
}

extension ToNode: Visitable {
    func accept(visitor: NodeVisitor) -> Int {
        return visitor.visit(node: self)
    }
}

extension ToNode: Equatable {
    public static func ==(lhs: ToNode, rhs: ToNode) -> Bool {
        return lhs.registers == rhs.registers && lhs.expr.isEqualTo(other: rhs.expr)
    }
}

extension ToNode: CustomStringConvertible {
    var description: String {
        var desc = "\(self.expr)"
        for register in registers {
            desc += " TO \(register)"
        }
        return desc
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
            return UnaryOpNode(op: token, expr: try self.factor())
        case .number(let value):
            self.eat()
            return NumberNode(value)
        case .register(let name):
            self.eat()
            return RegisterNode(name)
        default:
            throw ParserError.unexpectedTokenError
        }
    }
    
    func term() throws -> Node {
        // <term> ::= <factor> ((<mul> | <div>) <factor>)*
        let node = try self.factor()
        
        guard let token = self.currentToken, case let Token.op(op) = token else {
            return node
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
        
        guard let token = self.currentToken, case let Token.op(op) = token else {
            return node
        }
        
        switch op {
        case .plus: fallthrough
        case .minus:
            self.eat()
            return BinOpNode(left: node, op: token, right: try self.expr())
        default:
            return node
        }
    }
    
    func statement() throws -> Node {
        return try to()
    }
    
    func to() throws -> Node {
        let expr = try self.expr()
        
        var registers = [String]()
        while let token = self.currentToken, case .to = token {
            self.eat()
            if let token = self.currentToken, case let .register(name) = token {
                self.eat()
                registers.append(name)
            } else {
                throw ParserError.unexpectedTokenError
            }
        }
        
        if registers.count == 0 {
            return expr
        }        
        return ToNode(expr: expr, registers: registers)
    }

    func parse() throws -> Node {
        return try self.statement()
    }
}
