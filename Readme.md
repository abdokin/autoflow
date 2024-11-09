# AutoFlow

AutoFlow is a simple representation of a custom workflow system in Swift.

## Features

- Easy to use and integrate
- Customizable workflow,Triggers, Transitions, States, rules
- Lightweight and efficient

## Example

Here's a basic example of AutoFlow:

```swift

let draft = Status(name: "Draft")
let review = Status(name: "Review")
let published = Status(name: "Published")

let workflow = Workflow()

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

```

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss what you would like to change.

## License

AutoFlow is available under the MIT license. See the LICENSE file for more info.