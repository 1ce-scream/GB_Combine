//
//  TimeLogger.swift
//  SlotsMachine
//
//  Created by Vitaliy Talalay on 24.06.2022.
//

import Foundation

class TimeLogger: TextOutputStream {
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    private var now: String {
        formatter.string(from: Date.now) + " "
    }
    
    func write(_ string: String) {
        print("Logger: ", now,  string)
    }
}
