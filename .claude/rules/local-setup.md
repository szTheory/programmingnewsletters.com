# Local Development Setup

## Docker Setup (Recommended)

Prerequisites: Docker Desktop installed.

```bash
# First time: build image and start (takes a few minutes for CPAN deps)
docker compose up --build

# Visit http://localhost:8000
```

The Docker setup uses `ubuntu:24.04` with system Perl 5.38.2 — matching the Netlify Noble build image. Key details:
- Builds the site with `--rebuild --first-only` on startup (fast, 1 newsletter)
- Source files are volume-mounted — edit on host, rebuild inside container
- CPAN deps persist in a named Docker volume (`carton_deps`)
- Uses `carton install --deployment` for reproducible locked builds

### Common Docker commands

```bash
# Full rebuild (scrapes all newsletters):
docker compose exec dev carton exec perl Run.pm --rebuild

# Quick test build (1 newsletter):
docker compose exec dev carton exec perl Run.pm --rebuild --first-only

# Rebuild static assets only (after editing CSS/JS/template):
docker compose exec dev carton exec perl Run.pm

# Shell into container:
docker compose exec dev bash

# Stop:
docker compose down

# Rebuild image (after Dockerfile changes):
docker compose up --build
```

### Docker architecture notes

- `ubuntu:24.04` base image — matches Netlify Noble 24.04 build environment
- System Perl 5.38.2 (no need for asdf or custom Perl builds)
- `carton install --deployment` — uses locked versions from cpanfile.snapshot
- System deps: `libexpat1-dev` (XML::Parser), `libssl-dev` + `pkg-config` + `zlib1g-dev` (Net::SSLeay/HTTPS), `python3` (dev server), `curl` + `make` + `gcc` (build tools)
- On Apple Silicon Macs, runs natively (ubuntu:24.04 has arm64 images)

## Native Setup (Alternative)

Prerequisites: git, asdf (https://asdf-vm.com/), Python 3.

### 1. Install Perl via asdf

```bash
asdf plugin add perl https://github.com/ouest/asdf-perl.git
asdf install perl 5.38.2
asdf global perl 5.38.2
perl --version  # verify 5.38.2
```

If `perl --version` shows the wrong version, run `source ~/.zshrc` (or `~/.bash_profile`) and retry.

### 2. Install cpanminus

```bash
curl -L https://cpanmin.us > cpanm_setup.pl
perl cpanm_setup.pl App::cpanminus
```

### 3. Install pre-Carton dependencies

```bash
cpanm XML::Parser    # needs libexpat: brew install expat (macOS)
cpanm DateTime
```

### 4. Install Carton and project dependencies

```bash
cpanm Carton
asdf reshim perl   # critical: makes the `carton` command available
carton install --deployment   # installs locked deps from cpanfile.snapshot into local/
```

### 5. Build and verify

```bash
carton exec perl Run.pm --rebuild --first-only
python3 -m http.server --directory public   # localhost:8000
```

## Troubleshooting

- **`carton: command not found`** — run `asdf reshim perl`
- **Build fails with module not found** — run `carton install --deployment`
- **Perl version mismatch** — check `.tool-versions`, run `asdf install perl 5.38.2`
- **cpanm fails on XML::Parser** — `brew install expat` (macOS)
- **Net::SSLeay build failure** — ensure `pkg-config`, `libssl-dev`, `zlib1g-dev` are installed

## Optional: Development Tools

- **REPL:** `cpanm Reply && cpanm Term::ReadLine::Gnu && asdf reshim perl` → run `carton exec reply`
- **Debugger:** Add `$DB::single = 1;` as breakpoint, run `carton exec perl -d Run.pm`
- **VS Code extensions:** Perl (richterger.perl) for language server, perltidy-more for formatting
- **Formatter config:** `~/.perltidyrc` with `-i=2` for 2-space indent
