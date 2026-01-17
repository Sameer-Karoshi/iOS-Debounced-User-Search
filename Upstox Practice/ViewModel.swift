import UIKit

final class ViewModel {

    private var users: [Model] = []
    private var filteredUsers: [Model] = []
    private var searchWorkItem: DispatchWorkItem?

    var onUserInserted: ((Int) -> Void)?
    var onUserUpdated: ((Int) -> Void)?
    var onSearchUpdated: (() -> Void)?

    init() {
        filteredUsers = users
    }

    // MARK: - Add / Update

    func addUser(firstName: String, lastName: String) {
        let user = Model(firstName: firstName, lastName: lastName)
        users.append(user)
        filteredUsers.append(user)
        onUserInserted?(filteredUsers.count - 1)
    }

    func updateUser(at index: Int, firstName: String, lastName: String) {
        let updated = Model(firstName: firstName, lastName: lastName)

        if let originalIndex = users.firstIndex(where: {
            $0.firstName == filteredUsers[index].firstName &&
            $0.lastName == filteredUsers[index].lastName
        }) {
            users[originalIndex] = updated
        }

        filteredUsers[index] = updated
        onUserUpdated?(index)
    }

    // MARK: - Search (with debounce)

    func debounceSearch(text: String, delay: TimeInterval = 0.5) {
        searchWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.filterUsers(with: text)
        }

        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func filterUsers(with text: String) {
        if text.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter {
                $0.firstName.lowercased().contains(text.lowercased()) ||
                $0.lastName.lowercased().contains(text.lowercased())
            }
        }
        onSearchUpdated?()
    }

    // MARK: - DataSource Helpers

    func numberOfRows() -> Int {
        filteredUsers.count
    }

    func user(at index: Int) -> Model {
        filteredUsers[index]
    }
}

