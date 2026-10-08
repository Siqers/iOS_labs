// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Author: Erdaulet Toktagul


// MARK: Level 1 · Decoding Telemetry

// Helper: prints an optional reading as "(sensor: ..., value: ...)" or "nil"
// instead of "Optional((sensor: ..., value: ...))".
func describe(_ reading: Reading?) -> String {
    guard let reading = reading else { return "nil" }
    return "(sensor: \"\(reading.sensor)\", value: \(reading.value))"
}

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let (sensor, valueText) = splitOnce(raw, by: ":"),
          sensor.isEmpty == false,
          let value = Int(valueText),
          value >= 0 || sensor == "TEMP"
    else { return nil }
    return (sensor: sensor, value: value)
}

print("\n--- 1.1 parseReading ---")
print("O2:87    ->", describe(parseReading("O2:87")))     // (sensor: "O2", value: 87)
print("TEMP:-12 ->", describe(parseReading("TEMP:-12")))  // (sensor: "TEMP", value: -12)
print("RAD:-1   ->", describe(parseReading("RAD:-1")))    // nil
print(":55      ->", describe(parseReading(":55")))       // nil
print("O2:9x    ->", describe(parseReading("O2:9x")))     // nil
print("hello    ->", describe(parseReading("hello")))     // nil

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid: valid, invalidCount: invalidCount)
}

print("\n--- 1.2 parseLog ---")
let telemetry = parseLog(rawLog)
print("rawLog: \(telemetry.valid.count) valid, \(telemetry.invalidCount) corrupted")       // 10 valid, 6 corrupted
let smallLog = parseLog(["O2:50", "broken", "TEMP:-5", "RAD:"])
print("small log: \(smallLog.valid.count) valid, \(smallLog.invalidCount) corrupted")     // 2 valid, 2 corrupted

let A = telemetry.invalidCount
print("Code fragment A =", A)


// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

print("\n--- 2.1 select / values ---")
let o2Readings = select(telemetry.valid) { $0.sensor == "O2" }
print("O2 values:", values(of: o2Readings))                  // [87, 64, 71, 90]
let highReadings = select(telemetry.valid) { $0.value > 90 }
print("Values above 90:", values(of: highReadings))          // [101, 98]

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var minValue = first
    var maxValue = first
    var sum = 0
    for value in values {
        if value < minValue { minValue = value }
        if value > maxValue { maxValue = value }
        sum += value
    }
    return (min: minValue, max: maxValue, average: Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

// Helper: prints optional stats without the "Optional(...)" wrapper.
func describe(_ result: (min: Int, max: Int, average: Double)?) -> String {
    guard let result = result else { return "nil" }
    return "(min: \(result.min), max: \(result.max), average: \(result.average))"
}

print("\n--- 2.2 stats ---")
print("stats(3, 8, 1)  ->", describe(stats(3, 8, 1)))                     // (min: 1, max: 8, average: 4.0)
print("stats()         ->", describe(stats()))                            // nil
print("stats(of: [])   ->", describe(stats(of: [])))                      // nil
print("stats(of: O2)   ->", describe(stats(of: values(of: o2Readings))))  // (min: 64, max: 90, average: 78.0)

let B = Int(stats(of: values(of: o2Readings))?.average ?? 0)
print("Code fragment B =", B)

// 2.3 · The Closure Ladder (5 sorts, then compare results in code)
print("\n--- 2.3 Closure Ladder ---")
let readings = telemetry.valid

// 1. Full syntax: parameter types, return type and `return`
let sorted1 = readings.sorted(by: { (first: Reading, second: Reading) -> Bool in
    return first.value > second.value
})
// 2. Types inferred from context
let sorted2 = readings.sorted(by: { first, second in return first.value > second.value })
// 3. Implicit return (single-expression closure)
let sorted3 = readings.sorted(by: { first, second in first.value > second.value })
// 4. Shorthand argument names
let sorted4 = readings.sorted(by: { $0.value > $1.value })
// 5. Trailing closure
let sorted5 = readings.sorted { $0.value > $1.value }

// Tuples are not Equatable, so [Reading] can't be compared with ==.
// This helper compares two arrays of readings element by element.
func sameReadings(_ lhs: [Reading], _ rhs: [Reading]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for index in 0..<lhs.count {
        guard lhs[index].sensor == rhs[index].sensor,
              lhs[index].value == rhs[index].value
        else { return false }
    }
    return true
}

let allSortsMatch = sameReadings(sorted1, sorted2)
    && sameReadings(sorted1, sorted3)
    && sameReadings(sorted1, sorted4)
    && sameReadings(sorted1, sorted5)
print("Sorted values:", values(of: sorted1))                       // [101, 98, 90, 87, 71, 64, 31, 4, 3, -12]
print("All five sorts match:", allSortsMatch)                      // true
print("Sanity check, sorted vs unsorted:", sameReadings(sorted1, readings))  // false


// MARK: Level 3 · Temperature Stabilization

let safeTemperature = 18...24

// 3.1
func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < safeTemperature.lowerBound { return heatUp }
    if temp > safeTemperature.upperBound { return coolDown }
    return hold
}

print("\n--- 3.1 Protocols ---")
print("heatUp(10) =", heatUp(10), "| heatUp(-12) =", heatUp(-12))          // 15 | -7
print("coolDown(30) =", coolDown(30), "| coolDown(25) =", coolDown(25))    // 27 | 22
print("hold(20) =", hold(20), "| hold(18) =", hold(18))                    // 20 | 18
let coldAction = chooseProtocol(for: 10)
print("chooseProtocol(for: 10) applied to 10 =", coldAction(10))           // 15 (heatUp)
print("chooseProtocol(for: 30) applied to 30 =", chooseProtocol(for: 30)(30))  // 27 (coolDown)
print("chooseProtocol(for: 21) applied to 21 =", chooseProtocol(for: 21)(21))  // 21 (hold)

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    while safeTemperature.contains(temp) == false && steps < maxSteps {
        let action = chooseProtocol(for: temp)
        temp = action(temp)
        steps += 1
    }
    return (finalTemp: temp, steps: steps, isStable: safeTemperature.contains(temp))
}

print("\n--- 3.2 runUntilStable ---")
print("from 31:", runUntilStable(from: 31))                          // (finalTemp: 22, steps: 3, isStable: true)
print("from -100, max 5:", runUntilStable(from: -100, maxSteps: 5))  // (finalTemp: -75, steps: 5, isStable: false)
print("from 20:", runUntilStable(from: 20))                          // (finalTemp: 20, steps: 0, isStable: true)

let temperatureReadings = select(telemetry.valid) { $0.sensor == "TEMP" }
let lowestTemperature = stats(of: values(of: temperatureReadings))?.min ?? 0
print("Lowest valid temperature:", lowestTemperature)                // -12
print("Stabilizing it:", runUntilStable(from: lowestTemperature))

let C = runUntilStable(from: lowestTemperature).steps
print("Code fragment C =", C)


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

print("\n--- 4.1 oxygenLevel ---")
for member in crew {
    print("\(member.name):", String(describing: oxygenLevel(of: member)))
}

// 4.2
let criticalOxygenLevel = 20

func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let location = member.module?.name ?? "open space"
        return "\(member.name): no data (\(location))"
    }
    let state = level < criticalOxygenLevel ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(state)"
}

print("\n--- 4.2 status (whole crew) ---")
for member in crew {
    print(status(of: member))
}

// 4.3
let tankCapacity = 100

@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    let freeSpace = tankCapacity - target
    let transferred = max(0, min(amount, source, freeSpace))
    source -= transferred
    target += transferred
    return transferred
}

print("\n--- 4.3 transferOxygen ---")
var testSource = 50
var testTarget = 90
let moved1 = transferOxygen(from: &testSource, to: &testTarget, amount: 30)
print("50 -> 90, amount 30: moved \(moved1), now \(testSource) and \(testTarget)")  // moved 10, now 40 and 100

var smallSource = 5
var emptyTarget = 0
let moved2 = transferOxygen(from: &smallSource, to: &emptyTarget, amount: 20)
print("5 -> 0, amount 20: moved \(moved2), now \(smallSource) and \(emptyTarget)")  // moved 5, now 0 and 5

let moved3 = transferOxygen(from: &testSource, to: &emptyTarget, amount: -10)
print("negative amount: moved \(moved3), now \(testSource) and \(emptyTarget)")     // moved 0, now 40 and 5

// The real transfer: Lab -> Hab. Both tanks are optional, so unwrap them first.
if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    let moved = transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    print("Station: moved \(moved) units Lab -> Hab. Lab = \(labTank.level), Hab = \(habTank.level)")
} else {
    print("Station: transfer impossible, a tank is missing")
}

let D = hab.oxygenTank?.level ?? 0
print("Code fragment D =", D)

print("Crew status after transfer:")
for member in crew {
    print("  " + status(of: member))
}

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    found.sort { $0.priority < $1.priority }

    var order: [String] = []
    for member in found {
        order.append(member.name)
    }
    return order
}

print("\n--- 4.4 evacuationOrder ---")
print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))   // ["Aigerim", "Timur", "Dana"]
print(evacuationOrder("Timur", "Nurlan", "Dana", "Aigerim", roster: roster))  // ["Aigerim", "Nurlan", "Timur", "Dana"]
print(evacuationOrder("Ghost", "Alien", roster: roster))                      // []


// MARK: Level 5 · The Saboteur's Logbook
// The saboteur's original code, kept commented out, with every problem marked.

/*
func reportOxygen(for member: CrewMember) -> String {
    let tank = member.module!.oxygenTank!
    // PROBLEM 1: member.module!
    //   Breaks on: Nurlan (module == nil, he is in open space).
    //   What happens: "Unexpectedly found nil while unwrapping an Optional value",
    //   the whole program crashes, not just this report.
    // PROBLEM 2: .oxygenTank!
    //   Breaks on: Dana (she is in Dock, and Dock has no tank).
    //   What happens: the same crash. oxygenTank is a var, so any module
    //   could lose its tank later and crash a report that worked before.
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        if oxygenLevel(of: member)! < 20 {
            // PROBLEM 3: oxygenLevel(of: member)!
            //   Breaks on: any member with no data (Dana, Nurlan).
            //   What happens: crash. With the starter crew Dana is 2nd in the
            //   array, so it crashes before it ever reaches Aigerim (the one in danger).
            result = member.name
            // PROBLEM 4 (logic bug, no ! involved):
            //   The loop never stops after a match, so every later critical
            //   member overwrites result. It returns the LAST critical member,
            //   not the FIRST. Breaks on: 2+ critical members. With the starter
            //   data only Aigerim is critical, so the bug stays invisible.
        }
    }
    return result!
    // PROBLEM 5: return result!
    //   Breaks on: nobody is critical, or the crew array is empty.
    //   What happens: result is nil, so it crashes. The return type String can't
    //   say "nobody", so it has to be String?.
    // PROBLEM 6: the magic number 20 is duplicated here instead of using one
    //   shared constant, so if the threshold changes in status(of:) the two can disagree.
}
*/

// Fixed versions (no force unwraps):
func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        guard let level = oxygenLevel(of: member) else { continue }  // no data is not "critical"
        if level < criticalOxygenLevel {
            return member.name  // stop at the FIRST match
        }
    }
    return nil  // nobody is critical
}

print("\n--- 5 Saboteur's Logbook (fixed) ---")
for member in crew {
    print(reportOxygen(for: member))  // Dana and Nurlan no longer crash
}
print("firstCritical(in: crew) =", firstCritical(in: crew) ?? "nobody")

// Test that PROVES the logic bug is fixed: two critical members.
// The saboteur's loop would overwrite result and return the LAST one ("Bekzat").
// The correct answer is the FIRST one ("Aliya").
let logicTestCrew = [
    CrewMember(name: "Aliya",  role: "Test", priority: 1, module: Module(name: "T1", oxygenTank: Tank(level: 5))),
    CrewMember(name: "Arman",  role: "Test", priority: 2, module: Module(name: "T2", oxygenTank: Tank(level: 80))),
    CrewMember(name: "Bekzat", role: "Test", priority: 3, module: Module(name: "T3", oxygenTank: Tank(level: 15)))
]
let firstFound = firstCritical(in: logicTestCrew)
print("Logic test: got \(firstFound ?? "nil"), expected Aliya ->", firstFound == "Aliya" ? "PASS" : "FAIL")

// Test for problems 3 and 5: members without data and nobody critical.
// The saboteur's version would crash here.
let safeTestCrew = [
    CrewMember(name: "NoModule", role: "Test", priority: 1, module: nil),
    CrewMember(name: "NoTank",   role: "Test", priority: 2, module: Module(name: "T4", oxygenTank: nil)),
    CrewMember(name: "Healthy",  role: "Test", priority: 3, module: Module(name: "T5", oxygenTank: Tank(level: 70)))
]
let nobodyFound = firstCritical(in: safeTestCrew)
print("Nil test: got \(nobodyFound ?? "nil"), expected nil ->", nobodyFound == nil ? "PASS" : "FAIL")


// MARK: Finale · Launch Code

print("\n=============================")
let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")
print("=============================")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var fireCount = 0
    return { level in
        guard level < threshold else { return false }
        fireCount += 1
        print("Alarm #\(fireCount)")
        return true
    }
}

print("\n--- Bonus makeAlarm ---")
let alarm = makeAlarm(threshold: 20)
print(alarm(12))  // Alarm #1 → true
print(alarm(40))  // false
print(alarm(5))   // Alarm #2 → true

let strictAlarm = makeAlarm(threshold: 50)
print(strictAlarm(40))  // Alarm #1 → true (its own, separate counter)
print(alarm(1))         // Alarm #3 → true (the first alarm's counter is untouched)


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
    • With guard let, the unwrapped value lives AFTER the guard, for the rest of the
      function. With if let, it exists only inside the { } braces.
    • The else branch of a guard MUST leave the scope (return / continue / break / throw),
      and the compiler checks this. So you can't accidentally keep going with bad data.
    • guard means "early exit": check everything at the top, then write the happy path
      without nesting. if let means "do this only if the value exists".
    Example where if let is much worse: parseReading written with if let:

        if let (sensor, text) = splitOnce(raw, by: ":") {
            if sensor.isEmpty == false {
                if let value = Int(text) {
                    if value >= 0 || sensor == "TEMP" {
                        return (sensor, value)
                    }
                }
            }
        }
        return nil

    That's four levels of nesting (the "pyramid of doom"). The real result is buried in
    the middle, and every new rule adds another level. With guard it's one flat check
    and one return.

 2. Why can't you pass [Int] to stats(_ values: Int...)?
    For the caller, Int... is not [Int]. A variadic parameter means "pass any number of
    separate Int arguments": stats(3, 8, 1). The compiler packs them into an array only
    INSIDE the function. Swift has no "spread" operator to unpack an array into separate
    arguments, so stats(someArray) means "one argument of type [Int]" where an Int is
    expected, which is a type error. That's why stats(of:) takes [Int], and the variadic
    version just forwards to it.

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
    Swift's Law of Exclusivity: while a variable is passed as inout, the function gets
    exclusive write access to it. Passing the same x twice gives two overlapping write
    accesses to the same memory, so you get "overlapping accesses to 'x'".
    The bug it prevents: source and target would be the SAME tank. inout works like
    copy-in / copy-out:
        x = 50  ->  source = 50, target = 50
        source -= 5  ->  45      target += 5  ->  55
        both copies are written back to x  ->  x ends up as 45 OR 55
    Oxygen would appear or vanish out of nothing, depending on which write wins.

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
    ?? needs both sides to have the same type: (T?) ?? T gives T.
    oxygenLevel(of: dana) is Int?, so the default must be an Int, but "no data" is a
    String. Swift never mixes Int and String silently, so it's a type error.
    Fixes: unwrap with guard let / if let and build the text yourself (like status(of:)
    does), or give an Int default: oxygenLevel(of: dana) ?? 0. But 0 would lie and say
    the tank is empty when we really have no data.

 5. Full type of chooseProtocol and how to read it:
        (Int) -> (Int) -> Int
    The arrow groups from the right, so it means (Int) -> ((Int) -> Int):
    "a function that takes an Int (the current temperature) and returns ANOTHER function,
    which takes an Int and returns an Int". The label "for:" is not part of the type.
        let picker: (Int) -> (Int) -> Int = chooseProtocol
        let action = picker(10)       // action is heatUp, type (Int) -> Int
        action(10)                    // 15
        chooseProtocol(for: 30)(30)   // 27: two calls in a row

 Bonus. Where does the alarm counter live after makeAlarm returns?
    fireCount is a local variable of makeAlarm. Normally it would live on the stack and
    disappear when makeAlarm returns. But the returned closure uses it, so the closure
    CAPTURES it: Swift moves fireCount into a small box on the HEAP, and the closure keeps
    a reference to that box. The box lives as long as the closure (alarm) is alive.
    Every makeAlarm call creates a new box, so each alarm has its own counter.
    That's why strictAlarm starts again from #1 while alarm keeps counting.

*/
