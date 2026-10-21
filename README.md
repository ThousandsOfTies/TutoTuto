# TutoTuto

**English** | [日本語](README.ja.md)

**Study first. Scroll later.**

TutoTuto is a learning app that connects worksheet practice with time for social media. Import a PDF or saved image, write your answers, and review AI feedback. After grading, open a social media link you have set up and keep track of time with the timer.

[Open TutoTuto](https://thousandsofties.github.io/TutoTuto/) · [Usage guide (Japanese)](USAGE.md)

## Introduction video

45 seconds · English · Music, no narration

https://github.com/user-attachments/assets/643d1f95-01b8-4056-b9c9-1ce8acca30cf

[Try TutoTuto in your browser](https://thousandsofties.github.io/TutoTuto/)

## Features

- **Use your own materials:** import PDFs and saved image files. To use a paper handout, take a photo with your phone or tablet's camera app, save it, and import the image. TutoTuto does not take photos itself.
- **Write on your worksheets:** use handwriting or text input, switch between A/B pages, and work with a split view.
- **Check answers with AI:** select the area containing the question and your answer, then review correctness and explanations.
- **Ask follow-up questions:** ask about an explanation, branch a conversation, and revisit saved history. Markdown and mathematical notation are supported.
- **Move from study to social time:** open configured social media links after grading and follow the countdown timer. The timer tracks time; it does not block other apps on your device.
- **Choose your language:** the app supports English and Japanese, Google sign-in, and paid-plan integration.

Materials, annotations, grading history, and follow-up questions are stored in your browser's IndexedDB database, `TutoTutoDB`. Clearing site data removes these records. AI grading requires an internet connection.

## Repository structure

This repository pins its dependencies as Git submodules and manages the frontend build and deployment.

| Location | Role |
|---|---|
| `repos/tutotuto-app` | TutoTuto frontend |
| `repos/home-teacher-api` | Express API shared by TutoTuto and DoriDori |
| `repos/home-teacher-common` | Shared UI, PDF display, storage, and authentication |
| `repos/drawing-common` | Drawing infrastructure |

The API source and deployment are maintained in the separate [home-teacher-api](https://github.com/ThousandsOfTies/home-teacher-api) repository.
DoriDori's text indexing and reading features and CopiCopi's drawing evaluation are maintained in their respective apps.

## Local development

Use Node.js 20, matching the frontend CI, along with npm and Git. The Make commands require GNU Make and a Unix-like shell.

```bash
git clone --recurse-submodules https://github.com/ThousandsOfTies/TutoTuto.git
cd TutoTuto
make setup
```

Set `VITE_FIREBASE_*` and `VITE_API_URL=http://localhost:3003` in `repos/tutotuto-app/.env.local`.
Create `repos/home-teacher-api/.env` using the API's [example configuration](https://github.com/ThousandsOfTies/home-teacher-api/blob/main/.env.example). Keep API keys on the server. Do not append `/api` to the API base URL.

Start the frontend and API in separate terminals:

```bash
make dev         # Frontend: http://localhost:3000
make dev-server  # Shared API: http://localhost:3003
```

Without Make, run `npm install` in the drawing, shared UI, and app submodules, run `npm ci` in the API submodule, and run `npm run build` in the drawing submodule.
Then run `npm run dev:all` in the app submodule to start both services. When started through the app, the API also reads the legacy app `server/.env` for compatibility. If PowerShell blocks `npm.ps1`, use `npm.cmd`.

Run `make build` to build the frontend. In the app submodule, use `npm run typecheck` and `npm test`, followed by `npm run test:bundle` after a build. Run the API's `npm test` in the API submodule.

## Updates and deployment

Commit and push changes to each affected submodule before updating its gitlink in this repository. See [AGENTS.md (Japanese)](AGENTS.md) for the workflow and translation rules.
`make init` restores pinned commits; `make update` advances submodules to their configured tracking branches. To validate a new submodule commit before updating its gitlink, run checks directly in that submodule.

Pushing to this repository's `main` branch deploys the frontend to GitHub Pages. The shared Cloud Run API is deployed separately from the API repository.
The pinned submodule commits and the production API version are managed separately. See the [frontend deployment guide (Japanese)](.agent/workflows/deployment.md) and [API deployment guide](https://github.com/ThousandsOfTies/home-teacher-api/blob/main/DEPLOYMENT.md).
