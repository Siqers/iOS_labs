import UIKit

final class FavoritesViewController: UIViewController, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TrailLibrary.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? FavoriteCell else {
            preconditionFailure("Connect the FavoriteCell prototype in Main.storyboard.")
        }
        cell.configure(with: TrailLibrary.items[indexPath.row])
        return cell
    }
}
