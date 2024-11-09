protocol Trigger {
    func beforeTransition(from: Status, to: Status)
    func afterTransition(from: Status, to: Status)
}

class LoggingTrigger: Trigger {
    func beforeTransition(from: Status, to: Status) {
        print("About to transition from \(from.name) to \(to.name)")
    }

    func afterTransition(from: Status, to: Status) {
        print("Completed transition from \(from.name) to \(to.name)")
    }
}

class NotificationTrigger: Trigger {
    func beforeTransition(from: Status, to: Status) {
        print("Notifying: Starting \(from.name) -> \(to.name)")
    }

    func afterTransition(from: Status, to: Status) {
        print("Notifying: Completed \(from.name) -> \(to.name)")
    }
}

class CustomTrigger: Trigger {
    func beforeTransition(from: Status, to: Status) {
        print("Custom trigger: Starting \(from.name) -> \(to.name)")
    }

    func afterTransition(from: Status, to: Status) {
        print("Custom trigger: Completed \(from.name) -> \(to.name)")
    }
}