//
//  Example.swift
//
//
//  Created by Tan Ngo Dang on 20/9/25.
//

import Foundation

public protocol Copying {
    init(_ prototype: Self)
}

extension Copying {
    public func copy() -> Self {
        return type(of: self).init(self)
    }
}

// 1
public class Monster: Copying {
    public var health: Int
    public var level: Int
    public init(health: Int, level: Int) {
        self.health = health
        self.level = level
    }
    
    // 2
    public required convenience init(_ monster: Monster) {
        self.init(health: monster.health, level: monster.level)
    }
}

public class EyeballMonster: Monster {
    public var redness = 0
    // 2
    public init(health: Int, level: Int, redness: Int) {
        self.redness = redness
        super.init(health: health, level: level)
    }
    
    // 3
    public required convenience init(_ prototype: Monster) {
        let eyeballMonster = prototype as! EyeballMonster
        self.init(health: eyeballMonster.health,
                  level: eyeballMonster.level,
                  redness: eyeballMonster.redness)
    }
}


