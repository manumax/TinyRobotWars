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

enum Node {
    case number(Int)
    case register(String)
    indirect case unaryOp(Operator, Node)
    indirect case binaryOp(Operator, Node, Node)
    indirect case to(Node, [Node])
}

extension Node: Equatable {
    static func ==(lhs: Node, rhs: Node) -> Bool {
        switch (lhs, rhs) {
        case let (.number(l), .number(r)): return l == r
        case let (.register(l), .register(r)): return l == r
        case let (.unaryOp(lop, lnode), .unaryOp(rop, rnode)):
            return lop == rop && lnode == rnode
        case let (.binaryOp(lop, llnode, lrnode), .binaryOp(rop, rlnode, rrnode)):
            return lop == rop && llnode == rlnode && lrnode == rrnode
        case let (.to(lnode, lnodes), .to(rnode, rnodes)):
            return lnode == rnode && lnodes == rnodes
        default: return false
        }
    }
}

protocol Visitor {
    func visit(_ node: Node)
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
            if case .op(let op) = token {
                self.eat()
                return .unaryOp(op, try self.factor())
            }
            throw ParserError.invalidSyntaxError
        case .number(let value):
            self.eat()
            return .number(value)
        case .register(let name):
            self.eat()
            return .register(name)
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
            return .binaryOp(op, node, try self.factor())
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
            return .binaryOp(op, node, try self.expr())
        default:
            return node
        }
    }
    
    func statement() throws -> Node {
        return try to()
    }
    
    func to() throws -> Node {
        let expr = try self.expr()
        
        var registers = [Node]()
        while let token = self.currentToken, case .to = token {
            self.eat()
            if let token = self.currentToken, case let .register(name) = token {
                self.eat()
                registers.append(Node.register(name))
            } else {
                throw ParserError.unexpectedTokenError
            }
        }
        
        if registers.count == 0 {
            return expr
        }
        
        return .to(expr, registers)
    }

    func parse() throws -> Node {
        return try self.statement()
    }
}
