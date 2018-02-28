//
//  Matchers.swift
//  TinyRobotWars
//
//  Created by Manuele Mion on 21/02/2017.
//  Copyright © 2017 manumax. All rights reserved.
//

import Nimble

@testable import TinyRobotWars

private func tokensAreEqual(_ token1: Token, _ token2: Token) -> Bool {
    switch (token1, token2) {
    case (let .register(lRegister), let .register(rRegister)):
        return lRegister == rRegister
    case (let .number(lNumber), let .number(rNumber)):
        return lNumber == rNumber
    case (let .op(lop), let .op(rop)):
        return lop == rop
    case (let .label(llabel), let .label(rlabel)):
        return llabel == rlabel
    case (let .comment(lcomment), let .comment(rcomment)):
        return lcomment == rcomment
    case (.to, .to):
        return true
//    case (.if, .if): fallthrough
//    case (.gosub, .gosub): fallthrough
//    case (.endsub, .endsub): fallthrough
//    case (.goto, .goto):
//        return true
    default:
        return false
    }
}

public func equal(_ expectedToken: Token) -> Predicate<Token> {
    return MatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "equal \(expectedToken)"
        let actualToken = try! actualExpression.evaluate()
        let expected = expectedToken
        if let actual = actualToken {
            return tokensAreEqual(actual, expected)
        }
        return false
    }.predicate
}
