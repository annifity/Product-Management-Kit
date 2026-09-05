# Design System Binding: {{TITLE}}

## Identity

- Design-system ID:
- Version:
- Status: accepted / provisional / none
- Authoritative source: `{{DESIGN_AUTHORITY_SOURCE}}`
- Bound design ID: `{{DESIGN_ID}}`
- Approved by / date:

## Primitives

Raw, non-semantic values only. Reference these from the semantic tokens in Foundations; never bind a component directly to a primitive.

| Primitive Token | Raw Value | Category | Source |
|---|---|---|---|
| [e.g. color-blue-600] | [Raw value, e.g. #2563EB] | Color / Typography / Spacing / Elevation / Motion | [Source] |

## Foundations

Semantic tokens map a primitive to a product-level role (e.g. `color-primary` -> `color-blue-600`). Do not skip this layer by binding a component straight to a primitive.

| Category | Semantic token | Maps to primitive | Status | Source |
|---|---|---|---|---|
| Color | [Role, not raw component color, e.g. color-primary] | [Primitive token] | Accepted / provisional | [Source] |
| Typography | [Families, scale, weights] | [Primitive token] | Accepted / provisional | [Source] |
| Spacing and grid | [Scale and layout rules] | [Primitive token] | Accepted / provisional | [Source] |
| Shape and elevation | [Radius, border, shadow] | [Primitive token] | Accepted / provisional | [Source] |
| Motion | [Purpose, duration, reduced motion] | [Primitive token] | Accepted / provisional | [Source] |

## Components

| Component | Variants | States | Semantic tokens used | Accessibility contract | Source |
|---|---|---|---|---|---|
| [Component] | [Variants] | [States] | [Semantic tokens, e.g. color-primary, spacing-md] | [Keyboard / label / focus] | [Source] |

## Overrides And Gaps

- Page or surface overrides:
- Provisional decisions:
- Deprecated or prohibited patterns:
- Design gap IDs:
