# 📒 Phone Book System – Branch Overview

This project uses structured Git branches for clarity and effective collaboration.

Repository: https://github.com/danieljoshmijares/Phone-Book-System.git

🚀 START HERE - Team Setup

# 1. Clone the repository
git clone https://github.com/danieljoshmijares/Phone-Book-System.git
cd <your-project-folder-location>

# 2. Get dependencies (warnings are NORMAL)
flutter pub get
flutter pub outdated
flutter pub upgrade

# 4. Open in your preferred IDE and run the project


## Core Branches

- master  
  Stable, production-ready code only. All releases are merged here.

- integration  
  All development work and new features are integrated here before being released to master. This is the default branch. 

## NOTE: DO NOT PUSH IN MASTER OR INTEGRATION (unless given permission)

---

## Feature Branches

_Named as `feature/<feature-name>`. These are created from `integration` and merged back when finished._

- feature/basic-crud  
  Implements add, edit, delete, and view operations for contacts.

- feature/search  
  Adds searching capability by name or number.

- feature/storage  
  Integrates persistent storage for contact data (SharedPreferences).

- feature/ui-modernization  
  Modernizes UI: cards, dialogs, themes, icons, logo, etc.

- feature/sort (optional)  
  Adds sorting by name or number, including sort order toggles.

---

## Guidelines

- Branch off from `integration` for features and fixes.
- Use Pull Requests to merge changes, and request reviews when ready.
- Keep each branch focused on a single feature or fix.

---

🔄 Development Workflow
# 1. Get the latest integration branch explicitly
git fetch origin
git checkout -b integration origin/integration
git pull origin integration

# 2. Create your feature branch
git checkout -b <feature/your-feature-name>

# 3. After making changes:
git add .
git commit -m "Describe your changes"

# 4. NOTE: PUSH ONLY YOUR CLEAN FINAL CODE TO THEIR RESPECTIVE REMOTE BRANCH
git push -u origin <feature/remote-feature-name>


Happy coding! 🚀
# Phone-Book-System
For managing and tracking group work.
