import Fluent
import struct Foundation.UUID

final class WorkflowStatus: Model, @unchecked Sendable {
    static let schema = "workflow_status"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "workflow_id")
    var workflow: Workflow
    
    @Parent(key: "status_id")
    var status: Status
    
    init() { }
    
    init(id: UUID? = nil, workflow: Workflow, status: Status) throws {
        self.id = id
        self.$workflow.id = try workflow.requireID()
        self.$status.id = try status.requireID()
    }
}