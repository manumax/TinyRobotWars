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

class InterpreterSpec: QuickSpec {
    override func spec() {
        describe("executing interpreter") {
            let interpreter: Interpreter = Interpreter()
            describe("1 + 2 * 4") {
                let lexer = Lexer(withString: "1 + 2 * 4")
                let parser = Parser(withLexer: lexer)
                let node: Node = try! parser.parse()
                it("should return 9") {
                    let result = interpreter.visit(node: node)
                    expect(result).to(equal(9))
                }
            }
            describe("2 * -7") {
                let lexer = Lexer(withString: "2 * -7")
                let parser = Parser(withLexer: lexer)
                let node: Node = try! parser.parse()
                it("should return 9") {
                    let result = interpreter.visit(node: node)
                    expect(result).to(equal(-14))
                }
            }
        }
    }
}
