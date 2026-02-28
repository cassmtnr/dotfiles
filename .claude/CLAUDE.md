# Global Rules

## Critical Safety Rules

These rules apply directly to Claude Code and any AI agent in all contexts. **DO NOT** run any of the following commands. The user will handle these manually.

### Git — NEVER run these:

- `git push` (all variants: --force, --force-with-lease, --mirror, --all, --tags, --prune)
- `git push origin --delete` / `git push origin :<ref>` (deletes remote branches/tags)
- `git pull` (all variants: --rebase, --force)
- `git fetch` (all variants: --all, --prune, --prune-tags)
- `git clone` (all variants: --recursive, --mirror)
- `git add` / `git stage` (do not stage files)
- `git commit` (all variants: --amend, --no-edit, --allow-empty)
- `git merge` (do not merge branches)
- `git rebase` (all variants: interactive, --onto, --root, --autosquash)
- `git reset --hard` / `git reset --merge` / `git reset --keep`
- `git checkout -- .` / `git checkout -f` / `git restore .` / `git restore --staged --worktree .`
- `git clean -f` / `-fd` / `-fdx` / `-fdX` (permanently deletes untracked/ignored files)
- `git stash drop` / `git stash clear` / `git stash pop` (destructive stash operations)
- `git branch -D` (force-deletes branches)
- `git filter-branch` / `git filter-repo` (history rewriting)
- `git reflog expire` / `git gc --prune=now` / `git prune` (removes recovery safety net)
- `git update-ref -d HEAD` / `git symbolic-ref` / `git replace` (ref manipulation)
- `git remote add` / `git remote set-url` / `git remote remove`
- `git submodule add` / `git submodule update`
- `git config --global` / `git config --system`
- `git tag -d` combined with remote push (deletes remote tags)
- Any git command with `--no-verify` (skips safety hooks)

### Destructive system commands — NEVER run these:

- `rm -rf` (especially with `/`, `~`, `.`, `*`)
- `sudo` / `su` / `doas` / `pkexec` (elevated privileges)
- `chmod -R` / `chown -R` on broad paths
- `kill -9 -1` / `killall` / `pkill -9` (mass process killing)
- Disk operations: `dd`, `mkfs`, `fdisk`, `wipefs`, `parted`
- `truncate -s 0` / `> file` / `cat /dev/null > file` (emptying files)
- `crontab -r` (removes all cron jobs)
- Fork bombs or recursive shell constructs

### Publishing and deployment — NEVER run these:

- `npm publish` / `npm unpublish` / `npm deprecate`
- `cargo publish` / `pip upload` / `twine upload` / `gem push` / `pod trunk push`
- `vercel --prod` / `netlify deploy --prod` / `fly deploy` / `firebase deploy`
- `terraform apply` / `terraform destroy` (all variants)
- `pulumi destroy` / `cdktf destroy`
- `kubectl apply` / `kubectl delete` / `kubectl drain` / `kubectl scale --replicas=0`
- `helm install` / `helm uninstall` / `helm upgrade`
- `docker push`
- `heroku` deployment commands / `eb terminate` / `serverless remove`
- `cap production deploy` or any production deployment script
- `aws cloudformation delete-stack` / `gcloud projects delete` / `az group delete`

### Network and infrastructure — NEVER run these:

- `curl -X POST/PUT/DELETE` to external APIs (unless explicitly required by the task)
- `ssh` / `scp` / `rsync --delete` to remote hosts
- `docker rm -f $(docker ps -aq)` / `docker system prune -a` / `docker volume prune`
- `docker-compose down -v` / `docker-compose down --rmi all`
- `iptables -F` / `ufw disable` (firewall manipulation)
- `ifconfig <iface> down` / `route del default` (kills network)

### Database — NEVER run unless explicitly required by the task:

- `DROP DATABASE` / `DROP TABLE` / `TRUNCATE TABLE`
- `DELETE FROM <table> WHERE 1=1` (mass deletion)
- `redis-cli FLUSHALL` / `FLUSHDB`
- `prisma migrate reset` / `rails db:drop` / `rails db:reset` / `django flush`
- `alembic downgrade base`
- `mongosh "db.dropDatabase()"`

### Credentials — NEVER expose:

- Do not print or log `.env`, `credentials.json`, `~/.ssh/`, `~/.aws/`
- Do not expose API keys, tokens, or secrets in output
- Do not run `env` / `printenv` / `history` (may contain secrets)
- Do not run `security find-generic-password` / `gpg --export-secret-keys`

### Package installation safety:

- NEVER run `curl <url> | sh` or `wget <url> | sh` (piped remote scripts)
- NEVER run `npx <unknown-package>` without explicit user instruction
- NEVER run `npm audit fix --force` (can introduce breaking changes)

### Attribution — NEVER add Claude as author or co-author:

- NEVER include `Co-Authored-By`, `Authored-By`, or any similar trailer referencing Claude, Anthropic, or any AI in commit messages, PR descriptions, or any other git metadata
- NEVER set Claude as the git author or committer
- All commits and contributions must be attributed solely to the human user

## Refactoring Discipline

When renaming, moving, or deleting any file, function, variable, path, or config key:

1. **Search for all references before changing** — grep the entire project for the old name/path (filenames, string literals, symlink definitions, config files, scripts, documentation)
2. **Update every reference** — install scripts, symlink arrays, config entries, imports, documentation, READMEs, and comments must all reflect the new name/path
3. **Check for stale artifacts** — if a file was renamed/deleted, verify no orphaned symlinks, build outputs, or cached references to the old name remain
4. **Verify end-to-end** — after the change, confirm the renamed/moved thing actually works from the consumer's perspective (e.g., run the command, check the symlink resolves, test the import)

### What you SHOULD do instead:

- Make changes to files directly
- Run tests and linters
- Run local dev servers if needed for verification
- The user will review and handle git operations manually

