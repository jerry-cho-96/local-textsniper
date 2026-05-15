## AGENTS.md Usage (CRITICAL)

- Before performing any task, ALWAYS read and follow `AGENTS.md` in the repository root.
- `AGENTS.md` defines the authoritative rules for:
  - architecture
  - layer responsibilities
  - coding conventions
  - testing requirements
  - execution workflow
- If there is any conflict between general knowledge and `AGENTS.md`, ALWAYS follow `AGENTS.md`.
- Never ignore or bypass rules defined in `AGENTS.md`.

---

## Configuration & Secrets

- Do not commit real secrets.
- Use example values for base URLs, tokens, and environment-specific config.
- If environment separation is added, document required keys and setup steps in `README.md`.

---

## Commit & Pull Request Guidelines

- Commit format: Conventional Commits (`<type>: <subject>`). Types: `feat`, `fix`, `docs`, `style`, `refact`, `perf`, `test`, `chore`, `design`.
- Commit language: subject/body in Korean, noun-ended, <= 50 chars. Body uses `-` bullets.
- Multi-line commit body: use one `-m` for subject and one `-m` for the entire body.
- PRs include summary, linked issues, UI screenshots; note config changes (e.g., `.env`, Firebase).

---

## Output Language

- All explanations and responses are in Korean unless explicitly requested otherwise.
