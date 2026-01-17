# iOS-Debounced-User-Search

Add **user creation TextView** and **debounced search** to the users list using **MVVM architecture**.

---

## Overview

This iOS project enhances the **User List screen** by allowing users to:

- Add new users dynamically to the list
- Search the list efficiently using **debounced search**
- Maintain a clean, modular codebase using **MVVM**

---

## Features

### 1. Add New User
- Added a **TextView** at the top of the user list.
- Users can **enter a new user's name**.
- New users are added **dynamically** to the collection view.

### 2. Debounced Search
- Implemented **debounced search** using `DispatchWorkItem`.
- Reduces unnecessary filtering or API calls while typing.
- Updates the user list **after a short delay** for better performance.

### 3. MVVM Architecture
- Refactored using **Model-View-ViewModel (MVVM)**:
  - **Model:** Represents user data
  - **ViewModel:** Handles adding users and search logic
  - **View:** Updates automatically based on ViewModel
- Improves **code maintainability, readability, and testability**.

---

## Benefits

- Quickly add users without navigating away.
- Efficient and responsive search experience.
- Modular, clean, and testable code.

---

## Testing Video

Here’s a demonstration of the feature in action:

[Click here to watch the demo](https://github.com/user-attachments/assets/f0376bc7-3766-4757-825d-8729a1e94373)
