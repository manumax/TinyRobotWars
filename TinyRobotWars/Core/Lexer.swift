//
// Created by Manuele Mion on 17/05/15.
// Copyright (c) 2015 manumax. All rights reserved.
//

import Foundation

enum Token {
    case register(String)
    case number(Int)
    case op(Operator)
//    case to, `if`, goto, gosub, endsub
    case to
    case label(String)
    case comment(String)
}

enum Operator: String {
    case plus = "+"
    case minus = "-"
    case times = "*"
    case divide = "/"
//    case equal = "="
//    case notEqual = "#"
//    case greaterThan = ">"
//    case lessThan = "<"
}

let registers = ["AIM", "SHOT", "RADAR", "DAMAGE", "SPEEDX", "SPEEDY", "RANDOM", "INDEX"]

let singleCharToTokenMap: [Character: Token] = [
    "+": .op(.plus),
    "-": .op(.minus),
    "*": .op(.times),
    "/": .op(.divide),
//    "=": .op(.equal),
//    "#": .op(.notEqual),
//    ">": .op(.greaterThan),
//    "<": .op(.lessThan),
]

extension Character {
    var value: Int32 {
        return Int32(String(self).unicodeScalars.first!.value)
    }
    var isSpace: Bool {
        return isspace(self.value) != 0
    }
    var isAlphanumeric: Bool {
        return isalnum(self.value) != 0
    }
    var isEOL: Bool {
        return self.value == Int32("\n")
    }
}

class Lexer: IteratorProtocol {
    typealias Element = Token
    
    let input: String
    var index: String.Index
    var currentChar: Character? {
        return self.index < self.input.endIndex ? input[index] : nil
    }
    
    init(withString input: String) {
        self.input = input
        self.index = input.startIndex
    }
    
    func nextChar() {
        input.characters.formIndex(after: &index)
    }
    
    func skipSpaces() {
        while let char = self.currentChar, char.isSpace {
            nextChar()
        }
    }
    
    func readComment() -> String {
        var str = ""
        while let char = currentChar, !char.isEOL {
            str.characters.append(char)
            self.nextChar()
        }
        return str
    }
    
    func readIdentifierOrNumber() -> String {
        var str = ""
        while let char = currentChar, char.isAlphanumeric {
            str.characters.append(char)
            self.nextChar()
        }
        return str
    }
    
    func next() -> Token? {
        self.skipSpaces()
        
        guard let char = self.currentChar else {
            return nil;
        }
        
        if char == ";" {
            nextChar()
            let str = self.readComment()
            return .comment(str)
        }
        
        if let token = singleCharToTokenMap[char] {
            nextChar()
            return token
        }
        
        if char.isAlphanumeric {
            let str = self.readIdentifierOrNumber()
            
            // Number
            if let number = Int(str) {
                return .number(number)
            }
            
            // Identifier
            switch str {
            case "TO":
                return .to
//            case "IF":
//                return .if
//            case "GOTO":
//                return .goto
//            case "GOSUB":
//                return .gosub
//            case "ENDSUB":
//                return .endsub
            case "A"..."Z" where str.characters.count == 1: fallthrough
            case _ where registers.contains(str):
                return .register(str)
            default:
                return .label(str)
            }
        }
        
        return nil
    }
    
    func lex() -> [Token] {
        var tokens = [Token]()
        while let token = self.next() {
            tokens.append(token)
        }
        return tokens
    }
}
