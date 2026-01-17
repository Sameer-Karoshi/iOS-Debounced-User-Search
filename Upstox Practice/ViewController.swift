import UIKit


final class ViewController: UIViewController {
    
    // MARK: - Constants
    
    private static let viewControleTitle = "Users List"

    // MARK: - Properties

    private let viewModel = ViewModel()
    private let cellIdentifier = "Cell"

    // MARK: - UI

    private lazy var inputTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.layer.cornerRadius = 8
        tv.font = .systemFont(ofSize: 16)
        tv.backgroundColor = .white
        return tv
    }()

    private lazy var addButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add User", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 20
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        btn.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return btn
    }()

    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search users"
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.backgroundColor = .systemPink
        sb.delegate = self
        sb.barTintColor = .systemPink
        return sb
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tv.layer.cornerRadius = 8
        return tv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
        title = Self.viewControleTitle

        setupLayout()
        bindViewModel()
    }

    // MARK: - Binding

    private func bindViewModel() {

        viewModel.onUserInserted = { [weak self] index in
            guard let self else { return }
            let indexPath = IndexPath(row: index, section: 0)
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }

        viewModel.onUserUpdated = { [weak self] index in
            guard let self else { return }
            let indexPath = IndexPath(row: index, section: 0)
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }

        viewModel.onSearchUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(inputTextView)
        view.addSubview(addButton)
        view.addSubview(searchBar)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            inputTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            inputTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            inputTextView.heightAnchor.constraint(equalToConstant: 80),

            addButton.topAnchor.constraint(equalTo: inputTextView.bottomAnchor, constant: 16),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            searchBar.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Actions

    @objc private func didTapButton() {
        let text = inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        viewModel.addUser(firstName: text, lastName: text)
        inputTextView.text = ""
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier,
            for: indexPath
        )

        let user = viewModel.user(at: indexPath.row)
        cell.textLabel?.text = "\(user.firstName) \(user.lastName)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let user = viewModel.user(at: indexPath.row)

        let alert = UIAlertController(title: "Edit User", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.text = user.firstName }
        alert.addTextField { $0.text = user.lastName }

        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard
                let first = alert.textFields?[0].text?.trimmingCharacters(in: .whitespaces),
                let last = alert.textFields?[1].text?.trimmingCharacters(in: .whitespaces),
                !first.isEmpty,
                !last.isEmpty
            else { return }

            self.viewModel.updateUser(at: indexPath.row, firstName: first, lastName: last)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.debounceSearch(text: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        viewModel.debounceSearch(text: "")
        searchBar.resignFirstResponder()
    }
}
