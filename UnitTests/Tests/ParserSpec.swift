//
//  LexerSpec.swift
//  TinyRobotWars
//
//  Created by Manuele Mion on 19/02/2017.
//  Copyright © 2017 manumax. All rights reserved.
//

import Quick
import Nimble

@testable import TinyRobotWars

class ParserSpec: QuickSpec {
    override func spec() {
        describe("applying parser") {
            describe("1 + 2 * 4") {
                let lexer = Lexer(withString: "1 + 2 * 4")
                let parser = Parser(withLexer: lexer)
                let node: Node = try! parser.parse()                
                it("should return the correct tree") {
                    /*
                     Expected:
                         +
                       /   \
                      1     *
                          /   \
                         2     4
                    */
                    let expected = BinOpNode(left: NumberNode(1), op: .op(.plus), right: BinOpNode(left: NumberNode(2), op: .op(.times), right: NumberNode(4)))
                    expect(node.isEqualTo(other: expected)).to(beTrue())
                }
            }
            
//            describe("1 + A TO A") {
//                let lexer = Lexer(withString: "1 + A TO A")
//                let parser = Parser(withLexer: lexer)
//                let node: Node? = try! parser.parse()
//                it("should return the correct tree") {
//                    expect(node).notTo(beNil())
//                    expect(node).to(beAKindOf(ExprNode.self))
//                    let expr = node as! ExprNode
//                    expect(expr.term).to(beAKindOf(NumberNode.self))
//                    expect(expr.op).to(beAKindOf(OpNode.self))
//                    expect(expr.expr).to(beAKindOf(RegisterNode.self))
//                }
//            }
        }
    }
}
