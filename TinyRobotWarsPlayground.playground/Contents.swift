//: Playground - noun: a place where people can play

import UIKit


let test = "YEAH"
switch test {
case "A"..."Z" where test.characters.count == 1:
    print ("FOUND!")
default:
    print ("NOT FOUND!")
}