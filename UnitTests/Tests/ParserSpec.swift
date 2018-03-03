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
                    let expected = Node.binaryOp(
                        .plus,
                        .number(1),
                        .binaryOp(
                            .times,
                            .number(2),
                            .number(4)
                        )
                    )
                    expect(node).to(equal(expected))
                }
            }
            
            describe("1 + 2 + 3 - 4") {
                let lexer = Lexer(withString: "1 + 2 + 3 - 4")
                let parser = Parser(withLexer: lexer)
                let node: Node = try! parser.parse()
                it("should return the correct tree") {
                    /*
                     Expected:
                          +
                        /   \
                       1     +
                           /   \
                          2     -
                              /   \
                             3     4
                     */
                    let expected = Node.binaryOp(
                        .plus,
                        .number(1),
                        .binaryOp(
                            .plus,
                            .number(2),
                            .binaryOp(
                                .minus,
                                .number(3),
                                .number(4)
                            )
                        )
                    )
                    expect(node).to(equal(expected))
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
                    let expected = Node.binaryOp(
                        .times,
                        .unaryOp(.minus, .number(2)),
                        .unaryOp(.minus, .number(7))
                    )
                    expect(node).to(equal(expected))
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
                    let expected = Node.to(
                        .binaryOp(
                            .times,
                            .number(1),
                            .number(3)
                        ),
                        [ .register("A") ]
                    )
                    expect(node).to(equal(expected))
                }
            }

            describe("0 TO SPEEDX TO SPEEDY") {
                let lexer = Lexer(withString: "0 TO SPEEDX TO SPEEDY")
                let parser = Parser(withLexer: lexer)
                let node: Node = try! parser.parse()
                it("should return the correct tree") {
                    /*
                     Expected:
                          `to`
                         /    \
                       `0`  [SPEEDX, SPEEDY]
                     */
                    let expected = Node.to(.number(0), [ .register("SPEEDX"), .register("SPEEDY") ])
                    expect(node).to(equal(expected))
                }
            }

            describe("H-X*100 TO SPEEDX") {
                let lexer = Lexer(withString: "H-X*100 TO SPEEDX")
                let parser = Parser(withLexer: lexer)
                let node: Node = try! parser.parse()
                it("should return the correct tree") {
                    /*
                     Expected:
                           `to`
                         /      \
                        -     SPEEDX
                      /   \
                     H     *
                         /   \
                        X    100
                     */
                    let expected = Node.to(
                        .binaryOp(
                            .minus,
                            .register("H"),
                            .binaryOp(
                                .times,
                                .register("X"),
                                .number(100)
                            )
                        ),
                        [ .register("SPEEDX") ]
                    )
                    expect(node).to(equal(expected))
                }
            }
        }
    }
}
