// Assignment #2: Working with Collections in Swift
// Author: Erdaulet Toktagul

// MARK: - Easy Tasks

// 1. Array Creation and Access
let fruits: [String] = ["apple", "banana", "orange", "mango", "kiwi"]
print("Easy 1 - Third fruit:", fruits[2])

// 2. Set Creation and Manipulation
var favoriteNumbers: Set<Int> = [3, 7, 13, 21]
favoriteNumbers.insert(42)
print("Easy 2 - Updated set of favorite numbers:", favoriteNumbers)

// 3. Dictionary Creation and Access
let languageReleaseYears: [String: Int] = [
    "Swift": 2014,
    "Python": 1991,
    "Java": 1995
]
print("Easy 3 - Swift release year:", languageReleaseYears["Swift"]!)

// 4. Array Element Update
var colors: [String] = ["red", "green", "blue", "yellow"]
colors[1] = "purple"
print("Easy 4 - Updated colors:", colors)

// MARK: - Medium Tasks

// 1. Set Intersection
let firstSet: Set<Int> = [1, 2, 3, 4]
let secondSet: Set<Int> = [3, 4, 5, 6]
let commonNumbers = firstSet.intersection(secondSet)
print("Medium 1 - Intersection:", commonNumbers)

// 2. Dictionary Update
var studentScores: [String: Int] = [
    "Aruzhan": 85,
    "Dias": 72,
    "Madina": 90
]
studentScores.updateValue(95, forKey: "Dias")
print("Medium 2 - Updated scores:", studentScores)

// 3. Array Merge
let firstFruits: [String] = ["apple", "banana"]
let secondFruits: [String] = ["cherry", "date"]
let mergedFruits = firstFruits + secondFruits
print("Medium 3 - Merged array:", mergedFruits)

// MARK: - Hard Tasks

// 1. Dictionary Key Addition
var countryPopulations: [String: Int] = [
    "Kazakhstan": 20_000_000,
    "Japan": 124_000_000,
    "Germany": 84_000_000
]
countryPopulations["Canada"] = 41_000_000
print("Hard 1 - Updated populations:", countryPopulations)

// 2. Set Union and Subtract
let petsA: Set<String> = ["cat", "dog"]
let petsB: Set<String> = ["dog", "mouse"]
let allPets = petsA.union(petsB)
let finalPets = allPets.subtracting(petsB)
print("Hard 2 - Union:", allPets)
print("Hard 2 - After subtracting second set:", finalPets)

// 3. Nested Collection
let studentGrades: [String: [Int]] = [
    "Aruzhan": [90, 85, 78],
    "Dias": [70, 88, 92],
    "Madina": [95, 91, 89]
]
print("Hard 3 - Dias's second grade:", studentGrades["Dias"]![1])
