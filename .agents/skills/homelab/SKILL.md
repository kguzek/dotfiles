---
name: homelab
description: >-
  Manage Konrad's homelab (box, HP, Pi): topology, Proxmox LXC scripts, and service
  deployment via doco-cd, SOPS and Caddy. Use for this homelab's operations and migrations.
---

# Homelab

## Topology

box, hp and pi are in Gliwice on the same LAN (`192.168.0.0/24`). WireGuard uses
`10.1.7.0/24`; its server currently runs as a rootless Podman container on hp.
Refer to hp as HP, never as "legacy".

| Host | Site    | LAN           | VPN      | Role                                                                          |
| ---- | ------- | ------------- | -------- | ----------------------------------------------------------------------------- |
| box  | Gliwice | 192.168.0.227 | 10.1.7.2 | Proxmox VE 9.2, target for all services, GTX 1060 (Pascal, NVIDIA 580 branch) |
| pi   | Gliwice | 192.168.0.217 | 10.1.7.4 | Raspbian 13, pihole, status-pi, Tang installed; no Clevis clients use it yet |
| hp   | Gliwice | 192.168.0.224 | 10.1.7.7 | Fedora 44, rootless Podman as `konrad`, WireGuard server, worktrees in `/opt/<svc>` |
| mav  | —       | —             | —        | the user's MacBook; reaches hp via LAN, box via VPN                           |

- SSH: `s <host>` (`~/repos/scripts/common/s`) tries `<host>.lan.guzek.uk`, `<host>.vpn.guzek.uk`,
  then `ssh-<host>.guzek.uk`. On box use `s root@box`. `sudo` on hp needs a password.
- Cloudflare tunnels (manage with `cf`): `wrocław-hp` serves `*.guzek.uk` and other domains via
  hp's root-podman Caddy; `gliwice-box` (cloudflared on the box host) and `gliwice-pi`.
  VPN-only hostnames resolve to `hp.vpn.guzek.uk` today.
- Keep hp and box unclustered. For future cross-site resilience, use PBS sync and restore;
  do not run corosync over a WAN.
- Manage existing stacks on hp with `podman compose` as `konrad`, from their worktrees in
  `/opt/<svc>`. Do not use `systemctl` or `podman-compose@` units to manage these stacks.

## box storage and containers

- `rpool` (SSD, Proxmox storage `local-zfs`): root disks, databases, `rpool/tools`, `rpool/services`.
- `dpool` (8 TB HDD, storage `dpool`): bulk data. Empty so far.
- `backup` pool: PBS datastore, storage `pbs-box`, about 770 GB, client-side encrypted.
- Unencrypted for now; the system disk will later be reinstalled as Debian + LUKS (clevis/Tang) + Proxmox.

| ID   | Name                                | IP   |
| ---- | ----------------------------------- | ---- |
| 9000 | docker-base (template)              | DHCP |
| 100  | tv-cam (not managed by the scripts) | .100 |
| 110  | doco-cd                             | .110 |
| 111  | umami                               | .111 |
| 112  | caddy                               | .112 |

The container ID is the last octet of its IP (100–254). Mount point layout in every app container:
`mp0` tools (`/rpool/tools` → `/opt/tools`, ro), `mp1` services clone (`/rpool/services` →
`/srv/services`, ro), `mp2`+ data volumes.

Template 9000: Debian 13 with Docker, root shell zsh, `timezone: host`, `machine-id` set to
`uninitialized` (clones regenerate SSH host keys via `sshd-keygen.service`), doco-cd's public key
in root's `authorized_keys`. It must not have bind mounts, because `pct clone` refuses them. To
change it, edit `/rpool/data/basevol-9000-disk-0` from the host, then recreate `@__base__`.

## Scripts (run on box as root)

They live in `~/repos/personal/scripts/box` (on box: `/rpool/tools/config/scripts/box`, on PATH).
Every script has `--help` and `-d/--dry-run`. Dry-run first; after any change, show the real result.

```bash
lxc-new [-m MB] [-c N] [-s GB] [-v POOL:PATH[:GB][:nobackup]]... [-N] [-n] NAME ID
lxc-volume CONTAINER POOL:PATH[:GB][:nobackup]    # POOL: rpool | dpool, default 10 GB
lxc-context [-r] CONTAINER                         # Docker context in doco-cd, pins SSH host key
lxc-remove [-B] [-y] CONTAINER                     # vzdump to pbs-box, then destroy with volumes
services-sync                                      # systemd timer, pulls /rpool/services every minute
```

- `lxc-new` clones 9000, sets the IP and the tools and services mounts, adds volumes, starts the
  container, waits for SSH and registers the context. `-N` skips the context (only for doco-cd itself).
- `lxc-remove` refuses 9000 and 110. Do not call it `lxc-destroy`: that name is LXC's own tool on Proxmox.
- Settings live in `.lxc-defaults`. Zsh completions in dotfiles read options from `--help`.

## Deploying: doco-cd and the services repo

- Repo `git.guzek.uk/kguzek/services`, branch `main` only. Clone on mav: `~/repos/infra/services`
  (single-branch). The old per-service branches and hp's `~/repos/services` are legacy and contain
  plaintext secrets in history.
- Layout: `.doco-cd.yaml` (one YAML document per stack: `name`, `working_dir: stacks/<app>`,
  `context: <app>`), `stacks/<app>/compose.yaml`, `stacks/<app>/.env` (SOPS), `.sops.yaml`.
- doco-cd runs in 110 and polls `main` every 60 s. It deploys each stack to its context
  (`ssh://root@192.168.0.<id>`), so containers run in the app's own LXC. It manages itself from
  `stacks/doco-cd` (self-update, image pinned by tag and digest). Its secrets live only in 110:
  `/etc/doco-cd/git-token`, `/etc/doco-cd/age.key`. Bootstrap after rebuilding 110:
  `docker run … apply-self --bootstrap` (see `stacks/doco-cd`).
- Check a deploy: `docker compose -p doco-cd logs` in 110, `docker ps` in the app LXC, and the
  `cd.doco.deployment.target.sha` label on its containers.

## Rules

**Config files.** Over a remote Docker context, bind-mount sources must exist inside the app LXC.
Mount config **directories** from the services clone, read-only:
`/srv/services/stacks/<app>/config:/etc/<app>:ro`. Never use repo-relative bind mounts, never
mount single files (git replaces files, so a single-file mount keeps the old copy), and never
bake config into images with `COPY`. Config changes arrive through `services-sync` within a
minute, without doco-cd. The app reloads on its own (Caddy `--watch`), or restart it.

**Data.** Use Proxmox volumes via `lxc-volume`, never host bind mounts: volumes are backed up,
snapshotted and restored with their container. Databases go on `rpool`, bulk data on `dpool`;
re-downloadable data gets `:nobackup`. Remember that destroying a container destroys its volumes.

**Secrets.** Only in SOPS-encrypted `stacks/<app>/.env`. Recipients in `.sops.yaml` are
doco-cd's age key (`age1242qk…`) and mav's (`age1wp0u…`, in
`~/Library/Application Support/sops/age/keys.txt`). Never commit plaintext. Check for `ENC[`
before staging. Write secret files with `umask 077`. Keep tokens out of cloned repos.

**Caddy.** box's Caddy (112) serves only box-hosted services; hp has its own Caddy:
`stacks/caddy/config/Caddyfile` with `import Caddyfile.*`, `trusted_proxies` = box host
(`192.168.0.227`), Cloudflare DNS challenge, sites listed for both HTTPS and `http://` (tunnel).
`--watch` reloads imported files too, but **stops for good after a syntax error**; fix the file,
then `docker restart caddy` in 112. Moving a hostname to box: add
`cf routes gliwice-box add <host> http://192.168.0.112` and an explicit DNS record to the box
tunnel, which takes priority over the `*.guzek.uk` wildcard.

**Migrating a service from hp.**

1. Write `stacks/<app>/` and a `.doco-cd.yaml` entry.
2. Run `lxc-new` with volumes, then push.
3. Copy the data: stop the app on hp, stream `pg_dump -Fc` into `pg_restore` with plain
   `ssh -T hp.lan.guzek.uk … | ssh -T root@box.vpn.guzek.uk …`. Never pipe data through `s`:
   it prints status lines to stdout and forces a TTY. Compare row counts.
4. Cut over the hostname.
5. Bring down the old stack on hp with `cd /opt/<app> && podman compose down` as `konrad`,
   without removing volumes, and keep its data for a few days.

**Working style.**

- Investigate read-only first and report facts with evidence. Ask before changing infrastructure,
  and never push without being asked.
- Write commands and scripts in the existing style: zsh, `zparseopts`, `log-status`, `--help`,
  no filler comments, units next to scripts with install notes in the header.
- `pct exec` runs with a minimal PATH and the `C.UTF-8` locale.
- Prefer simple solutions; the user rejects over-engineering.
