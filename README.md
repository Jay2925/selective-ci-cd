# Selective CI/CD (GitHub Actions) — Monolith + Services

- Builds/tests only changed components (monolith, users, payments)
- Pushes images to GHCR
- Deploys to dev (auto on `develop`), staging (approval on `main`), prod (approval on tag `v*`)
- Uses Helm and namespaces: `app-dev`, `app-staging`, `app-prod`

## One-time setup
1. **Create GitHub Environments**: `dev`, `staging`, `production`  
   - Add `KUBE_CONFIG_DATA` secret to each (base64 of your kubeconfig)
2. **Create namespaces** in your cluster:
