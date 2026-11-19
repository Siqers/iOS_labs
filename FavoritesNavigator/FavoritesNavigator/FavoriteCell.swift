import UIKit

final class FavoriteCell: UITableViewCell {
    @IBOutlet private var artwork: UIImageView!
    @IBOutlet private var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.adjustsFontForContentSizeCategory = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        artwork.image = nil
        titleLabel.text = nil
    }

    func configure(with item: FavoriteItem) {
        artwork.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
    }
}
