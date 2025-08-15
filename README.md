Purpose

This project sets up a continuous integration and continuous deployment (CI/CD) system for a repository that has:

One monolithic application (Java-based)

Multiple microservices (Node.js, Python, etc.)

The pipeline:

Detects exactly which parts of the code changed.

Runs tests and builds only for those parts.

Deploys only changed services to the correct environment (Development, Staging, Production).

This approach saves time, speeds up feedback, and scales well as the system grows.

Key Concepts
Change Detection

Instead of running the full build for all services every time:

A script checks which files/folders changed in the commit or pull request.

It matches the changed paths with a list of components in a configuration file.

Only the affected components are processed in the pipeline.

This means if you only update the users microservice, the payments service and monolith are ignored in that run.

Build and Test

Each changed component goes through:

Language-specific build & test steps:

Java (monolith) → Maven build and unit tests.

Node.js (users service) → npm install and Jest tests.

Python (payments service) → pip install and PyTest.

Test results are saved in a standard JUnit XML format so they can be viewed in the CI tool’s UI.

If tests fail for any changed component, deployment stops.

Docker Image Creation

For each tested component:

A Docker image is built from its Dockerfile.

The image is pushed to GitHub Container Registry (GHCR).

Images are tagged with a commit SHA (immutable) to ensure traceability.

Deployment with Helm

Deployment is done to Kubernetes using Helm:

A single Helm chart is reused for all components.

Environment-specific values (like replicas, image tag, and secrets) are set via separate config files.

Each environment has its own Kubernetes namespace (app-dev, app-staging, app-prod).

Environment Strategy
Environment	Trigger	Approval	Namespace
Dev	Push to develop	No	app-dev
Staging	Push to main	Yes	app-staging
Prod	Tag v*	Yes	app-prod

Dev: Auto-deploys on pushes to develop.

Staging: Deploys on pushes to main after manual approval.

Production: Deploys only from tagged releases (v1.0.0, v2.1.3, etc.) after manual approval.

Required Secrets

These must be added in GitHub repository settings for the workflow to work:

KUBE_CONFIG_DATA → Base64-encoded kubeconfig for Kubernetes cluster access.

DOCKER_USERNAME and DOCKER_PASSWORD → For authenticating to GHCR.

GHCR_TOKEN → GitHub token with package publishing rights.

Benefits

Scalable → Adding a new microservice only requires adding its folder and configuration entry.

Efficient → Saves CI time by skipping unnecessary builds/tests.

Secure → Uses immutable image tags to prevent “latest” tag drift.

Consistent → Same Helm chart is used for all services with environment-specific overrides.

Typical Workflow

Developer updates code and pushes to develop.

CI detects changes → Builds, tests, and deploys only affected services to dev.

Once tested in dev, changes are merged to main.

Pipeline deploys to staging after approval.

When ready for release, a version tag is created.

Pipeline deploys to production after approval.

/////////////////////////////////////////////

📂 Repository File & Folder Explanations
.github///////////

Purpose: Holds all CI/CD configuration files for GitHub Actions.

>>>> Subfolders:

workflows/ci-cd.yml → The main CI/CD workflow file that orchestrates the entire build, test, and deploy process.

actions/ → Custom composite GitHub Actions that encapsulate repetitive steps:

build-java/ → Runs Maven build and tests for the Java monolith.

build-node/ → Installs dependencies and runs tests for Node.js microservices.

build-python/ → Installs dependencies and runs tests for Python microservices.

docker-build-push/ → Builds Docker images and pushes them to GHCR.

helm-deploy/ → Deploys a service to Kubernetes via Helm.

smoke-test/ → Runs a simple health check after deployment.

ci//////////

Purpose: Contains helper scripts and metadata for selective builds.

Files:

components.yaml → Single source of truth listing each component’s name, type (Java/Node/Python), source path, and Helm chart path.

detect_changes.sh → Script that detects which services or monolith modules changed between commits/branches and passes that list to the workflow.

charts/app/

Purpose: Generic Helm chart used for deploying any component to Kubernetes.

Files:

Chart.yaml → Metadata for the Helm chart (name, version).

values.yaml → Default values shared across environments.

templates////////////:

deployment.yaml → Kubernetes Deployment template parameterized for any service.

service.yaml → Kubernetes Service template to expose the app.

env/////////

Purpose: Stores environment-specific Helm override values.

Files:

values-dev.yaml → Config for the Dev namespace (smaller replicas, lower resources).

values-staging.yaml → Config for the Staging namespace (closer to production settings).

values-prod.yaml → Config for the Production namespace (full capacity, scaling settings).

monolith//////////////////////

Purpose: Contains the Java-based monolithic application.

Files:

pom.xml → Maven configuration (dependencies, plugins, build settings).

Dockerfile → Defines how to containerize the monolith for deployment.

src/ → Source code for the monolith.

services/////////////////////

Purpose: Contains multiple microservices, each in its own folder with independent tech stacks.

Example services:

users/ (Node.js) → Has its own package.json, Dockerfile, src/ code, and tests/.

payments/ (Python) → Has its own pyproject.toml, Dockerfile, app/ code, and tests/.

Root Files

.gitignore → Ignores build artifacts, secrets, and temporary files from Git.

.dockerignore → Ignores unnecessary files from Docker build context to keep images small.

README.md → Project documentation (this file).
