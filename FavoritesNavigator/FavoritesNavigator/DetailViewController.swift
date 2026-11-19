import UIKit

final class DetailViewController: UIViewController {
    var item: FavoriteItem?

    @IBOutlet private var artwork: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var ratingView: UIStackView!
    @IBOutlet private var descriptionLabel: UILabel!

    private func configureLabels() {
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure proper wrapping width for multiline labels to avoid overlap
        titleLabel.preferredMaxLayoutWidth = titleLabel.bounds.width
        subtitleLabel.preferredMaxLayoutWidth = subtitleLabel.bounds.width
        descriptionLabel.preferredMaxLayoutWidth = descriptionLabel.bounds.width
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLabels()
        guard let item else { return }
        navigationItem.title = item.title
        artwork.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        descriptionLabel.text = item.description
        for (index, view) in ratingView.arrangedSubviews.enumerated() {
            let symbol = index < item.rating ? "star.fill" : "star"
            (view as? UIImageView)?.image = UIImage(systemName: symbol)
        }
    }
}
