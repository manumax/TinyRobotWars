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
            
            describe("-2 * -7") {
                let lexer = Lexer(withString: "-2 * -7")
                let parser = Parser(withLexer: lexer)
                let node: Node = try! parser.parse()
                it("should return the correct tree") {
                    /*
                     Expected:
                            *
                          /   \
                         -     -
                          \     \
                           2     7
                     */
                    let expected = BinOpNode(left: UnaryOpNode(op: .op(.minus), expr: NumberNode(2)), op: .op(.times), right: UnaryOpNode(op: .op(.minus), expr: NumberNode(7)))
                    expect(node.isEqualTo(other: expected)).to(beTrue())
                }
            }
            
            describe("1 * 3 TO A") {
                let lexer = Lexer(withString: "1 * 3 TO A")
                let parser = Parser(withLexer: lexer)
                let node: Node = try! parser.parse()
                it("should return the correct tree") {
                    /*
                     Expected:
                         `to`
                         /   \
                        *     A
                      /   \
                     1     3
                     */
                    let expected = ToNode(expr: BinOpNode(left: NumberNode(1), op: .op(.times), right: NumberNode(3)), register: .register("A"))
                    expect(node.isEqualTo(other: expected)).to(beTrue())
                }
            }
        }
    }
}
