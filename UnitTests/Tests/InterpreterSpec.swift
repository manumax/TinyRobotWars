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
            describe("1 + 2 * 4") {
                let lexer = Lexer(withString: "1 + 2 * 4")
                let parser = Parser(withLexer: lexer)
                let node: Node = try! parser.parse()
                let interpreter: Interpreter = Interpreter()
                it("should return 9") {
                    interpreter.visit(node)
                    if let result = interpreter.stack.first {
                        expect(result).to(equal(9))
                    } else {
                        fail()
                    }
                }
            }
            describe("2 * -7") {
                let lexer = Lexer(withString: "2 * -7")
                let parser = Parser(withLexer: lexer)
                let node: Node = try! parser.parse()
                let interpreter: Interpreter = Interpreter()
                it("should return 9") {
                    interpreter.visit(node)
                    if let result = interpreter.stack.first {
                        expect(result).to(equal(-14))
                    } else {
                        fail()
                    }
                }
            }
            describe("1 * 3 TO A") {
                let lexer = Lexer(withString: "1 * 3 TO A")
                let parser = Parser(withLexer: lexer)
                let node: Node = try! parser.parse()
                let interpreter: Interpreter = Interpreter()
                it("should set register `A` to value 3") {
                    interpreter.visit(node)
                    expect(interpreter.registers["A"]).to(equal(3))
                }
            }
        }
    }
}
