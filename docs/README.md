# docs/

| File | What it is |
|---|---|
| `report.pdf` | The 3-page project report — **this is what you submit** |
| `report.html` | Its source |
| `build-report.sh` | Regenerates the PDF and fails if it is not exactly 3 pages |
| `screenshots/` | The 6 images the report embeds |

## Replacing the screenshots

`screenshots/` currently holds numbered placeholders. Take each real screenshot,
save it over the placeholder **keeping the exact filename**, then rebuild:

```bash
./docs/build-report.sh
```

| File | What to capture |
|---|---|
| `02-jenkins-pipeline-success.png` | Stage view / Blue Ocean, all six stages green, build number visible |
| `03-jenkins-tests-passed.png` | The build's **Test Result** page — 14 tests, 0 failures |
| `04-docker-compose-terminal.png` | `docker compose ps` — `calculator Up (healthy)`, `calc-nginx` on `:80` |
| `05-local-testing.png` | `curl` against each endpoint plus the HTTP 400 divide-by-zero |
| `06-dockerhub-latest-tag.png` | Docker Hub repo page showing `latest` and the build-number tag |
| `07-email-notification.png` | The Jenkins SUCCESS mail in your inbox |

Any aspect ratio works — the CSS uses `object-fit: contain`, so images are
letterboxed into a fixed box rather than stretched or breaking the page count.
Crop tightly: a full-screen 16:9 grab letterboxed into the box renders small.

The architecture of the whole pipeline (Figure 1) is a vector diagram drawn in
the HTML, not a screenshot — it stays sharp at print resolution.

## Editing the text

One `.page` div per printed page. **Always re-run `build-report.sh`** after an
edit; it refuses to pass if the page count drifts off 3.
