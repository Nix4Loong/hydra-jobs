# Hydra Jobs - Nix Flakes Auto Update

This repository contains GitHub Actions workflows for automatically monitoring and updating Nix flakes.

## 🚀 Features

- **🕐 Scheduled Check**: Automatically checks the `loongson-community/nixpkgs` repository's `loong-master` branch for updates every hour
- **🔍 Smart Detection**: Only executes update operations when new commits are detected
- **📦 Batch Update**: Automatically finds all `flake.nix` files in the repository and updates corresponding `flake.lock` files
- **🤖 Auto Commit**: Automatically commits changes to the repository after updates

## 📁 Project Structure

```
hydra-jobs/
├── .github/
│   ├── workflows/
│   │   └── ci.yml           # Main GitHub Actions workflow
│   └── last-nixpkgs-sha     # Records the last checked commit SHA
├── nixos-images/            # NixOS images related flake
│   ├── flake.nix
│   └── flake.lock
├── nixpkgs/                 # nixpkgs related flake
│   ├── flake.nix
│   └── flake.lock
├── nixpkgs-tarball/         # nixpkgs tarball related flake
│   ├── flake.nix
│   └── flake.lock
└── README.md
```

## ⚙️ Workflow Process

1. **Scheduled Trigger**: GitHub Actions automatically runs every hour (at `:00` minutes)
2. **Check Updates**: Uses `git ls-remote` to check if `loongson-community/nixpkgs@loong-master` has new commits
3. **Compare Status**: Compares current commit SHA with the last recorded SHA
4. **Execute Updates**: If new commits are found:
   - Find all directories containing `flake.nix`
   - Run `nix flake update` in each directory
   - Update corresponding `flake.lock` files
5. **Commit & Push**: Automatically commit all changes and push to repository

## 🔧 Manual Trigger

Besides automatic scheduled runs, you can also manually trigger the workflow:

1. Go to the "Actions" page of your GitHub repository
2. Select the "Auto Update Nix Flakes" workflow
3. Click the "Run workflow" button

## 📊 Monitoring and Logs

Each run generates detailed execution summaries, including:
- Execution time and branch information
- Whether new updates were found
- List of processed flake directories
- Update status and results

## 🛠️ Custom Configuration

### Modify Check Frequency

Edit the cron expression in `.github/workflows/ci.yml`:

```yaml
schedule:
  - cron: '0 * * * *'  # Every hour
  # - cron: '0 */6 * * *'  # Every 6 hours
  # - cron: '0 9 * * 1-5'  # Weekdays at 9 AM
```

### Monitor Different Repository

Modify the repository URL and branch name in the workflow:

```bash
REMOTE_SHA=$(git ls-remote https://github.com/your-org/your-repo.git your-branch | cut -f1)
```

## 📝 Notes

- Ensure the repository has sufficient permissions to push commits
- `flake.nix` files must comply with Nix flakes specifications
- The workflow uses `github-actions[bot]` as the committer
- Last checked SHA is recorded in `.github/last-nixpkgs-sha` file

## 🤝 Contributing

Welcome to submit Issues and Pull Requests to improve this automation system!

## 📄 License

This project is released under the corresponding open source license. 