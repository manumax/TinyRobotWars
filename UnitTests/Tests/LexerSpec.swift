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

class LexerSharedExamplesConfiguration: QuickConfiguration {
    override class func configure(_ configuration: Configuration) {
        sharedExamples("parsed string") { context in
            it("should have the expected token") {
                let input = context()["input"] as! String
                let expected: [Token] = context()["expected"] as! [Token]
                let tokens: [Token] = Lexer(withString: input).lex()
                expect(tokens).to(equal(expected))
            }
        }
    }
}

class LexerSpec: QuickSpec {
    override func spec() {
        describe("applying lexer") {
            describe("1 TO A") {
                itBehavesLike("parsed string") {
                    [
                        "input": "1 TO A",
                        "expected": [.number(1), .to, .register("A")] as [Token]
                    ]
                }
            }
            
            describe("0 TO SPEEDX TO SPEEDY") {
                itBehavesLike("parsed string") {
                    [
                        "input": "0 TO SPEEDX TO SPEEDY",
                        "expected": [.number(0), .to, .register("SPEEDX"), .to, .register("SPEEDY")] as [Token]
                    ]
                }
            }

            describe("-240 TO SPEEDX") {
                itBehavesLike("parsed string") {
                    [
                        "input": "-240 TO SPEEDX",
                        "expected": [.op(Operator.minus), .number(240), .to, .register("SPEEDX")] as [Token]
                    ]
                }
            }

            describe("240 + 100 TO A") {
                itBehavesLike("parsed string") {
                    [
                        "input": "240 + 100 TO A",
                        "expected": [.number(240), .op(Operator.plus), .number(100), .to, .register("A")] as [Token]
                    ]
                }
            }
            
            describe("H-X*100 TO SPEEDX") {
                itBehavesLike("parsed string") {
                    [
                        "input": "H-X*100 TO SPEEDX",
                        "expected": [
                            .register("H"),
                            .op(Operator.minus),
                            .register("X"),
                            .op(Operator.times),
                            .number(100),
                            .to,
                            .register("SPEEDX")
                        ] as [Token]
                    ]
                }
            }

            describe("IF DAMAGE # D GOTO MOVE") {
                itBehavesLike("parsed string") {
                    [
                        "input": "IF DAMAGE # D GOTO MOVE",
                        "expected": [
                            .`if`,
                            .register("DAMAGE"),
                            .relOp(.notEqual),
                            .register("D"),
                            .goto,
                            .label("MOVE")
                            ] as [Token]
                    ]
                }
            }
            
            describe("GOSUB MOVE") {
                itBehavesLike("parsed string") {
                    [
                        "input": "GOSUB MOVE",
                        "expected": [
                            .gosub,
                            .label("MOVE")
                        ] as [Token]
                    ]
                }
            }
            
            describe("ENDSUB") {
                itBehavesLike("parsed string") {
                    [
                        "input": "ENDSUB",
                        "expected": [
                            .endsub
                        ] as [Token]
                    ]
                }
            }
            
            describe("DAMAGE TO D ;SAVE CURRENT DAMAGE") {
                itBehavesLike("parsed string") {
                    [
                        "input": "DAMAGE TO D ;SAVE CURRENT DAMAGE",
                        "expected": [
                            .register("DAMAGE"),
                            .to,
                            .register("D"),
                            .comment("SAVE CURRENT DAMAGE")
                        ] as [Token]
                    ]
                }
            }
        }
    }
}
