---
allowed-tools: Bash(git commit:*), Bash(git log:*), Bash(git diff:*), Bash(git add:*), Bash(git status:*), Bash(git config:*)
description: Commit changes in the current working tree
---

Commit all changes in the current working tree.

- Git status: !`git status`
- Git log: !`git log --oneline -n 10`
- Git diff: !`git diff --compact-summary`
- Check for pre-commit hook: !`git config --get core.hooksPath`

If you have implemented a feature or updated code, commit only the relevant changes. If you have not made any specific changes, group and commit all changes in the working tree by their content.

Action steps:
- Stage only files relevant to your current updates, or group by feature if no specific feature was implemented.
- Commit the staged changes.
- If a pre-commit hook exists, ensure it passes, then commit again if needed.

What to commit and what to ignore:
- Include all modified or added files relevant to your current updates.
- Exclude files unrelated to your current updates. If you have not implemented a specific feature in this session, commit all changes in the working tree.
- Unstage and ignore unrelated files instead of resetting them.

Commit message guidelines:
- Use a conventional commit message, starting with an imperative verb and optional scope, e.g., `feat(ui): add login form` or `test: remove failed server test`.
- Use `chore` for maintenance, `refactor` for code changes that are not bug fixes or features, etc.
- For multiple independent changes, commit them separately.
- Keep commit messages in one line. Do NOT add description or bullet points to the commit message.
- Do NOT add "Generated with Claude Code\n\nCo-Authored-By: Claude noreply@anthropic.com" to the commit message.

Note:
- If you know which files to commit, you can run all add and commit commands together.