# Sprint Contract Template

## Format

```markdown
## Sprint Contract: {feature-name}

Date: {YYYY-MM-DD}
Plan: {path to plan file}
App: {URL(s) to test against}

### Must Pass (any failure → FAIL)

- [ ] {user} does {action} and sees {result}
- [ ] When {error condition}, {error message or fallback} is shown
- [ ] End-to-end: {start} → {middle} → {end state} is reachable

### Should Pass (2+ failures → FAIL)

- [ ] {action} completes within {N} seconds
- [ ] Layout holds at {W}px viewport width
- [ ] Edge case: {condition} produces {expected behavior}

### Won't Test (out of scope)

- {reason}: {item}

### Test Data Prerequisites

- {User A}: {role}, {state}
- {Data}: {what needs to exist in the DB}
```

## Worked example

```markdown
## Sprint Contract: user-onboarding

Date: 2026-03-29
Plan: docs/plans/user-onboarding.md
App: http://localhost:3000

### Must Pass

- [ ] A new user fills the signup form, submits, and reaches the dashboard
- [ ] Leaving the email field blank and submitting shows "Please enter your email"
- [ ] Signing up with an already-registered email shows "Email already registered"
- [ ] After logging in, the dashboard greets the user by name

### Should Pass

- [ ] The signup-to-dashboard flow completes in under 2 seconds
- [ ] The signup form renders correctly at 375px width
- [ ] The password strength meter updates as the user types

### Won't Test

- Email delivery: can't verify locally
- Social login: planned for a future sprint
- Screen reader support: dedicated accessibility pass later

### Test Data Prerequisites

- Existing account: test@example.com (for the duplicate-email test)
- Seed data in the users table
```

## Sizing guide

| Tier | Min | Sweet spot | Max |
|------|-----|-----------|-----|
| Must | 3 | 5 | 7 |
| Should | 1 | 3 | 5 |
| Won't Test | 1 | 2 | — |

More than 7 Must items usually means the sprint should be split.
