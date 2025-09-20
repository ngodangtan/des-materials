//
//  HomeTheaterSystem.swift
//  
//
//  Created by Tan Ngo Dang on 20/9/25.
//

// Subsystems
class TV {
    func on() { print("TV On") }
    func setInputHDMI() { print("HDMI Input selected") }
}

class Speaker {
    func on() { print("Speaker On") }
    func setVolume(_ level: Int) { print("Volume set to \(level)") }
}

class Projector {
    func down() { print("Projector screen down") }
}

class Light {
    func off() { print("Lights Off") }
}

// Facade
class HomeTheaterFacade {
    private let tv = TV()
    private let speaker = Speaker()
    private let projector = Projector()
    private let light = Light()
    
    func watchMovie() {
        print("Get ready to watch a movie...")
        tv.on()
        tv.setInputHDMI()
        speaker.on()
        speaker.setVolume(10)
        projector.down()
        light.off()
    }
}

// Client
//let theater = HomeTheaterFacade()
//theater.watchMovie()
