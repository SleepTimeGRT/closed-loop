# Evaluation Result Template

## When passing

```markdown
# Evaluation: {feature-name}

Date: {YYYY-MM-DD HH:mm}
Contract: {path to contract file}
Verdict: **PASS**
Round: {N}/3

## Summary

Must Pass: {passed}/{total}
Should Pass: {passed}/{total}

## Results

| # | Tier | Item | Result |
|---|------|------|--------|
| 1 | Must | {summary} | PASS |
| 2 | Must | {summary} | PASS |
| 3 | Should | {summary} | PASS |
```

## When failing

```markdown
# Evaluation: {feature-name}

Date: {YYYY-MM-DD HH:mm}
Contract: {path to contract file}
Verdict: **FAIL**
Round: {N}/3

## Summary

Must Pass: {passed}/{total}
Should Pass: {passed}/{total}

## Results

| # | Tier | Item | Result | Note |
|---|------|------|--------|------|
| 1 | Must | {summary} | PASS | — |
| 2 | Must | {summary} | FAIL | Expected: {X}, Got: {Y} |
| 3 | Should | {summary} | PASS | — |

## Failure details

### FAIL #1: {item title}

- **Expected**: what the contract says the user should see
- **Actual**: what the user actually saw
- **Repro**: {URL} → {action taken} → {observable result}
- **Console errors**: {captured errors, or "none"}

### FAIL #2: ...

## Generator feedback

Describe what's broken clearly enough that someone can reproduce it without
looking at this eval. Focus on the symptoms — what went wrong and where —
not on how to fix it. That's the Generator's call.
```
