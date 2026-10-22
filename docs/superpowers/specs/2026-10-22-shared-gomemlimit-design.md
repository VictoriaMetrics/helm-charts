# Shared, opt-in GOMEMLIMIT for vmagent and vmstorage

**Status:** Approved, 2026-10-22

## Goal

Use one implementation of exact Kubernetes memory-quantity parsing and GOMEMLIMIT calculation for vmagent and vmstorage. Keep automatic injection opt-in, while allowing operators to configure the percentage of the container memory limit used as the Go runtime memory target.

## Design

Move the existing overflow-safe calculation and memory quantity parser into `victoria-metrics-common` as shared Helm template helpers. The public helper accepts a memory quantity and an integer percentage, validates the percentage is in the range 1–100, and returns the floored result in MiB. Retain exact integer arithmetic, including handling for large mantissas and quantities at MiB boundaries.

The common chart is versioned as 0.4.4. In this one-PR change, vmagent and vmstorage reference the sibling library chart with `file://../victoria-metrics-common`; update both consumer `Chart.lock` files to match the local 0.4.4 dependency. Helm packages hard dependencies inside application chart archives, and the source checkout contains the sibling library, so release packaging does not depend on publication order or an already-published OCI artifact.

Add `goMemLimitPercent: 85` beside each chart's `useGOMEMLIMIT` setting: at the root of vmagent values and under `vmstorage` for the cluster chart. The value must be an integer from 1 to 100; reject fractional and out-of-range values. Set both `useGOMEMLIMIT` defaults to `false`. When enabled, each chart calls the same common helper with its effective memory limit and configured percentage.

## Rendering behavior

- When `useGOMEMLIMIT` is false, do not inject an automatic `GOMEMLIMIT`.
- When enabled and a memory limit is present, calculate `floor(memoryBytes * percent / (100 * 1MiB))` and render the result with the `MiB` suffix.
- Preserve an explicitly configured `env.GOMEMLIMIT` and do not inject an automatic value when `envFrom` is non-empty, since its keys are not visible to Helm.
- If no memory limit is configured, do not inject `GOMEMLIMIT`.
- Reject invalid percentages and invalid memory quantities when automatic calculation is requested. Reject computed results below 1MiB.

## Validation

Update chart unit tests so tests expecting automatic injection opt in explicitly. Cover default-off behavior, explicit environment precedence, `envFrom`, missing limits, the 85% default, a non-default percentage, percentage bounds, invalid quantities, the existing MiB-boundary case, and the large scaled-mantissa case for both charts. Run Helm unit tests and chart lint/template checks for vmagent and vmstorage, then verify release packaging resolves and bundles the local common library.

## Scope boundaries

Only vmagent and vmstorage receive the opt-in setting in this change. Other VictoriaMetrics components, runtime Go behavior, and non-GOMEMLIMIT resource settings remain unchanged.
