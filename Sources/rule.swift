protocol Rule {
    func validate(from: Status, to: Status) -> Bool
}
struct NoSelfTransitionRule: Rule {
    func validate(from: Status, to: Status) -> Bool {
        from.name != to.name
    }
}


