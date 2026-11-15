# ADR 0001: Initial Project Architecture

- **Status:** Accepted
- **Date:** 2026-11-15
- **Decision owners:** Odem Eytam

## Context

DevPlatform is a local-first learning project intended to demonstrate the main building blocks of an Internal Developer Platform: Kubernetes, Infrastructure as Code, CI, GitOps, multi-tenancy, a developer portal, and observability.

The project should be achievable on a Windows 11 development machine with WSL2, Docker Desktop, and limited local resources. It should not require a paid cloud account for its core functionality.

The architecture must also avoid overlapping ownership between infrastructure and deployment tools.

## Decisions

### 1. Use a monorepo initially

Keep infrastructure, Kubernetes configuration, GitOps configuration, services, portal code, and documentation in one repository.

**Reason:** A monorepo reduces initial coordination overhead and makes it easier to understand how the components fit together. Revisit this if independent release cycles or access boundaries later justify multiple repositories.

### 2. Use K3d for the local Kubernetes cluster

Use K3d to create a lightweight local K3s cluster running in Docker.

**Reason:** It supports a multi-node Kubernetes learning environment without requiring several full virtual machines.

**Ownership:** K3d owns cluster creation and deletion. Terraform will not manage K3d cluster lifecycle.

### 3. Use Terraform for selected foundational resources

Use Terraform after the cluster exists to manage explicitly assigned Kubernetes resources, initially namespaces, quotas, LimitRanges, and RBAC foundations.

**Reason:** This provides practical experience with providers, modules, variables, outputs, state, plans, and drift.

**Constraint:** A resource must have one lifecycle owner. Terraform and Argo CD must not both manage the same resource.

### 4. Use Helm for application packaging

Create reusable Helm charts for applications and their configuration.

**Reason:** Helm provides a practical way to parameterize and package Kubernetes applications.

### 5. Use Argo CD for GitOps application delivery

Use Argo CD to reconcile application and selected platform deployment configuration from Git.

**Reason:** GitOps makes the desired state reviewable, repeatable, and recoverable.

**Constraint:** Argo CD will not own Terraform-managed foundational resources.

### 6. Use GitHub Actions for CI

Use GitHub Actions to run tests, validation, image builds, and image publishing.

**Reason:** It integrates directly with the source repository and supports a zero-cost-first workflow for a small public project, subject to current service limits.

**Constraint:** GitHub Actions should not become a competing continuous deployment controller after Argo CD is introduced.

### 7. Use GHCR as the image registry

Publish container images to GitHub Container Registry.

**Reason:** It integrates with GitHub and avoids introducing a separate registry service at the beginning.

### 8. Use FastAPI and React for the developer portal

Use FastAPI for the platform API and workflow orchestration, and React for the frontend.

**Reason:** This creates an opportunity to learn how a platform API and developer-facing experience interact with infrastructure automation.

### 9. Keep the project local-first

Do not make AWS or another paid cloud provider a prerequisite for the initial milestones.

**Reason:** The primary learning objective is Kubernetes and platform engineering, not cloud-provider administration or cloud billing.

## Consequences

### Positive

- The initial setup is relatively lightweight.
- Each major tool has a clear responsibility.
- The project can be developed without mandatory cloud spending.
- The architecture can grow incrementally.
- The repository provides a single place to review implementation and design decisions.

### Trade-offs

- A local K3d cluster does not reproduce every operational property of a production-managed Kubernetes service.
- Some cloud-specific infrastructure patterns will not be covered by the local implementation.
- Terraform's Kubernetes provider can only operate after the cluster is available and reachable.
- Local Terraform state is suitable for learning but is not a production team-state solution.
- A monorepo may eventually need to be split if ownership, permissions, or release requirements become more complex.

## Follow-up decisions

The following should be recorded in separate ADRs when implemented:
- K3d cluster topology and resource allocation.
- Ingress controller and local DNS.
- Terraform state strategy.
- Tenant isolation model.
- GitOps repository layout and promotion strategy.
- Portal authentication and authorization.
- Secrets management.