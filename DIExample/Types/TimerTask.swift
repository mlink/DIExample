//
//  TimerTask.swift
//  DIExample
//
//  Created by Michael Link on 3/26/25.
//

struct TimerTask: Sendable {
    let task: Task<Void, Never>

    @discardableResult
    init<C>(priority: TaskPriority? = nil, interval duration: C.Instant.Duration, tolerance: C.Instant.Duration? = nil, clock: C = ContinuousClock(), @_inheritActorContext @_implicitSelfCapture operation: sending @escaping @isolated(any) () async -> Void) where C : Clock {
        task = Task(priority: priority) {
            do {
                try await Task.sleep(for: duration, tolerance: tolerance, clock: clock)
                await operation()
            } catch {
                // return
            }
        }
    }

    private init<C>(priority: TaskPriority? = nil, interval duration: C.Instant.Duration, tolerance: C.Instant.Duration? = nil, clock: C = ContinuousClock(), repeats: Bool, @_inheritActorContext operation: sending @escaping @isolated(any) () async -> Void) where C : Clock {
        task = Task(priority: priority) {
            do {
                repeat {
                    try await Task.sleep(for: duration, tolerance: tolerance, clock: clock)
                    await operation()
                } while repeats
            } catch {
                // return
            }
        }
    }

    @inlinable static func repeating<C>(priority: TaskPriority? = nil, interval duration: C.Instant.Duration, tolerance: C.Instant.Duration? = nil, clock: C = ContinuousClock(), @_inheritActorContext operation: sending @escaping @isolated(any) () async -> Void) -> Self where C : Clock {
        Self.init(priority: priority, interval: duration, tolerance: tolerance, clock: clock, repeats: true, operation: operation)
    }

    func cancel() {
        task.cancel()
    }
}
