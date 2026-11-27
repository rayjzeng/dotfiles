# Meta Remote Server

Configure terminal tools without applying laptop or personal Git assumptions.

## Dependencies

Use the detected Linux package manager. On CentOS or RHEL, install `fd-find`
to provide `fd`; on Debian or Ubuntu, account for packages that expose only
`fdfind`. Install the remaining missing core tools: `fzf`, `jq`, `ripgrep`,
`stow`, `tmux`, `vim`, `zoxide`, and `zsh`. Install Starship only when absent.

Verify `fd` explicitly because its package and executable names vary by distro.
Suggest changing the login shell only when zsh is installed and not already the
login shell; never run `chsh` without confirmation.

## Git and SSH

Use `git-homedir-setup` in local-copy mode when Meta settings are present. Keep
the Meta HTTPS GitHub remote and preserve work identity, credential helper,
proxy, certificate, and URL rewrite settings.

Do not perform the GitHub SSH-key workflow, start an SSH agent, or add
`AddKeysToAgent`; these do not support the normal HTTPS workflow on a remote
server.

## Remote-Only Choices

- Skip WezTerm configuration and shell-integration downloads even if a
  WezTerm wrapper or executable is visible remotely.
- Stow the shared `codex` package for status-line tooling.
- Configure zkbd for the host terminal and its tmux/screen variants.
