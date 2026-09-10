# Steering

**What it is.** Steering is what a task must respect and the code cannot show: rules, patterns and
pitfalls. Its shape, how it is read, written and kept, are the [context mechanism](context.md)'s and are
not restated here. This document states what is steering's alone: its three layers, how the map names
them, and the moment it is written.

## Three layers

| Layer | Holds | Loaded for | File | Map key |
|---|---|---|---|---|
| Workspace | What every task in the repository must respect: import boundaries, conventions, stack, architecture | Every task | `steering/workspace.md` | `workspace`, reserved |
| App | What only one app needs: its surface, its flows, its twists on shared topics | A task whose area is that app | `steering/<app>.md` | The app's name |
| Domain | What every consumer of the domain needs | A task touching the domain | `steering/<domain>.md` | The domain's name |

`workspace` is a **reserved key** in the `steering:` map of `project.yml` — never an area, on the same
terms as `default:` inside `review_profile:`. A project that declares no workspace entry is told so in one
line by every run that resolves context, and the line disappears the day the entry exists.

The layers are the mechanism's write questions, read as places: what every task needs is workspace, what
every consumer of a domain needs is the domain, what one app needs is the app, and an app's twist on a
shared topic is a pointer in the app's file to the domain's section. The derived test that catches a rule
in the wrong layer costs nothing: a section title in a domain file that needs an app's name belongs in that
app's file.

In a **single project** the app layer does not exist — the app is the workspace — and the map holds
`workspace` plus domain keys. In a **monorepo** the map holds keys of both kinds, and the directories
resolve them: an `apps/<key>` or `libs/<key>` the task touches makes its entry affected without anyone
judging it. A review profile and a steering file are keyed alike and answer different questions: the
profile says how a stack is judged, the steering says what an area knows.

## How the map names a file

The file convention is `steering/<key>.md`, the key being the project's or the domain's own name. Several
keys may point at one file and the file is read once. One key names one file: the set of files a task
needs is derived from the keys it touches, not kept as a list by hand — a hand-kept list would load a
domain into every task of an app whatever the task touched, and go stale each time the app adopted a
library.

A steering file the map **does not name** is checked all the same. The map answers which file a task
receives; shape belongs to where the file lives. An undeclared file is delivered to nobody and still holds
rules somebody wrote, and a file nothing measures is the drawer everything ends up in.

`pencil-design.md` is reached by the design-session rule and is outside the map; nothing in the mechanism
applies to it and the check does not read it.

## When it is written

Step 1 of the archive checklist asks whether the task taught or changed a rule. The lesson is placed by the
mechanism's write questions, merges into its topic's section, carries its provenance on the rule's line,
and the nano line of that section is rewritten in the same edit. The check is the step's `Verify`. A task
in flight writes no steering; a lesson learned mid-task waits in the task's sheet for the close.

## Who reads it

Consumers state their own use in their own protocols. Understand reads the nano of each affected file and
the sections that intersect the task, and writes the aggregate line. Execute re-reads sections per step.
The review workflow's architecture auditor reads the workspace file, and its security auditor the steering
of the affected area, from the list Verify hands them.
