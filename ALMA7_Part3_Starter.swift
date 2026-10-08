// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Author: Erdaulet Toktagul


// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  -> A battery is one physical object that the drone and everyone else must share, so every holder has to see the same charge; with a struct each copy would have its own charge and the same energy could be spent twice.
final class PowerCell {
    static let capacity = 100

    private var charge: Int

    init(charge: Int) {
        self.charge = PowerCell.clamped(charge)
    }

    func level() -> Int {
        charge
    }

    func canSpend(_ amount: Int) -> Bool {
        amount > 0 && amount <= charge
    }

    func spend(_ amount: Int) -> Bool {
        guard canSpend(amount) else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        charge = PowerCell.rechargedLevel(from: charge, by: amount)
    }

    // The charging rules live here once and are reused by SensorModule too.
    static func clamped(_ value: Int) -> Int {
        min(capacity, max(0, value))
    }

    static func rechargedLevel(from current: Int, by amount: Int) -> Int {
        guard amount > 0 else { return current }
        return clamped(current + amount)
    }
}

print("\n--- 1 PowerCell ---")
let cell = PowerCell(charge: 40)
print("PowerCell(charge: 150) ->", PowerCell(charge: 150).level())   // 100
print("PowerCell(charge: -20) ->", PowerCell(charge: -20).level())   // 0
print("level:", cell.level())                                        // 40
print("spend(30):", cell.spend(30), "| level", cell.level())         // true | 10
print("spend(0):", cell.spend(0), "| level", cell.level())           // false | 10
print("spend(-5):", cell.spend(-5), "| level", cell.level())         // false | 10
print("spend(50):", cell.spend(50), "| level", cell.level())         // false | 10 (not enough)
cell.recharge(by: -10)
print("recharge(by: -10) -> level", cell.level())                    // 10 (ignored)
cell.recharge(by: 500)
print("recharge(by: 500) -> level", cell.level())                    // 100 (never above 100)

// Encapsulation proof (leave this commented, with the compiler error):
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  -> No subclass can override the ritual, so every drone, present or future, must pay its powerCost before it does any work: no free work and no negative charge.
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    var hasChargeForTask: Bool {
        cell.canSpend(powerCost)
    }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }

    override func performTask() -> Int { 40 }

    func weldSeam() -> String {
        "\(id) welds a hull seam"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }

    override func performTask() -> Int { 15 }

    override var statusLine: String {
        super.statusLine + " [scanner]"
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }

    override func performTask() -> Int { 25 }
}

print("\n--- 2.2 Drone types ---")
let sampleWelder = WelderDrone(id: "W-0", cell: PowerCell(charge: 100))
let sampleScanner = ScannerDrone(id: "S-0", cell: PowerCell(charge: 100))
let sampleCargo = CargoDrone(id: "C-0", cell: PowerCell(charge: 100))
print(sampleWelder.statusLine, "| cost", sampleWelder.powerCost, "| runOnce ->", sampleWelder.runOnce())   // cost 25, 40
print(sampleScanner.statusLine, "| cost", sampleScanner.powerCost, "| runOnce ->", sampleScanner.runOnce()) // cost 10, 15
print(sampleCargo.statusLine, "| cost", sampleCargo.powerCost, "| runOnce ->", sampleCargo.runOnce())       // cost 20, 25
print(sampleWelder.weldSeam())
print("after one run:", sampleWelder.statusLine, "/", sampleScanner.statusLine, "/", sampleCargo.statusLine)

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

func buildFleet(from records: [(kind: String, id: String, charge: Int)]) -> [Drone] {
    var drones: [Drone] = []
    for record in records {
        guard let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) else {
            print("Warning: unknown drone kind \"\(record.kind)\" for \(record.id), skipped")
            continue
        }
        drones.append(drone)
    }
    return drones
}

print("\n--- 2.3 Factory ---")
let fleet: [Drone] = buildFleet(from: fleetData)   // T-1 ("tug") is skipped with a warning
print("fleet size:", fleet.count)                  // 5
for drone in fleet {
    print(drone.statusLine)
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    guard rounds > 0 else { return 0 }
    var totalWork = 0
    for _ in 1...rounds {
        for drone in fleet {
            totalWork += drone.runOnce()  // one call, different behaviour per drone
        }
    }
    return totalWork
}

func totalCharge(of fleet: [Drone]) -> Int {
    var total = 0
    for drone in fleet {
        total += drone.cell.level()
    }
    return total
}

func readyCount(of fleet: [Drone]) -> Int {
    var count = 0
    for drone in fleet where drone.hasChargeForTask {
        count += 1
    }
    return count
}

print("\n--- 3 The Shift ---")
let shiftWork = runShift(fleet, rounds: 3)
print("work units from 3 rounds:", shiftWork)              // 285
print("after the shift:")
for drone in fleet {
    print("  " + drone.statusLine)
}
print("drones that can still run one more task:", readyCount(of: fleet))  // 3

let A = shiftWork
let B = totalCharge(of: fleet)
let C = readyCount(of: fleet)
print("Mission fragments: A =", A, "| B =", B, "| C =", C)  // 285 | 105 | 3

// A drone with too little charge produces nothing: no crash, no negative charge.
let tiredWelder = WelderDrone(id: "W-TIRED", cell: PowerCell(charge: 15))
print("tired welder runOnce ->", tiredWelder.runOnce(), "|", tiredWelder.statusLine)  // 0 | 15%
print("runShift with 0 rounds ->", runShift([tiredWelder], rounds: 0))                // 0


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }

    var statusCode: Int { healthCode(for: cell.level()) }

    // Why does Drone implement recharge(by:) without `mutating`?  -> Drone is a class, so self is a reference: recharging changes the PowerCell object the drone points to, never the reference itself, so there is nothing for `mutating` to do (and classes aren't allowed to write it).
    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let componentID: String
    var chargeLevel: Int

    var statusCode: Int { healthCode(for: chargeLevel) }

    mutating func recharge(by amount: Int) {
        chargeLevel = PowerCell.rechargedLevel(from: chargeLevel, by: amount)
    }
}

func buildSensors(from records: [(id: String, charge: Int)]) -> [SensorModule] {
    var sensors: [SensorModule] = []
    for record in records {
        sensors.append(SensorModule(componentID: record.id, chargeLevel: record.charge))
    }
    return sensors
}

print("\n--- 4.2 Rechargeable ---")
// Test objects only, so the fleet and the real sensors keep their values for D.
let testDrone = WelderDrone(id: "W-TEST", cell: PowerCell(charge: 10))
print("before:", testDrone.diagnose())                       // W-TEST: code 2
testDrone.recharge(by: 50)                                   // works on a `let`: it's a class
print("after recharge(by: 50):", testDrone.diagnose())       // W-TEST: code 0

var testSensor = SensorModule(componentID: "test-sensor", chargeLevel: 30)
print("before:", testSensor.diagnose())                      // test-sensor: code 1
testSensor.recharge(by: 500)                                 // needs `var`: it's a struct
print("after recharge(by: 500):", testSensor.chargeLevel, testSensor.diagnose())  // 100, code 0
// With `let testSensor` the call above would fail:
// error: cannot use mutating member on immutable value: 'testSensor' is a 'let' constant

// 4.3
// Why could [Drone] never have held the sensors?  -> [Drone] only accepts Drone and its subclasses, and SensorModule is a struct, which can never inherit from a class, so only a protocol can be shared by both.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = "=== DIAGNOSTICS: \(components.count) components ==="
    for component in components {
        report += "\n  " + component.diagnose()
    }
    return report
}

print("\n--- 4.3 Diagnostics screen ---")
let sensors = buildSensors(from: sensorData)
var components: [Diagnosable] = []
for drone in fleet {
    components.append(drone)
}
for sensor in sensors {
    components.append(sensor)
}
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }

    // THE Health Rule. This is the only place in the file that knows the thresholds.
    func healthCode(for level: Int) -> Int {
        switch level {
        case ..<20: return 2   // critical
        case ..<50: return 1   // warning
        default:    return 0   // nominal
        }
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }

    var statusCode: Int { healthCode(for: signalStrength) }

    func diagnose() -> String {
        "[LEGACY HARDWARE] \(name): signal \(signalStrength), code \(statusCode). Original station equipment, check by hand"
    }
}

func totalStatusCode(of components: [Diagnosable]) -> Int {
    var total = 0
    for component in components {
        total += component.statusCode
    }
    return total
}

print("\n--- 5.2 Diagnostics with the beacon ---")
components.append(beacon)
print(diagnosticsReport(components))

let D = totalStatusCode(of: components)
print("Mission fragment D =", D)  // drones 8 + sensors 2 + beacon 2 = 12

// 5.3
extension Int {
    var powerBar: String {
        let filled = Swift.min(10, Swift.max(0, self / 10))
        return String(repeating: "#", count: filled) + String(repeating: ".", count: 10 - filled)
    }
}

print("\n--- 5.3 powerBar ---")
print("42  ->", 42.powerBar)    // ####......
print("-5  ->", (-5).powerBar)  // ..........
print("250 ->", 250.powerBar)   // ##########
print("100 ->", 100.powerBar)   // ##########


// MARK: Level 6 · Incident Reports
// Two of these do not compile. Two compile and lie.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())

// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
*/

print("\n--- 6 Incident Reports (fixed) ---")

// ---------- Report 1 ----------
// Expected: a PatchDrone that produces 30 work units per task.
// Actual:   DOES NOT COMPILE:
//           error: overriding declaration requires an 'override' keyword
// Rule:     when a subclass replaces a superclass method, Swift makes you write `override`,
//           so you can never replace a parent method by accident (or think you replaced one
//           when you didn't).
// Fix:
class PatchDrone: Drone {
    override func performTask() -> Int {
        return 30
    }
}

let patchDrone = PatchDrone(id: "P-1", cell: PowerCell(charge: 50))
print("Report 1 fixed: PatchDrone runOnce ->", patchDrone.runOnce(), "|", patchDrone.statusLine)  // 30 | 40%

// ---------- Report 2 ----------
// Expected: a HeavyWelder that produces 999 work units per run.
// Actual:   DOES NOT COMPILE, two errors:
//           error: inheritance from a final class 'WelderDrone'
//           error: instance method overrides a 'final' instance method
// Rule:     a `final` class can't be subclassed, and a `final` method can't be overridden.
//           runOnce() is final on purpose: overriding it would give 999 units without
//           paying any charge.
// Fix:      subclass Drone (not the final WelderDrone) and change only the COST and the WORK.
//           The ritual stays the same.
final class HeavyWelder: Drone {
    override var powerCost: Int { 50 }

    override func performTask() -> Int { 90 }
}

let heavyWelder = HeavyWelder(id: "HW-1", cell: PowerCell(charge: 100))
print("Report 2 fixed: HeavyWelder runOnce ->", heavyWelder.runOnce(), "|", heavyWelder.statusLine)  // 90 | 50%

// ---------- Report 3 ----------
// Expected: prints the welder's weldSeam() message.
// Actual:   DOES NOT COMPILE:
//           error: value of type 'Drone' has no member 'weldSeam'
// Rule:     the compiler only allows members of the STATIC type. reportFleet is [Drone], so
//           `first` is a Drone, and Drone has no weldSeam(), even though the object really is
//           a WelderDrone at runtime.
// Fix:      ask at runtime with a conditional cast.
//           as? returns an optional because the cast can fail: the Drone might be a scanner,
//           and then there is no welder to give back, so you get nil instead of a crash.
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print("Report 3 fixed:", welder.weldSeam())
}
let notAWelder: Drone = ScannerDrone(id: "S-9", cell: PowerCell(charge: 100))
if let welder = notAWelder as? WelderDrone {
    print(welder.weldSeam())
} else {
    print("Report 3 fixed: \(notAWelder.id) is not a welder, the cast gave nil")
}

// ---------- Report 4 ----------
// Expected: "thruster T-1".
// Actual:   compiles and prints "generic component".
// Rule:     label() is NOT a requirement of Labelled. It only exists in the extension.
//           Extension-only methods are dispatched STATICALLY: the compiler picks the function
//           from the variable's declared type. parts[0] is declared as Labelled, so the
//           extension's label() runs. Thruster's label() doesn't override it, it only hides
//           it when the static type is Thruster.
//           A method declared IN the protocol is a requirement. It goes into the protocol's
//           witness table and is dispatched DYNAMICALLY, so the real type's version runs.
// Fix:      one line: add `func label() -> String` to the protocol.

// The original, live, to show the lie:
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print("Report 4 original, through [Labelled]:", parts[0].label())                   // generic component
print("Report 4 original, through Thruster:  ", Thruster(componentID: "T-1").label()) // thruster T-1

// The fix:
protocol LabelledFixed {
    var componentID: String { get }
    func label() -> String  // <- the one line that changes the output
}

extension LabelledFixed {
    func label() -> String { "generic component" }
}

struct ThrusterFixed: LabelledFixed {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let fixedParts: [LabelledFixed] = [ThrusterFixed(componentID: "T-1")]
print("Report 4 fixed, through [LabelledFixed]:", fixedParts[0].label())  // thruster T-1

// Note: the task says two reports don't compile, but the compiler rejects THREE:
// Reports 1, 2 and 3. Only Report 4 compiles and lies.


// MARK: Finale · Mission Code

print("\n=============================")
let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")
print("=============================")


// MARK: Bonus

// Two ways to forbid using Drone directly; a protocol-based redesign;
// two or three sentences comparing them.

print("\n--- Bonus ---")

// Way 1, fails at RUNTIME: the base class refuses to be created directly.
class GuardedDrone {
    let id: String

    init(id: String) {
        self.id = id
        if type(of: self) == GuardedDrone.self {
            fatalError("GuardedDrone is abstract: create a subclass instead")
        }
    }

    func performTask() -> Int { 0 }
}

final class GuardedWelder: GuardedDrone {
    override func performTask() -> Int { 40 }
}

let guardedWelder = GuardedWelder(id: "GW-1")
print("Way 1: a subclass is fine:", guardedWelder.id, "->", guardedWelder.performTask())
// let bareDrone = GuardedDrone(id: "G-0")
// compiles, but crashes when that line runs:
// Fatal error: GuardedDrone is abstract: create a subclass instead

// Way 2, fails at COMPILE TIME: make the base type a protocol, which can't be instantiated.
// This is also the protocol-based redesign of the fleet.
// (It sits next to the class design only for comparison. A real station would keep just one,
// so the ritual below is the protocol version of Drone.runOnce, not a second copy of the rule.)
protocol RepairDrone: Diagnosable {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int
}

extension RepairDrone {
    var componentID: String { id }

    var statusCode: Int { healthCode(for: cell.level()) }

    // Not a requirement, so it's statically dispatched (like Report 4). Through RepairDrone
    // this version always runs. That's the protocol world's version of `final`.
    func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

// let bareRepairDrone = RepairDrone()
// error: 'any RepairDrone' cannot be constructed because it has no accessible initializers

enum ProtocolFleet {
    struct WelderDrone: RepairDrone {
        let id: String
        let cell: PowerCell
        let powerCost = 25

        func performTask() -> Int { 40 }

        func weldSeam() -> String {
            "\(id) welds a hull seam (struct version)"
        }
    }

    struct CargoDrone: RepairDrone {
        let id: String
        let cell: PowerCell
        let powerCost = 20

        func performTask() -> Int { 25 }
    }
}

let protocolFleet: [RepairDrone] = [
    ProtocolFleet.WelderDrone(id: "PW-1", cell: PowerCell(charge: 80)),
    ProtocolFleet.CargoDrone(id: "PC-1", cell: PowerCell(charge: 100))
]
var protocolWork = 0
for drone in protocolFleet {
    protocolWork += drone.runOnce()
}
print("Way 2: protocol fleet, one round ->", protocolWork, "work units")  // 40 + 25 = 65
print(diagnosticsReport(protocolFleet))  // still Diagnosable: it fits the same screen

// The struct trap: a copy of a struct drone still shares the SAME PowerCell (a class).
let structWelder = ProtocolFleet.WelderDrone(id: "PW-2", cell: PowerCell(charge: 100))
let structCopy = structWelder
_ = structCopy.runOnce()
print("struct copy ran once -> original's charge is", structWelder.cell.level())  // 75, shared battery

// Comparison:
// The class design gives every drone one identity, shared stored properties and a `final`
// ritual that the compiler enforces, but Swift lets anyone create a plain, useless Drone.
// The protocol design can't be instantiated, works for structs and for types we don't own,
// and lets a type conform to many protocols, but stored state has to be repeated in every
// struct, and the "final" ritual is only protected by static dispatch.
// For this station I'd keep the class design: drones are physical machines whose battery state
// must be shared by everyone holding them. With structs, shared mutable state only works by
// putting a class (PowerCell) inside, and then copies quietly share the battery, as shown above.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?
    `mutating` in a protocol means "this method is allowed to change self".
    For a struct, self IS the value, so changing chargeLevel changes self. The struct has
    to mark the method `mutating` (self becomes inout), and it can only be called on a `var`.
    For a class, self is a reference. recharge changes the object on the heap (the PowerCell),
    never the reference, so every class method can already do that, and the keyword means
    nothing for classes (it isn't even allowed). That's why `let testDrone` can be recharged
    and `let testSensor` can't.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:
    • Inheritance: subclasses inherit STORED properties and real implementations that can be
      locked with `final` or extended with `super`. Every drone gets id + cell + init and the
      final runOnce() for free, and ScannerDrone builds on super.statusLine. A protocol can't
      store anything, so every conforming struct has to declare its own properties.
    • Protocols: they unite types that can't share a superclass. A class (Drone), a struct
      (SensorModule) and a type I'm not allowed to edit (LegacyBeacon, via an extension) all
      fit into one [Diagnosable]. A struct can't inherit from anything, and a class can have
      only one superclass, but any type can adopt many protocols.

 3. What does `final` prevent, and what did it protect in runOnce()?
    `final` on a class prevents subclassing it. On a method or property it prevents
    overriding it. On runOnce() it protects the shift ritual: "pay powerCost first, work only
    if paid". No subclass can skip the payment, produce work for free or drive the charge
    negative. Report 2's HeavyWelder (999 units, no cost) is exactly what it blocks.
    Bonus effect: the compiler knows there's only one version, so it can call it directly
    (static dispatch).

 4. In Report 4, why did the protocol extension's method win?
    Because label() wasn't a requirement of Labelled, only an extension method. Extension-only
    methods are chosen at COMPILE time from the declared type. parts is [Labelled], so
    parts[0].label() is compiled as "call Labelled's extension label()". Thruster's own
    label() isn't an override, it's just another function with the same name, used only when
    the static type is Thruster. Declaring `func label() -> String` in the protocol turns it
    into a requirement, and requirements are looked up at RUNTIME in the real type's witness
    table, so Thruster's version wins.

*/
