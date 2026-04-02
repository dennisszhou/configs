# configs

# vimscript helpt
https://devhints.io/vimscript

## Codex Superpowers

This repo can install a curated subset of your `superpowers` fork for Codex from the `vendor/superpowers` submodule.

- Curated skills are listed in `codex/superpowers.manifest`
- Installed skills are exposed under `~/.agents/skills/superpowers/`
- Re-run `./configure.sh codex` after changing the manifest or updating the submodule
- Check for upstream drift with `sh codex/check-superpowers-manifest.sh`
