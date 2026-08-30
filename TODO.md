# TODO

## phase-03 needs a from-scratch Linux run

Verified against a fake `HOME` on macOS only (task 6, and again during the
2026-08-30 overhaul). A from-scratch `./install.sh` on a clean Linux machine,
run twice for idempotence, still needs doing on the server replacing tars, and
that run is also the first time `ensure_ai_repo` actually performs its clone.
Every other path through it has been exercised; the clone itself has not.
