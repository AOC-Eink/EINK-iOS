//
//  CommandSender.swift
//  eink
//
//  Created by Aaron on 2024/10/13.
//

import SwiftUI
import Combine

class TaskScheduler {
    private var timerCancellable: AnyCancellable?
    private var currentCount = 0
    private let interval: TimeInterval
    private let taskCount: Int
    private let task: () -> Void
    
    init(interval: TimeInterval, taskCount: Int, task: @escaping () -> Void) {
        self.interval = interval
        self.taskCount = taskCount
        self.task = task
    }
    
    func start() {
        currentCount = 0
        timerCancellable = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.currentCount < self.taskCount {
                    self.task()
                    self.currentCount += 1
                } else {
                    self.stop()
                }
            }
    }
    
    func stop() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}


