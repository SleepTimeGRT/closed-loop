# Evaluation: user-onboarding

Date: 2026-03-29 13:15
Contract: docs/plans/user-onboarding-contract.md
Verdict: **FAIL**
Round: 1/3

## Summary

Must Pass: 3/4
Should Pass: 2/3

## Results

| # | Tier | Item | Result | Note |
|---|------|------|--------|------|
| 1 | Must | Signup → dashboard | PASS | — |
| 2 | Must | Blank email shows error | PASS | — |
| 3 | Must | Duplicate email shows error | FAIL | Blank screen instead of error message |
| 4 | Must | Dashboard shows user name | PASS | — |
| 5 | Should | Signup completes in under 2s | PASS | ~1.2s |
| 6 | Should | Mobile layout at 375px | FAIL | Submit button overflows right edge |
| 7 | Should | Password strength meter | PASS | — |

## Failure details

### FAIL #1: Duplicate email shows error

- **Expected**: An "Email already registered" message appears below the email field.
- **Actual**: The screen goes blank after submission. No error message, no redirect — just a white page.
- **Repro**: Navigate to /signup → enter "test@example.com" (already exists) → click "Sign Up" → blank screen.
- **Console errors**: `POST /api/auth/signup` returned 409 Conflict. The response came back fine, but nothing on the page reacted to it.

### FAIL #2: Mobile layout at 375px

- **Expected**: The entire signup form, including the submit button, fits within the viewport.
- **Actual**: The submit button extends roughly 30% past the right edge. Users would need to scroll horizontally to tap it.
- **Repro**: Resize browser to 375px width → navigate to /signup → scroll to the bottom.
- **Console errors**: None.

## Generator feedback

Two issues blocking a PASS:

1. **Duplicate email handling is missing from the UI.** The server responds with a 409 when the email is taken, but the page doesn't show an error — it just goes blank. The server side looks fine; this is purely about what the user sees after submission.

2. **Submit button overflows on narrow screens.** At 375px, the button is wider than its parent container and clips off the right side. Horizontal scrolling is required to reach it.
