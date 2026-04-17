# Interview Exercise

## Overview

This is a Rails API for a to-do list manager. Users can register, authenticate via a token, manage to-do lists, and manage individual to-dos within those lists.

The app has been intentionally written with areas for improvement. Your goal is to identify and discuss them.

**Context:** This is a slice of a mid-sized production app — think a team of 5–10 engineers, years of growth, and real users. The kind of codebase where decisions have lasting consequences and tradeoffs actually matter.

---

## Step 1 — Browse the app (5 minutes)

Take 5 minutes to explore the codebase.

You don't need to read everything in depth. Scan for patterns, smells, or decisions that catch your eye. We're less interested in style nits (naming, formatting) and more in structural or behavioral issues.

We may interrupt you and have you move onto the next observation. This is not negative feedback, we are just looking for more examples of what you have uncovered.

## Step 2 — Discussion (15 minutes)

Walk us through the issues you found and how you would address them. We're interested in your reasoning, not just the list.

Some areas worth thinking about:

- **Design** — are responsibilities in the right place? Is there logic that belongs elsewhere?
- **Duplication** — is any code repeated across models or controllers?
- **Consistency** — is authentication handled the same way throughout the app?
- **Correctness** — are there edge cases or race conditions that could cause bugs?
- **Conventions** — familiarity with rails community best practices or standards.
- **Security** — how are passwords stored and validated? Is anything missing?

There are no trick questions. We want to see how you think through a real codebase and communicate trade-offs.
