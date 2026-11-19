import UIKit

final class FavoriteCell: UITableViewCell {
    @IBOutlet private var artwork: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var ratingView: UIStackView!

    func configure(with item: FavoriteItem) {
        artwork.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        for (index, view) in ratingView.arrangedSubviews.enumerated() {
            let symbol = index < item.rating ? "star.fill" : "star"
            (view as? UIImageView)?.image = UIImage(systemName: symbol)
        }
    }
}
