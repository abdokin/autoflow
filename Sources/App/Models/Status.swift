import Fluent
import struct Foundation.UUID

final class Status: Model,  @unchecked Sendable, Codable {
       static let schema = "statuses"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Siblings(through: WorkflowStatus.self, from: \.$status, to: \.$workflow)
    var workflows: [Workflow]
    
    init() { }
    
    init(id: UUID? = nil, name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
}