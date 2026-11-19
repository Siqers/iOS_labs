import UIKit

final class FavoritesViewController: UIViewController, UITableViewDataSource {
    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = true
    }

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: false)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showDetail",
              let detail = segue.destination as? DetailViewController,
              let indexPath = tableView.indexPathForSelectedRow else { return }
        detail.item = TrailLibrary.items[indexPath.row]
    }
}
