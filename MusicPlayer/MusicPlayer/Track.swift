struct Track {
    let title: String
    let artist: String
    let fileName: String
    let coverImageName: String
}

enum TrackLibrary {
    static let tracks: [Track] = [
        .init(title: "First Light", artist: "Quiet Frequencies", fileName: "Track01", coverImageName: "Track01"),
        .init(title: "Slow Current", artist: "Quiet Frequencies", fileName: "Track02", coverImageName: "Track02"),
        .init(title: "Paper Lanterns", artist: "Quiet Frequencies", fileName: "Track03", coverImageName: "Track03"),
        .init(title: "Blue Hour", artist: "Quiet Frequencies", fileName: "Track04", coverImageName: "Track04"),
        .init(title: "Pine Shadows", artist: "Quiet Frequencies", fileName: "Track05", coverImageName: "Track05"),
        .init(title: "After the Rain", artist: "Quiet Frequencies", fileName: "Track06", coverImageName: "Track06"),
        .init(title: "Winter Window", artist: "Quiet Frequencies", fileName: "Track07", coverImageName: "Track07"),
        .init(title: "Small Hours", artist: "Quiet Frequencies", fileName: "Track08", coverImageName: "Track08"),
        .init(title: "Open Ridge", artist: "Quiet Frequencies", fileName: "Track09", coverImageName: "Track09"),
        .init(title: "Going Home", artist: "Quiet Frequencies", fileName: "Track10", coverImageName: "Track10")
    ]
}
