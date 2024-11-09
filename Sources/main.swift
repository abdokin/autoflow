// Usage example:
let draft = Status(name: "Draft")
let review = Status(name: "Review")
let published = Status(name: "Published")

let workflow = Workflow()

// Add global triggers that will run for all transitions
// workflow.addGlobalTrigger(LoggingTrigger())
workflow.addGlobalTrigger(NotificationTrigger())

// Add transitions with specific triggers
let draftToReview = Transition(
    from: draft,
    to: review,
    rules: [NoSelfTransitionRule()],
    triggers: [CustomTrigger()]
)

workflow.addTransition(draftToReview)
workflow.addTransition(Transition(from: review, to: published))

let _ = workflow.executeTransition(from: draft, to: review)
let _ = workflow.executeTransition(from: review, to: review)
