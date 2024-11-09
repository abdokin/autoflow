import Fluent
import struct Foundation.UUID
protocol RuleAble {
    func validate(from: Status, to: Status) -> Bool
}

final class TransitionRule: Model, @unchecked Sendable, RuleAble {
    static let schema = "rules"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "condition")
    var condition: String
    
    @Field(key: "action")
    var action: String
    
    @Parent(key: "transition_id")
    var transition: Transition
    
    init() { }
    
    init(id: UUID? = nil, name: String, condition: String, action: String, transitionId: UUID) {
        self.id = id
        self.name = name
        self.condition = condition
        self.action = action
        self.$transition.id = transitionId
    }

    func validate(from: Status, to: Status) -> Bool {
        // TODO: Implement rule validation
        return true
    }
}