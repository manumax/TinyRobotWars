//: Playground - noun: a place where people can play

import UIKit

enum Node: CustomStringConvertible, Equatable {
    case number(Int)
    case register(String)
    indirect case container(Node, Node)
    
    var description: String {
        switch self {
        case .number(let value): return "\(value)"
        case .register(let name): return name
        case .container(let l, let r): return "\(l), \(r)"
        }
    }
    
    static func ==(lhs: Node, rhs: Node) -> Bool {
        switch (lhs, rhs) {
        case let (.number(l), .number(r)): return l == r
        case let (.register(l), .register(r)): return l == r
        case let (.container(l), .container(r)): return l == r
        default: return false
        }
    }
}

//struct AnyNode: Equatable {
//    let node: Any
//    let nodeAccept: (NodeVistor) -> Void
//
//    init<N>(_ node: N) where N: Node {
//        self.node = node
//        self.nodeAccept = node.accept
//    }
//
//    func accept(visitor: NodeVistor) {
//        return nodeAccept(visitor)
//    }
//
//    static func ==(lhs: AnyNode, rhs: AnyNode) -> Bool {
//
//
//        if let lnode = lhs.node as? Number, let rnode = rhs.node as? Number {
//            return lnode == rnode
//        }
//        if let lnode = lhs.node as? Register, let rnode = rhs.node as? Register {
//            return lnode == rnode
//        }
//        if let lnode = lhs.node as? Container, let rnode = rhs.node as? Container {
//            return lnode == rnode
//        }
//        return false
//    }
//}

protocol Visitor {
    func visit(_ node: Node)
}

class MyVisitor: Visitor {
    var stack: [Int] = []
    
    func visit(_ node: Node) {
        switch node {
        case .number(let value):
            stack.append(value)
        case .register(let name):
            stack.append(name.count)
        case .container(let l, let r):
            self.visit(l)
            self.visit(r)
            let first = stack.removeLast()
            let second = stack.removeLast()
            stack.append(first + second)
        }
    }
}

let n = Node.number(1)
let r = Node.register("X")
let r2 = Node.register("Y")
let r3 = Node.register("Y")

let c = Node.container(n, r)
let d = Node.container(r, c)

let v = MyVisitor()
v.visit(d)
print("\(v.stack)")



