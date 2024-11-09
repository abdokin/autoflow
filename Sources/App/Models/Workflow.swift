import Fluent
import struct Foundation.UUID

final class Workflow: Model,  @unchecked Sendable {
    static let schema = "workflows"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @OptionalParent(key: "current_status_id")
    var currentStatus: Status?

    @Siblings(through: WorkflowStatus.self, from: \.$workflow, to: \.$status)
    var statuses: [Status]

    @Children(for: \.$workflow)
    var transitions: [Transition]

    @Children(for: \.$workflow)
    var globalTriggers: [Trigger]

    init() { }

    init(id: UUID? = nil, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }

    func addTransition(_ transition: Transition) {
        transitions.append(transition)
    }

    func addGlobalTrigger(_ trigger: Trigger) {
        globalTriggers.append(trigger)
    }
    
    func addGlobalTriggers(_ triggers: [Trigger]) {
        globalTriggers.append(contentsOf: triggers)
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
            to: to
        )

        guard transition.validate() else {
            return false
        }

        transition.execute()
        currentStatus = to
        return true
    }
}