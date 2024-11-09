import Fluent

struct CreateAllTables: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        // Create Statuses
        let statuses = database.schema("statuses")
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .create()
        
        // Create Workflows
        let workflows = database.schema("workflows")
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("current_status_id", .uuid, .references("statuses", "id"))
            .create()
        
        // Create Workflow-Status pivot
        let workflowStatus = database.schema("workflow_status")
            .id()
            .field("workflow_id", .uuid, .required, .references("workflows", "id", onDelete: .cascade))
            .field("status_id", .uuid, .required, .references("statuses", "id", onDelete: .cascade))
            .create()
        
        // Create Transitions
        let transitions = database.schema("transitions")
            .id()
            .field("name", .string, .required)
            .field("workflow_id", .uuid, .required, .references("workflows", "id", onDelete: .cascade))
            .field("status_from_id", .uuid, .required, .references("statuses", "id", onDelete: .cascade))
            .field("status_to_id", .uuid, .required, .references("statuses", "id", onDelete: .cascade))
            .create()
        
        // Create Triggers
        let triggers = database.schema("triggers")
            .id()
            .field("name", .string, .required)
            .field("type", .string, .required)
            .field("condition", .string, .required)
            .field("transition_id", .uuid, .required, .references("transitions", "id", onDelete: .cascade))
            .field("workflow_id", .uuid, .references("workflows", "id", onDelete: .cascade))
            .create()
        
        // Create Rules
        let rules = database.schema("rules")
            .id()
            .field("name", .string, .required)
            .field("condition", .string, .required)
            .field("action", .string, .required)
            .field("transition_id", .uuid, .required, .references("transitions", "id", onDelete: .cascade))
            .create()
        
        // Execute migrations in sequence
        return workflows
            .flatMap { statuses }
            .flatMap { workflowStatus }
            .flatMap { transitions }
            .flatMap { triggers }
            .flatMap { rules }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        // Drop tables in reverse order
        return database.schema("rules").delete()
            .flatMap { database.schema("triggers").delete() }
            .flatMap { database.schema("transitions").delete() }
            .flatMap { database.schema("workflow_status").delete() }
            .flatMap { database.schema("statuses").delete() }
            .flatMap { database.schema("workflows").delete() }
    }
}


// Optional: Seeder migration for initial data
struct SeedInitialData: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        // Create a basic workflow with some statuses
        let workflow = Workflow(name: "Document Approval", description: "Basic document approval workflow")
        let draft = Status(name: "Draft", description: "Initial state")
        let review = Status(name: "In Review", description: "Document is being reviewed")
        let approved = Status(name: "Approved", description: "Document has been approved")
        
        return workflow.save(on: database)
            .flatMap { 
                draft.save(on: database)
                    .and(review.save(on: database))
                    .and(approved.save(on: database))
            }
            .flatMap { _ in
                // Create workflow-status relationships
                let workflowStatus1 = try! WorkflowStatus(workflow: workflow, status: draft)
                let workflowStatus2 = try! WorkflowStatus(workflow: workflow, status: review)
                let workflowStatus3 = try! WorkflowStatus(workflow: workflow, status: approved)
                
                return workflowStatus1.save(on: database)
                    .and(workflowStatus2.save(on: database))
                    .and(workflowStatus3.save(on: database))
            }
            .flatMap { _ -> EventLoopFuture<Void> in
                // Create transitions
                guard let workflowId = workflow.id,
                      let draftId = draft.id,
                      let reviewId = review.id,
                      let approvedId = approved.id else {
                    return database.eventLoop.future()
                }
                
                let draftToReview = Transition(
                    name: "Submit for Review",
                    workflowId: workflowId,
                    statusFromId: draftId,
                    statusToId: reviewId
                )
                
                let reviewToApproved = Transition(
                    name: "Approve Document",
                    workflowId: workflowId,
                    statusFromId: reviewId,
                    statusToId: approvedId
                )
                
                return draftToReview.save(on: database)
                    .and(reviewToApproved.save(on: database))
                    .transform(to: ())
            }
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        // Clear seeded data if needed
        return database.eventLoop.future()
    }
}