class Transition {
    let from: Status
    let to: Status
    var rules: [Rule]
    var triggers: [Trigger]

    init(
        from: Status, to: Status, rules: [Rule] = [NoSelfTransitionRule()],
        triggers: [Trigger] = [LoggingTrigger(), NotificationTrigger()]
    ) {
        self.from = from
        self.to = to
        self.rules = rules
        self.triggers = triggers
    }

    func isValid() -> Bool {
        rules.allSatisfy { $0.validate(from: from, to: to) }
    }

    func validate() -> Bool {
        let valid = isValid()
        if !valid {
            print("Invalid transition from \(from.name) to \(to.name)")
        }
        return valid
    }

    func execute() {
        print("Executing transition from \(from.name) to \(to.name)")
        triggers.forEach { $0.beforeTransition(from: from, to: to) }
    }
}