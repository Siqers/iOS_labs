// Assignment #1: Your Life Story in Swift
// Author: Erdaulet Toktagul

// MARK: - Step 1: Personal Information

let firstName: String = "Erdaulet"
let lastName: String = "Toktagul"
let birthYear: Int = 2006
let isStudent: Bool = true
let height: Double = 1.78
let city: String = "Almaty"
let country: String = "Kazakhstan"
let languages: [String] = ["Kazakh", "Russian", "English"]
let university: String = "KBTU"
let major: String = "Computer Science"

// Bonus Challenge: calculate age from currentYear and birthYear
let currentYear: Int = 2026
let age: Int = currentYear - birthYear

// MARK: - Step 2: Hobbies and Interests

let hobby: String = "programming"
let numberOfHobbies: Int = 4
let favoriteNumber: Int = 7
let isHobbyCreative: Bool = true
let otherHobbies: [String] = ["playing football", "watching movies", "traveling"]
let favoriteFood: String = "beshbarmak"
let favoriteProgrammingLanguage: String = "Swift"
let hoursOfCodingPerWeek: Double = 15.5

// MARK: - Bonus: emoji as values and variable names

let 🎯 = "become a professional iOS developer"
let 📱 = "an app that helps students plan their day"
let 😊 = "🚀"
let favoriteEmoji = "💻"

// MARK: - Step 3: Life Story Summary

let studentStatus = isStudent ? "I am currently a student" : "I am not a student right now"
let hobbyType = isHobbyCreative ? "a creative" : "not a creative"

var lifeStory = """
My name is \(firstName) \(lastName). \
I am \(age) years old, born in \(birthYear). \
\(studentStatus). \
I enjoy \(hobby), which is \(hobbyType) hobby. \
I have \(numberOfHobbies) hobbies in total, and my favorite number is \(favoriteNumber).
"""

// Additional details about me
lifeStory += """
 I live in \(city), \(country), and I am \(height) meters tall. \
I study \(major) at \(university) and speak \(languages.count) languages: \
\(languages.joined(separator: ", ")). \
Besides \(hobby), I also like \(otherHobbies.joined(separator: ", ")). \
My favorite food is \(favoriteFood), and my favorite programming language is \(favoriteProgrammingLanguage). \
I spend about \(hoursOfCodingPerWeek) hours a week coding \(favoriteEmoji).
"""

// MARK: - Bonus Task: Future Goals

let futureGoals: String = "In the future, I want to \(🎯) and build \(📱) \(😊)"
lifeStory += " " + futureGoals

// MARK: - Step 4: Print Life Story

print(lifeStory)
