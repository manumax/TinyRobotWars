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

//            describe("IF DAMAGE # D GOTO MOVE") {
//                let tokens: [Token] = Lexer(withString: "IF DAMAGE # D GOTO MOVE").lex()
//                it("should return six tokens") {
//                    expect(tokens).to(haveCount(6))
//                }
//                it("should return have `if` as first token") {
//                    expect(tokens[0]).to(equal(.if))
//                }
//                it("should return have op `#` as third token") {
//                    expect(tokens[2]).to(equal(.op(.notEqual)))
//                }
//                it("should return have `goto` as fifth token") {
//                    expect(tokens[4]).to(equal(.goto))
//                }
//                it("should return have `label` as sixth token") {
//                    expect(tokens[5]).to(equal(.label("MOVE")))
//                }
//            }
//
//            describe("IF DAMAGE = D GOTO MOVE") {
//                let tokens: [Token] = Lexer(withString: "IF DAMAGE = D GOTO MOVE").lex()
//                it("should return have op `=` as third token") {
//                    expect(tokens[2]).to(equal(.op(.equal)))
//                }
//            }
//
//            describe("IF DAMAGE > D GOTO MOVE") {
//                let tokens: [Token] = Lexer(withString: "IF DAMAGE > D GOTO MOVE").lex()
//                it("should return have op `>` as third token") {
//                    expect(tokens[2]).to(equal(.op(.greaterThan)))
//                }
//            }
//
//            describe("IF DAMAGE < D GOTO MOVE") {
//                let tokens: [Token] = Lexer(withString: "IF DAMAGE < D GOTO MOVE").lex()
//                it("should return have op `<` as third token") {
//                    expect(tokens[2]).to(equal(.op(.lessThan)))
//                }
//            }
//
//            describe("GOSUB MOVE") {
//                let tokens: [Token] = Lexer(withString: "GOSUB MOVE").lex()
//                it("should return two tokens") {
//                    expect(tokens).to(haveCount(2))
//                }
//                it("should return have `gosub` as first token") {
//                    expect(tokens[0]).to(equal(.gosub))
//                }
//                it("should return have `label` as second token") {
//                    expect(tokens[1]).to(equal(.label("MOVE")))
//                }
//            }
//
//            describe("ENDSUB") {
//                let tokens: [Token] = Lexer(withString: "ENDSUB").lex()
//                it("should return one token") {
//                    expect(tokens).to(haveCount(1))
//                }
//                it("should return have `endsub` as first token") {
//                    expect(tokens[0]).to(equal(.endsub))
//                }
//            }
//
//            describe("DAMAGE TO D ;SAVE CURRENT DAMAGE") {
//                let tokens: [Token] = Lexer(withString: "DAMAGE TO D;SAVE CURRENT DAMAGE").lex()
//                it("should return one token") {
//                    expect(tokens).to(haveCount(4))
//                }
//                it("should return have a `comment` as last token") {
//                    expect(tokens.last!).to(equal(.comment("SAVE CURRENT DAMAGE")))
//                }
//            }
        }
    }
}
