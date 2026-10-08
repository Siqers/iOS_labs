// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Author: Erdaulet Toktagul


// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab:    return 3
        case .engine: return 4
        case .cargo:  return 5
        }
    }
}

print("\n--- 1.1 Deck ---")
for deck in Deck.allCases {
    print("\(deck.rawValue): evacuation priority \(deck.evacuationPriority)")
}
print("Deck(rawValue: \"medbay\")     ->", Deck(rawValue: "medbay")?.rawValue ?? "nil")      // medbay
print("Deck(rawValue: \"greenhouse\") ->", Deck(rawValue: "greenhouse")?.rawValue ?? "nil")  // nil

// 1.2
enum AlarmLevel: Int {
    case green = 0, yellow, orange, red

    static let massPerStep = 500

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let steps = max(0, mass / massPerStep)
        let clamped = min(steps, AlarmLevel.red.rawValue)
        // clamped is always 0...3, so the fallback can't fire. If it ever did, red is the safe answer.
        return AlarmLevel(rawValue: clamped) ?? .red
    }
}

print("\n--- 1.2 AlarmLevel ---")
for mass in [0, 499, 500, 940, 1000, 1499, 1500, 4000] {
    let level = AlarmLevel.level(forTotalMass: mass)
    print("\(mass) kg -> \(level) (rawValue \(level.rawValue))")
}
// 0 green, 499 green, 500 yellow, 940 yellow, 1000 orange, 1499 orange, 1500 red, 4000 red


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)  // always has at least one element
    switch (parts[0], parts.count) {
    case ("crate", 3):
        guard let id = Int(parts[1]), let massKg = Int(parts[2]) else { break }
        return .crate(id: id, massKg: massKg)
    case ("container", 3):
        guard let massKg = Int(parts[2]) else { break }
        return .container(code: parts[1], massKg: massKg)
    case ("livestock", 4):
        guard let count = Int(parts[2]), let massPerUnitKg = Int(parts[3]) else { break }
        return .livestock(species: parts[1], count: count, massPerUnitKg: massPerUnitKg)
    default:
        break
    }
    return .unknown(raw: line)
}

print("\n--- 2.2 parseEntry ---")
print(parseEntry("crate:101:120"))             // crate(id: 101, massKg: 120)
print(parseEntry("container:KZ-ALM-7:340"))    // container(code: "KZ-ALM-7", massKg: 340)
print(parseEntry("livestock:lab mice:12:2"))   // livestock(species: "lab mice", count: 12, massPerUnitKg: 2)
print(parseEntry("crate:104:abc"))             // unknown: number doesn't parse
print(parseEntry("crate:1:2:3"))               // unknown: wrong field count
print(parseEntry("boat:1:2"))                  // unknown: unknown tag

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

func summarizeManifest(_ lines: [String]) -> (totalMass: Int, unknownCount: Int) {
    var totalMass = 0
    var unknownCount = 0
    for line in lines {
        let entry = parseEntry(line)
        totalMass += mass(of: entry)
        if case .unknown = entry {
            unknownCount += 1
        }
    }
    return (totalMass: totalMass, unknownCount: unknownCount)
}

print("\n--- 2.3 mass ---")
print("mass of livestock:lab mice:12:2 =", mass(of: parseEntry("livestock:lab mice:12:2")))  // 24
print("mass of a corrupted line =", mass(of: parseEntry("???")))                             // 0
let manifest = summarizeManifest(rawManifest)
print("Manifest: total mass \(manifest.totalMass) kg, \(manifest.unknownCount) unknown lines")  // 1244 kg, 3 unknown

let A = manifest.totalMass
print("Integrity fragment A =", A)


// MARK: Level 3 · Crew Snapshots

// 3.1
// A snapshot is just data about a person at one moment, so it's a struct.
// No initializer written: Swift generates the memberwise init(name:deck:oxygen:) for structs.
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    var summary: String {
        "\(name) [\(deck.rawValue), O2 \(oxygen)%]"
    }

    mutating func breathe(_ amount: Int) {
        guard amount > 0 else { return }
        oxygen = max(0, oxygen - amount)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

print("\n--- 3.1 CrewSnapshot ---")
var rookie = CrewSnapshot.rookie(named: "Aliya")
print("rookie:", rookie.summary)                       // Aliya [bridge, O2 100%]
rookie.breathe(130)
print("after breathe(130):", rookie.summary)           // O2 0, never below 0
rookie.move(to: .cargo)
print("after move(to: .cargo):", rookie.summary)       // cargo
rookie.reviveInMedbay()
print("after reviveInMedbay():", rookie.summary)       // Aliya [medbay, O2 100%]

// 3.2
func buildRoster(from records: [(name: String, deck: String, oxygen: Int)]) -> [CrewSnapshot] {
    var roster: [CrewSnapshot] = []
    for record in records {
        guard let deck = Deck(rawValue: record.deck) else {
            print("Warning: \(record.name) is on unknown deck \"\(record.deck)\", skipped")
            continue
        }
        roster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
    }
    return roster
}

print("\n--- 3.2 Roster ---")
let crewRoster: [CrewSnapshot] = buildRoster(from: crewData)
for member in crewRoster {
    print(member.summary)
}
let testRoster = buildRoster(from: [
    (name: "Ghost", deck: "greenhouse", oxygen: 50),
    (name: "Arman", deck: "medbay", oxygen: 80)
])
print("test roster size:", testRoster.count)  // 1 (Ghost skipped with a warning)

// 3.3 · Value-semantics demonstration (copy / plain parameter / inout)
print("\n--- 3.3 Value semantics ---")

// 1. Copy
let originalSnapshot = CrewSnapshot.rookie(named: "Bekzat")
var copiedSnapshot = originalSnapshot
print("1. before: original O2 \(originalSnapshot.oxygen), copy O2 \(copiedSnapshot.oxygen)")
copiedSnapshot.breathe(30)
print("1. after copy.breathe(30): original O2 \(originalSnapshot.oxygen), copy O2 \(copiedSnapshot.oxygen)")
// original 100, copy 70

// 2. Plain (non-inout) parameter: the function gets its own copy
func drainPlain(_ member: CrewSnapshot) {
    var local = member  // parameters are constants, so change a local copy
    local.breathe(50)
    print("   inside drainPlain: O2 \(local.oxygen)")
}

var passenger = CrewSnapshot.rookie(named: "Madina")
print("2. before drainPlain: O2 \(passenger.oxygen)")
drainPlain(passenger)
print("2. after drainPlain:  O2 \(passenger.oxygen) (unchanged)")

// 3. inout parameter: the function writes back into the caller's variable
func drainInout(_ member: inout CrewSnapshot) {
    member.breathe(50)
    print("   inside drainInout: O2 \(member.oxygen)")
}

print("3. before drainInout: O2 \(passenger.oxygen)")
drainInout(&passenger)
print("3. after drainInout:  O2 \(passenger.oxygen) (changed)")


// MARK: Level 4 · The Teleport Pod

// 4.1
// TeleportPod is a class: a pod is one physical machine with an identity. Everyone who
// holds "pod P-1" must see the same charge and the same occupant. It also needs deinit and ===
// (Bonus), which only classes have.
final class TeleportPod {
    static let fireCost = 20

    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // Why I have to write this init: structs get a free memberwise initializer, classes don't.
    // A class can be subclassed, and Swift's class init rules (every stored property of the
    // whole class chain must be set) are too complex to auto-generate a memberwise init.
    // A class only gets a free init() when ALL its stored properties have default values,
    // and id / chargeLevel have none.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    // Bonus 1
    deinit {
        print("   [deinit] pod \(id) destroyed")
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= TeleportPod.fireCost else { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let passenger = occupant else { return nil }  // empty pod: no charge spent
        chargeLevel -= TeleportPod.fireCost
        occupant = nil
        return passenger
    }
}

func crewMember(named name: String, in roster: [CrewSnapshot]) -> CrewSnapshot? {
    for member in roster where member.name == name {
        return member
    }
    return nil
}

print("\n--- 4.1 TeleportPod ---")
let testPod = TeleportPod(id: "T-1", chargeLevel: 30)
let rookieA = CrewSnapshot.rookie(named: "Aliya")
let rookieB = CrewSnapshot.rookie(named: "Arman")
print("load Aliya into empty pod:", testPod.load(rookieA))          // true
print("load Arman into occupied pod:", testPod.load(rookieB))       // false
print("fire ->", testPod.fire()?.name ?? "nobody", "| charge", testPod.chargeLevel)  // Aliya | 10
print("load Arman with charge 10:", testPod.load(rookieB))          // false (charge < 20)
print("fire empty pod ->", testPod.fire()?.name ?? "nobody", "| charge", testPod.chargeLevel)  // nobody | 10

// 4.2 · Charge ledger: load+fire three times, then fire an empty pod
print("\n--- 4.2 Charge ledger ---")
let ledgerPod = TeleportPod(id: "P-1", chargeLevel: 100)
print("start: charge \(ledgerPod.chargeLevel)")
for name in ["Timur", "Dana", "Nurlan"] {
    guard let member = crewMember(named: name, in: crewRoster) else {
        print("\(name) is not in the roster, skipped")
        continue
    }
    let loaded = ledgerPod.load(member)
    let arrived = ledgerPod.fire()
    print("load \(name): \(loaded), fire -> \(arrived?.name ?? "nobody"), charge \(ledgerPod.chargeLevel)")
}
let emptyShot = ledgerPod.fire()
print("fire empty pod -> \(emptyShot?.name ?? "nobody"), charge \(ledgerPod.chargeLevel)")

let C = ledgerPod.chargeLevel
print("Integrity fragment C =", C)

// 4.3 · Reference-semantics demonstration
print("\n--- 4.3 Reference vs value ---")
let podOne = TeleportPod(id: "P-2", chargeLevel: 100)
let podAlias = podOne
print("class  before: podOne \(podOne.chargeLevel), podAlias \(podAlias.chargeLevel)")
podAlias.chargeLevel = 35
print("class  after podAlias.chargeLevel = 35: podOne \(podOne.chargeLevel), podAlias \(podAlias.chargeLevel)")
// both 35

let snapOne = CrewSnapshot.rookie(named: "Dana")
var snapAlias = snapOne
print("struct before: snapOne O2 \(snapOne.oxygen), snapAlias O2 \(snapAlias.oxygen)")
snapAlias.oxygen = 35
print("struct after snapAlias.oxygen = 35: snapOne O2 \(snapOne.oxygen), snapAlias O2 \(snapAlias.oxygen)")
// 100 and 35

// Rule: assigning a class instance copies the REFERENCE (two names, one object), while assigning a struct copies the whole VALUE (two independent objects).


// MARK: Level 5 · Station Systems

// 5.1
// Station is a class: there is ONE live station, and every system holding it must see the
// same hull and oxygen (a struct copy would be an outdated photo). Also, reading a lazy
// property mutates the instance, so on a struct it couldn't be read through a `let` constant.
final class Station {
    // Stored (let)
    let callSign: String

    // Stored (var) with observers
    var hullIntegrity: Int = 100 {
        willSet {
            print("   hull: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            // Assigning to the property inside its own didSet does NOT trigger the observers again.
            hullIntegrity = min(100, max(0, hullIntegrity))
        }
    }

    // Stored, built from the readings in init
    var oxygenByDeck: [Deck: Int]

    // private(set): blocks outside code from faking the counter; it only exists to prove the lazy behaviour
    private(set) var scanCount = 0

    // Lazy stored
    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        self.scanCount += 1
        var report = "\(self.callSign) diagnostics: hull \(self.hullIntegrity)%"
        for deck in Deck.allCases {
            if let oxygen = self.oxygenByDeck[deck] {
                report += ", \(deck.rawValue) \(oxygen)%"
            } else {
                report += ", \(deck.rawValue) no data"
            }
        }
        return report
    }()

    // Computed, read-only (no `get` keyword)
    var totalOxygen: Int {
        var total = 0
        for oxygen in oxygenByDeck.values {
            total += oxygen
        }
        return total
    }

    // Computed, get + set
    var averageOxygen: Int {
        get {
            guard oxygenByDeck.isEmpty == false else { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in Deck.allCases {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        var byDeck: [Deck: Int] = [:]
        for reading in readings {
            guard let deck = Deck(rawValue: reading.deck) else {
                print("\(callSign): skipped reading for unknown deck \"\(reading.deck)\"")
                continue
            }
            byDeck[deck] = reading.oxygen
        }
        oxygenByDeck = byDeck
    }
}

print("\n--- 5.1 Station ---")
let station = Station(callSign: "ALMA-7", readings: deckReadings)  // skips "greenhouse"
let B = station.averageOxygen
print("callSign:", station.callSign)
print("totalOxygen:", station.totalOxygen, "| averageOxygen:", station.averageOxygen)  // 285 | 57
print("Integrity fragment B =", B)

print("scans before touching fullDiagnostics:", station.scanCount)   // 0, and no scan message so far
print("first access:")
print(station.fullDiagnostics)                                       // "Running full scan..." appears here
print("second access:")
print(station.fullDiagnostics)                                       // no scan message this time
print("scans after two accesses:", station.scanCount)                // 1

let backupStation = Station(callSign: "ALMA-7B", readings: [(deck: "lab", oxygen: 30), (deck: "cargo", oxygen: 50)])
print("backup total:", backupStation.totalOxygen, "| average:", backupStation.averageOxygen)  // 80 | 40
backupStation.averageOxygen = 70
print("after averageOxygen = 70: total", backupStation.totalOxygen, "| average", backupStation.averageOxygen)  // 350 | 70
print("backup never touched fullDiagnostics, scans:", backupStation.scanCount)  // 0, no scan message ever

// 5.2 · The clamp trap: 130, then -40, then 55
print("\n--- 5.2 Clamp trap ---")
station.hullIntegrity = 130
print("hull after = 130:", station.hullIntegrity)   // 100
station.hullIntegrity = -40
print("hull after = -40:", station.hullIntegrity)   // 0
station.hullIntegrity = 55
print("hull after = 55:", station.hullIntegrity)    // 55

// Why the clamp doesn't loop forever: when didSet assigns to its own property, Swift writes
// straight into the stored value and does NOT call willSet/didSet again. That's why there's
// only ONE "hull: a -> b" line per assignment above, even though didSet assigns a second time.

print("fullDiagnostics now:", station.fullDiagnostics)  // still says hull 100: lazy ran once and kept its value


// MARK: Level 6 · Incident Reports
// Three of these compile and are wrong. One does not compile.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)   // author expected the crew to have lost oxygen

// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)   // author expected 100

// Report 3
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}

// Report 4
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
*/

print("\n--- 6 Incident Reports (fixed) ---")

// ---------- Report 1 ----------
// Expected: every crew member loses 10 oxygen, so roster[0].oxygen prints 52 (Timur: 62 - 10).
// Actual:   compiles, prints 62. Nothing changed.
// Rule:     CrewSnapshot is a struct (value type). `for var member in roster` gives the loop a
//           COPY of each element. The copy loses 10 and is thrown away after each iteration.
//           The array itself is never written to.
// Fix:      loop over the indices and change the elements inside the array.
var report1Roster = crewRoster
print("Report 1 before:", report1Roster[0].summary)
for index in report1Roster.indices {
    report1Roster[index].breathe(10)  // breathe also keeps oxygen from going below 0
}
print("Report 1 fixed: ", report1Roster[0].summary)  // O2 52

// ---------- Report 2 ----------
// Expected: podA keeps 100, because "podB is a copy".
// Actual:   compiles, prints 0. `let podB = podA` copies the REFERENCE, not the pod.
//           podA and podB are two names for one object.
// Rule:     classes are reference types, so assignment shares the instance. `let` only stops
//           podB from pointing at another pod. It doesn't freeze the pod itself.
// Fix:      if you need an independent pod, create a new instance.
let report2PodA = TeleportPod(id: "A", chargeLevel: 100)
let report2PodB = TeleportPod(id: "A-2", chargeLevel: report2PodA.chargeLevel)
report2PodB.chargeLevel = 0
print("Report 2 fixed: podA \(report2PodA.chargeLevel), podB \(report2PodB.chargeLevel)")  // 100, 0

// ---------- Report 3 ----------
// Expected: add(_:) appends an entry to the logbook.
// Actual:   DOES NOT COMPILE:
//           error: cannot use mutating member on immutable value: 'self' is immutable
// Rule:     inside a normal struct method, `self` is a constant. entries.append changes a
//           stored property, which changes self, so the method must be marked `mutating`.
// Fix:
struct Logbook {
    var entries: [String] = []

    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}

var logbook = Logbook()
print("Report 3 before:", logbook.entries)    // []
logbook.add("Day 10: teleporter fired")
logbook.add("Day 10: manifest rebuilt")
print("Report 3 fixed: ", logbook.entries)    // 2 entries

// ---------- Report 4 ----------
// Expected: the author thought both lines behave the same, since both are `let`.
// Actual:   snapshot.oxygen = 40 DOES NOT COMPILE:
//             error: cannot assign to property: 'snapshot' is a 'let' constant
//           pod.chargeLevel = 10 compiles and works.
// Rule:     `let` freezes whatever is stored in the constant itself.
//           • struct: the constant holds the VALUE itself (name + deck + oxygen), so `let`
//             freezes the whole value, including properties declared `var`.
//           • class: the constant holds only a REFERENCE (an address). `let` freezes that
//             reference, so pod can never point to a different pod, but the object on the heap
//             is still mutable through its `var` properties. What WOULD fail is:
//               pod = TeleportPod(id: "C", chargeLevel: 0)
//               error: cannot assign to value: 'pod' is a 'let' constant
// Fix:      make the snapshot `var`. The pod line is correct as it is.
var report4Snapshot = CrewSnapshot.rookie(named: "Dana")
report4Snapshot.oxygen = 40
let report4Pod = TeleportPod(id: "B", chargeLevel: 50)
report4Pod.chargeLevel = 10
print("Report 4 fixed: snapshot O2 \(report4Snapshot.oxygen), pod charge \(report4Pod.chargeLevel)")  // 40, 10

// Note: the task says only one report fails to compile, but the compiler rejects two:
// Report 3 and the snapshot line of Report 4. Reports 1, 2 and the pod line of Report 4 compile.


// MARK: Level 7 · Sealing the Black Box

// The leaky original:
//
// class FlightRecorder {
//     var entries: [String] = []
//     var isSealed = false
// }
//
// Your sealed version below. One comment per access keyword.

// FlightRecorder is a class: there is exactly ONE black box. Everyone holding it must see the
// same entries and the same seal. With a struct, someone could keep a copy from before sealing
// and keep writing into it, and then there would be two different "histories".
final class FlightRecorder {
    // private: blocks all code outside this class from replacing, clearing or appending to the list
    private var entries: [String] = []

    // private(set): blocks writes from outside, so nobody can set isSealed back to false (reading is allowed)
    internal private(set) var isSealed = false

    // internal: blocks only other modules; anyone in this app can read how many entries exist
    internal var entryCount: Int {
        entries.count
    }

    // internal: blocks only other modules; the transcript is a read-only formatted copy
    internal var transcript: String {
        var text = "FLIGHT RECORDER (\(isSealed ? "sealed" : "open")), \(entries.count) entries"
        for (index, entry) in entries.enumerated() {
            text += "\n  \(index + 1). \(entry)"
        }
        return text
    }

    // internal: blocks only other modules; add itself refuses to write after sealing
    @discardableResult
    internal func add(_ entry: String) -> Bool {
        guard isSealed == false else { return false }
        entries.append(entry)
        return true
    }

    // internal: blocks only other modules; sealing is one-way, there is no unseal method
    internal func seal() {
        isSealed = true
    }

    // fileprivate: blocks code in other files; only this file's audit function can read the raw list (as a copy)
    fileprivate func rawEntries() -> [String] {
        entries
    }
}

// A free function elsewhere in the file that uses your fileprivate helper:
func auditTranscript(of recorder: FlightRecorder) -> String {
    let entries = recorder.rawEntries()
    var characters = 0
    var longest = ""
    for entry in entries {
        characters += entry.count
        if entry.count > longest.count {
            longest = entry
        }
    }
    return "AUDIT: \(entries.count) entries, \(characters) characters, longest: \"\(longest)\", sealed: \(recorder.isSealed)"
}

print("\n--- 7 Flight Recorder ---")
let blackBox = FlightRecorder()
blackBox.add("03:14 teleporter reports full crew transfer")
blackBox.add("03:15 manifest rebuilt with enums")
print("entries:", blackBox.entryCount, "| sealed:", blackBox.isSealed)   // 2 | false
blackBox.seal()
let lateWriteAccepted = blackBox.add("03:20 nothing happened here")
print("add after seal accepted:", lateWriteAccepted)                     // false
print("entries:", blackBox.entryCount, "| sealed:", blackBox.isSealed)   // 2 | true
print(blackBox.transcript)
print(auditTranscript(of: blackBox))

// Trying to break the recorder from outside the type. Each line fails to compile:
//
// blackBox.entries = []
//   error: 'entries' is inaccessible due to 'private' protection level
// blackBox.entries.removeAll()
//   error: 'entries' is inaccessible due to 'private' protection level
// blackBox.isSealed = false
//   error: cannot assign to property: 'isSealed' setter is inaccessible


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
print("\nIntegrity fragment D =", D, "(\(AlarmLevel.level(forTotalMass: A)))")

print("=============================")
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")
print("=============================")


// MARK: Bonus

// deinit in TeleportPod, a do-block lifetime experiment, and === identity
print("\n--- Bonus: deinit and reference counting ---")

// Experiment 1: both references live inside the block.
print("before do block")
do {
    let tempPod = TeleportPod(id: "TMP-1", chargeLevel: 10)
    let secondReference = tempPod  // reference count = 2
    print("inside do block: two references to \(secondReference.id)")
    print("leaving do block...")
}   // <- deinit fires HERE: both constants go out of scope, the count drops 2 -> 0
print("after do block")

// Experiment 2: the second reference lives OUTSIDE the block.
var survivor: TeleportPod? = nil
do {
    let tempPod = TeleportPod(id: "TMP-2", chargeLevel: 10)
    survivor = tempPod  // reference count = 2
    print("inside do block: survivor also points to \(tempPod.id)")
}   // count drops 2 -> 1, the pod is still alive, so no deinit here
print("after do block: survivor still holds \(survivor?.id ?? "nothing")")
survivor = nil  // <- deinit fires HERE: the last reference is gone, count 1 -> 0
print("after survivor = nil")

// === identity check: the station has two records for one crew member.
print("\n--- Bonus: === identity ---")
func identityCheck(_ first: TeleportPod, _ second: TeleportPod) -> String {
    if first === second {
        return "SAME pod \(first.id): two references to one object"
    }
    let sameOccupant = first.occupant?.name == second.occupant?.name
        && first.occupant?.deck == second.occupant?.deck
        && first.occupant?.oxygen == second.occupant?.oxygen
    if first.id == second.id && first.chargeLevel == second.chargeLevel && sameOccupant {
        return "two DIFFERENT pods with equal contents (both \(first.id), \(first.chargeLevel)%, \(first.occupant?.name ?? "empty"))"
    }
    return "two different pods with different contents (\(first.id) vs \(second.id))"
}

let danaRecord = CrewSnapshot.rookie(named: "Dana")
let recordPod = TeleportPod(id: "R-1", chargeLevel: 60)
print("load Dana into R-1:", recordPod.load(danaRecord))
let sameRecordPod = recordPod
let clonedRecordPod = TeleportPod(id: "R-1", chargeLevel: 60)
print("load Dana into the clone:", clonedRecordPod.load(danaRecord))
let otherPod = TeleportPod(id: "R-2", chargeLevel: 60)

print(identityCheck(recordPod, sameRecordPod))     // SAME pod
print(identityCheck(recordPod, clonedRecordPod))   // two different pods, equal contents
print(identityCheck(recordPod, otherPod))          // different pods, different contents

// === on structs doesn't compile:
// danaRecord === danaRecord
//   error: argument type 'CrewSnapshot' expected to be an instance of a class or class-constrained type


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
    Swift automatically writes a memberwise init for every struct, built from its stored
    properties: CrewSnapshot(name:deck:oxygen:). Classes never get one. A class can have
    subclasses, and class init rules (every stored property in the whole class chain must
    be set, designated vs convenience inits) are too complex to generate automatically.
    A class only gets a free init() when ALL stored properties have default values.
    TeleportPod's id and chargeLevel have no defaults, so I had to write
    init(id:chargeLevel:) myself.

 2. What does `mutating` do to self, and why do classes never need it?
    In a normal struct method, self is a constant copy, like a `let` parameter.
    `mutating` turns self into an inout parameter: the method can change stored properties
    or even replace self completely (self = CrewSnapshot(...) in reviveInMedbay), and the new
    value is written back into the caller's variable. That's why a mutating method can only
    be called on a `var`.
    In a class, self is a reference. Methods change the object it points to, not the
    reference, so there's nothing to write back and no `mutating` is needed.

 3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?
    `let` freezes what is stored inside the constant.
    • Struct: the constant stores the whole value (name, deck, oxygen), so everything is
      frozen, even properties declared `var`:
          let snapshot = CrewSnapshot.rookie(named: "Dana")
          snapshot.oxygen = 40     // error
    • Class: the constant stores only a reference (the address of the pod). `let` freezes
      the reference: pod will always point to the same pod. The pod object itself is still
      mutable through its `var` properties:
          let pod = TeleportPod(id: "B", chargeLevel: 50)
          pod.chargeLevel = 10                          // OK, changes the object
          pod = TeleportPod(id: "C", chargeLevel: 0)    // error, changes the reference

 4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?
    A `let` must have its value by the end of init. A lazy property gets its value LATER,
    on first access, so it is written after init, and only a `var` can be written then.
    Behaviour change: the initializer runs at first access, so the RESULT depends on WHEN you
    first read it. In 5.2 fullDiagnostics was first read while hull was 100. After the hull
    changed to 55 it still says "hull 100%", because lazy computes once and keeps the value.
    A computed property would say 55. Also the side effect ("Running full scan...") happens
    at first access, or never: backupStation never prints it.

 5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?
    auditTranscript(of:) is a free function outside the class that needs the raw entries.
    If rawEntries() were private, only code inside FlightRecorder could call it, so
    auditTranscript wouldn't compile. If it were internal, any code in the whole app could
    read the raw list. fileprivate is the exact fit: the recorder and its audit tool live in
    the same file, so only they can use it. The entries array itself stays private, so even
    auditTranscript can only read a copy and can't change history.

 Bonus. On which line does deinit fire, and why can't === be used on
 CrewSnapshot?
    • Experiment 1: deinit fires on the closing brace of the do block. Both references
      (tempPod and secondReference) are local constants of the block. When the block ends they
      are released, the reference count goes 2 -> 0, and ARC destroys the pod immediately.
    • Experiment 2: leaving the block is NOT enough, because `survivor` still holds the pod
      (count 1). deinit fires on the line `survivor = nil`, when the last reference disappears.
    • === asks "do these two references point to the SAME object in memory?". Only class
      instances have that kind of identity. A struct is just a value: every assignment makes
      a new independent copy, so there is no "same instance" to compare. That's why === only
      accepts class instances (AnyObject) and CrewSnapshot gets a compile error. For structs
      you can only compare contents (==, if the type is Equatable).

*/
