
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