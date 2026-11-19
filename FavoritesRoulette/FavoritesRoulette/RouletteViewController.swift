import UIKit

private struct Favorite {
    let title: String
    let imageName: String
    let description: String
}

final class RouletteViewController: UIViewController {
    @IBOutlet private var artwork: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!

    private let favorites: [Favorite] = [
        .init(title: "Ala-Archa Gorge", imageName: "Trail01", description: "The trail follows the river into the gorge. Spruce trees shade the early stretch. The peaks come into view as the valley opens."),
        .init(title: "Kolsai Lakes", imageName: "Trail02", description: "The lower lake is framed by forest. The route to the middle lake climbs through meadows and over roots. The shore is a good place to stop before turning back."),
        .init(title: "Charyn Canyon", imageName: "Trail03", description: "The path descends between bands of red rock. In the Valley of Castles the walls rise on both sides. There is little shade on the way to the river."),
        .init(title: "Big Almaty Lake", imageName: "Trail04", description: "The reservoir sits in a basin above Almaty. Its color changes with the light and sediment. The road offers several views of the surrounding slopes."),
        .init(title: "Kaindy Lake", imageName: "Trail05", description: "Bare spruce trunks rise above the water. They remained after a landslide flooded the valley. A short approach through the forest leads to the shore."),
        .init(title: "Song-Kul", imageName: "Trail06", description: "The lake lies on a broad plateau. In summer, horses graze among the yurts. The open shore offers long views across the water."),
        .init(title: "Jeti-Oguz", imageName: "Trail07", description: "A group of red cliffs marks the entrance to the valley. The rock contrasts with the grass on the lower slopes. A track follows the valley beyond the formations."),
        .init(title: "Skazka Canyon", imageName: "Trail08", description: "Eroded clay forms narrow ridges and little gullies. The colors range from yellow to deep red. A higher viewpoint looks back toward Issyk-Kul."),
        .init(title: "Iskanderkul", imageName: "Trail09", description: "Steep mountains ring this lake in the Fann range. A path from the outlet leads toward a waterfall. The lake is calmest in the early morning."),
        .init(title: "Seven Lakes of the Fann Mountains", imageName: "Trail10", description: "The lakes follow one another up the valley. Each basin has a different color and shape. The climb between villages gives a clear sense of their changing elevation.")
    ]
    private var currentIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        showRandomFavorite()
    }

    @IBAction private func spin(_ sender: UIButton) {
        showRandomFavorite()
    }

    private func showRandomFavorite() {
        let choices = favorites.indices.filter { $0 != currentIndex }
        guard let index = choices.randomElement() else { return }
        currentIndex = index
        let favorite = favorites[index]
        artwork.image = UIImage(named: favorite.imageName)
        titleLabel.text = favorite.title
        descriptionLabel.text = favorite.description
    }
}
