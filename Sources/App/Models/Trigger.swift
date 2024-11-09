import Fluent
import struct Foundation.UUID

protocol Triggerable {
    func beforeTransition(from: Status, to: Status)
    func afterTransition(from: Status, to: Status)
}

final class Trigger: Model, @unchecked Sendable, Triggerable {
    static let schema = "triggers"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "type")
    var type: String
    
    @Field(key: "condition")
    var condition: String
    
    @Parent(key: "transition_id")
    var transition: Transition

    @OptionalParent(key: "workflow_id")
    var workflow: Workflow?
    
    init() { }
    
    init(id: UUID? = nil, name: String, type: String, condition: String, transitionId: UUID) {
        self.id = id
        self.name = name
        self.type = type
        self.condition = condition
        self.$transition.id = transitionId
    }

    func beforeTransition(from: Status, to: Status) {
        print("Trigger \(name): Starting \(from.name) -> \(to.name)")
    }

    func afterTransition(from: Status, to: Status) {
        print("Trigger \(name): Completed \(from.name) -> \(to.name)")
    }
}