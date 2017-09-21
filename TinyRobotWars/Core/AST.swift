//
//  AST.swift
//  TinyRobotWars
//
//  Created by Manuele Mion on 21/02/2017.
//  Copyright © 2017 manumax. All rights reserved.
//

import Foundation

/**

 <expr> ::= <term> ((<plus> | <minus>) <term>)*
 <term> ::= <factor> ((<mul> | <div>) <factor>)*
 <factor> ::= <number> | <register>
 
 <number> ::= ([0-9])+
 <plus>  ::= '+'
 <minus> ::= '-'
 <mult>  ::= '*'
 <div>   ::= '/'
 */

//<register> ::= [A..Z] | 'AIM' | 'SHOOT' | 'RADAR' | 'DAMAGE' | 'SPEEDX' | 'SPEEDY' | 'RANDOM' | 'INDEX'

// <program> ::= <statement> | <statement> <program>
// 
// <statement> ::= <to> | <if> | <goto> | <gosub> | <endsub> | <label>
// <to> ::= <expr> 'TO' <register>
// <if> ::= 'IF' <expr> <cond> <expr> <goto>
// <goto> ::= 'GOTO' <label>
// <gosub> ::= 'GOSUB' <label>
// <endsub> ::= 'ENDSUB'
// <expr> ::= <term> | <term> <op> <expr>
// <term> ::= <digit> | <register>
//
// <cond> ::= '=' | '#' | '<' | '>'
// <label> ::= [A..Z]+
// <register> ::= [A..Z] | 'AIM' | 'SHOOT' | 'RADAR', 'DAMAGE', 'SPEEDX', 'SPEEDY', 'RANDOM', 'INDEX's

// MARK: - AST

protocol Node {
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

// MARK: - <number>

class NumberNode: Node {
    let value: Int
    
    init(_ value: Int) {
        self.value = value
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

// MARK: - <plus>, <minus>, <mult>, <div>

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
        guard let token = self.currentToken, case let Token.number(value) = token else {
            throw ParserError.unexpectedTokenError
        }
        self.eat()
        return NumberNode(value)
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
        guard let node = try? self.term(), let token = self.currentToken, case let Token.op(op) = token else {
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
