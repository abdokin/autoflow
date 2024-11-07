class Status {
    let name: String

    init(name: String) {
        self.name = name
    }
}

protocol Trigger {
    func beforeTransition(from: Status, to: Status)
    func afterTransition(from: Status, to: Status)
}

protocol Rule {
    func validate(from: Status, to: Status) -> Bool
}

// Example rule implementations
struct NoSelfTransitionRule: Rule {
    func validate(from: Status, to: Status) -> Bool {
        from.name != to.name
    }
}

// Example triggers
class LoggingTrigger: Trigger {
    func beforeTransition(from: Status, to: Status) {
        print("About to transition from \(from.name) to \(to.name)")
    }

    func afterTransition(from: Status, to: Status) {
        print("Completed transition from \(from.name) to \(to.name)")
    }
}

// Example triggers
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
        triggers.forEach { $0.beforeTransition(from: from, to: to) }

        print("Executing transition from \(from.name) to \(to.name)")

        // Execute after triggers
        triggers.forEach { $0.afterTransition(from: from, to: to) }
    }
}

class Workflow {
    private var transitions: [Transition] = []
    private(set) var currentStatus: Status?
    var globalTriggers: [Trigger] = []


    func addTransition(_ transition: Transition) {
        transitions.append(transition)
    }

   func addGlobalTrigger(_ trigger: Trigger) {
        globalTriggers.append(trigger)
    }
    
    func canTransition(from: Status, to: Status) -> Bool {
        transitions.contains { t in
            t.from.name == from.name && t.to.name == to.name
        }
    }

    func executeTransition(from: Status, to: Status) -> Bool {
        guard canTransition(from: from, to: to) else {
            print("No valid transition defined from \(from.name) to \(to.name)")
            return false
        }
        
        // Create transition with both local and global triggers
        let transition = Transition(
            from: from, 
            to: to,
            triggers: globalTriggers
        )
        
        guard transition.validate() else {
            return false
        }
        
        transition.execute()
        currentStatus = to
        return true
    }
}

// Usage example:
let draft = Status(name: "Draft")
let review = Status(name: "Review")
let published = Status(name: "Published")

let workflow = Workflow()

// Add global triggers that will run for all transitions
workflow.addGlobalTrigger(LoggingTrigger())
workflow.addGlobalTrigger(NotificationTrigger())

// Add transitions with specific triggers
let draftToReview = Transition(
    from: draft,
    to: review,
    triggers: [CustomTrigger()]
)

workflow.addTransition(draftToReview)
workflow.addTransition(Transition(from: review, to: published))

// Execute and see triggers in action
let _ = workflow.executeTransition(from: draft, to: review)
let _ = workflow.executeTransition(from: review, to: review)
