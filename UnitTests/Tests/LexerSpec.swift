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

class LexerSpec: QuickSpec {
    override func spec() {
        describe("applying lexer") {
            
            describe("1 TO A") {
                let tokens: [Token] = Lexer(withString: "1 TO A").lex()
                it("should return three tokens") {
                    expect(tokens).to(haveCount(3))
                }
                it("should return numer 1 as first token") {
                    expect(tokens[0]).to(equal(.number(1)))
                }
                it("should return token `TO` as second token") {
                    expect(tokens[1]).to(equal(.to))
                }
                it("should return register `A` as third token") {
                    expect(tokens[2]).to(equal(.register("A")))
                }
            }
            
            describe("0 TO SPEEDX TO SPEEDY") {
                let tokens: [Token] = Lexer(withString: "0 TO SPEEDX TO SPEEDY").lex()
                it("should return five tokens") {
                    expect(tokens).to(haveCount(5))
                }
                it("should return have `SPEEDY` as last token") {
                    expect(tokens.last!).to(equal(.register("SPEEDY")))
                }
            }
            
            describe("-240 TO SPEEDX") {
                let tokens: [Token] = Lexer(withString: "-240 TO SPEEDX").lex()
                it("should return three tokens") {
                    expect(tokens).to(haveCount(4))
                }
                it("should return have `-` as first token") {
                    expect(tokens.first!).to(equal(.op(.minus)))
                }
            }

            describe("240 + 100 TO A") {
                let tokens: [Token] = Lexer(withString: "240 + 100 TO A").lex()
                it("should return five tokens") {
                    expect(tokens).to(haveCount(5))
                }
                it("should return have `+` as second token") {
                    expect(tokens[1]).to(equal(.op(.plus)))
                }
            }
            
            describe("H-X*100 TO SPEEDX") {
                let tokens: [Token] = Lexer(withString: "H-X*100 TO SPEEDX").lex()
                it("should return seven tokens") {
                    expect(tokens).to(haveCount(7))
                }
            }

            describe("IF DAMAGE # D GOTO MOVE") {
                let tokens: [Token] = Lexer(withString: "IF DAMAGE # D GOTO MOVE").lex()
                it("should return six tokens") {
                    expect(tokens).to(haveCount(6))
                }
                it("should return have `if` as first token") {
                    expect(tokens[0]).to(equal(.if))
                }
                it("should return have op `#` as third token") {
                    expect(tokens[2]).to(equal(.op(.notEqual)))
                }
                it("should return have `goto` as fifth token") {
                    expect(tokens[4]).to(equal(.goto))
                }
                it("should return have `label` as sixth token") {
                    expect(tokens[5]).to(equal(.label("MOVE")))
                }
            }
            
            describe("IF DAMAGE = D GOTO MOVE") {
                let tokens: [Token] = Lexer(withString: "IF DAMAGE = D GOTO MOVE").lex()
                it("should return have op `=` as third token") {
                    expect(tokens[2]).to(equal(.op(.equal)))
                }
            }

            describe("IF DAMAGE > D GOTO MOVE") {
                let tokens: [Token] = Lexer(withString: "IF DAMAGE > D GOTO MOVE").lex()
                it("should return have op `>` as third token") {
                    expect(tokens[2]).to(equal(.op(.greaterThan)))
                }
            }

            describe("IF DAMAGE < D GOTO MOVE") {
                let tokens: [Token] = Lexer(withString: "IF DAMAGE < D GOTO MOVE").lex()
                it("should return have op `<` as third token") {
                    expect(tokens[2]).to(equal(.op(.lessThan)))
                }
            }

            describe("GOSUB MOVE") {
                let tokens: [Token] = Lexer(withString: "GOSUB MOVE").lex()
                it("should return two tokens") {
                    expect(tokens).to(haveCount(2))
                }
                it("should return have `gosub` as first token") {
                    expect(tokens[0]).to(equal(.gosub))
                }
                it("should return have `label` as second token") {
                    expect(tokens[1]).to(equal(.label("MOVE")))
                }
            }
            
            describe("ENDSUB") {
                let tokens: [Token] = Lexer(withString: "ENDSUB").lex()
                it("should return one token") {
                    expect(tokens).to(haveCount(1))
                }
                it("should return have `endsub` as first token") {
                    expect(tokens[0]).to(equal(.endsub))
                }
            }

            describe("DAMAGE TO D ;SAVE CURRENT DAMAGE") {
                let tokens: [Token] = Lexer(withString: "DAMAGE TO D;SAVE CURRENT DAMAGE").lex()
                it("should return one token") {
                    expect(tokens).to(haveCount(4))
                }
                it("should return have a `comment` as last token") {
                    expect(tokens.last!).to(equal(.comment("SAVE CURRENT DAMAGE")))
                }
            }
        }
    }
}
