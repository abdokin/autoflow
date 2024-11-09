import Fluent
import struct Foundation.UUID

final class Transition: Model,  @unchecked Sendable {
    static let schema = "transitions"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Parent(key: "workflow_id")
    var workflow: Workflow
    
    @Parent(key: "status_from_id")
    var from: Status
    
    @Parent(key: "status_to_id")
    var to: Status
    
    @Children(for: \.$transition)
    var triggers: [Trigger]
    
    @Children(for: \.$transition)
    var rules: [TransitionRule]
    
    init() { }
    
    init (
        //TODO:  NoSelfTransitionRule()
        from: Status, to: Status, rules: [TransitionRule] = [], triggers: [Trigger] = []
    ){
        self.$from.id = from.id!
        self.$to.id = to.id!
        self.rules = rules
    }
    init(id: UUID? = nil, name: String, workflowId: UUID, statusFromId: UUID, statusToId: UUID) {
        self.id = id
        self.name = name
        self.$workflow.id = workflowId
        self.$from.id = statusFromId
        self.$to.id = statusToId
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

        triggers.forEach { $0.afterTransition(from: from, to: to) }
    }
}