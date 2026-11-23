---
name: homelab
description: >-
  Manage Konrad's homelab (box, HP, Pi): Proxmox cluster topology, OpenTofu/Ansible
  guests, and doco-cd, SOPS and Caddy deploys. Use for its operations and migrations.
---

# Homelab

Everything lives in the services repo: `git.guzek.uk/kguzek/services`, branch `main` only,
cloned on mav at `~/repos/infra/services`. Read its READMEs (`ansible/`, `tofu/`,
`tofu/cloudflare/`) and `ansible/TODO.md` before changing anything; they are the source of truth
where this skill is vague.

## Service placement

Provision new and migrated services on box and HP in Proxmox LXC containers.
Install packaged services directly in their LXC when practical. For services
that require Docker, run Docker inside the LXC, including Forgejo Actions
runners. Create a QEMU/KVM VM only when Konrad explicitly requests one.

## Topology

Two sites joined by WireGuard (`10.1.7.0/24`). Both LANs are `192.168.0.0/24`, so the other site
is reached by its VPN address. Hosts and addresses are in `ansible/group_vars/all.yaml`
(`network_hosts`). Refer to hp as HP, never as "legacy".

| Host | Site            | LAN           | VPN      | Role                                                                     |
| ---- | --------------- | ------------- | -------- | ------------------------------------------------------------------------ |
| box  | Gliwice         | 192.168.0.227 | 10.1.7.2 | Proxmox VE 9.2, most services (Docker per LXC), PBS, GTX 1060            |
| hp   | Wrocław (T17)   | 192.168.0.224 | 10.1.7.7 | Proxmox VE 9.2, WireGuard hub (10.1.7.1), Tang, native-service LXCs      |
| pi   | Gliwice         | 192.168.0.217 | 10.1.7.4 | Raspbian 13: corosync qnetd, pihole, Tang (box's unlock), monitoring, VPN Caddy (10.1.7.11), internet exit for 10.1.7.192/26 |
| rig  | Wrocław (T17)   | 192.168.0.17  | 10.1.7.9 | desktop, not managed by Ansible                                          |
| mav  | —               | —             | —        | the user's MacBook, the controller for OpenTofu and Ansible              |

- box and hp form the Proxmox cluster `homelab`, with pi as the qdevice. Guest IDs are unique
  across the cluster. One API endpoint, `https://proxmox.box.guzek.uk/` (VPN only), covers both nodes.
- Root SSH works on box and hp (`root@box.vpn.guzek.uk`, `root@hp.vpn.guzek.uk`); pi is `konrad@`
  with passwordless sudo. `s <host>` (scripts repo, `common/s`) tries `.lan`, `.vpn`, then `ssh-<host>`.
- box's VPN peer NETMAPs `10.1.7.100–199` to `192.168.0.100–199`, so VPN clients reach box's LXCs
  at `10.1.7.<id>`.
- Cloudflare tunnels (manage with `cf`, or `tofu/cloudflare` for `wrocław-hp`): `gliwice-box`
  (cloudflared on the box host), `wrocław-hp` (hp host), `gliwice-pi`.
- VPN-only hostnames are site-qualified, `<svc>.<site>.guzek.uk`: the unproxied wildcards
  `*.box.guzek.uk` → 10.1.7.112 (box's Caddy), `*.hp.guzek.uk` → 10.1.7.7, `*.pi.guzek.uk` → 10.1.7.11.

## Disks and unlock

- box: `rpool` (SSD, LUKS `rpool_ssd`) and the `backup` pool (LUKS `backup_crypt`, PBS datastore
  `pbs-box`) unlock with clevis/Tang against pi (`192.168.0.217:7500`); dropbear in the initramfs
  as a fallback. `dpool` (8 TB HDD) uses ZFS native encryption, unlocked by `dpool-unlock.service`.
- hp: `rpool` (LUKS) unlocks manually over dropbear in the initramfs, deliberately without clevis.
  `dpool` (1 TB SSD, LUKS) unlocks with a keyfile from the encrypted root.
- Storage IDs on both nodes: `local-zfs` (rpool), `dpool`, `pbs-box`. Guest backups: one nightly
  cluster job at 02:00 to `pbs-box` (`ansible/group_vars/pve.yaml`); box's host backup
  (`pve-host-backup`) at 02:30.
- Boot-critical config on box (crypttab, clevis, GRUB, udev) is still manual. Never touch it
  without an explicit go-ahead; see `ansible/TODO.md`.

## Who manages what

| Layer                                  | Tool                                          |
| -------------------------------------- | --------------------------------------------- |
| Host config (pve nodes, pi)            | Ansible, `ansible/site.yaml`, `pi.yaml`       |
| Guests (containers themselves)         | OpenTofu, `tofu/hp.tf`, `tofu/box.tf`         |
| Inside hp's guests (native services)   | Ansible, `ansible/hp-services.yaml`           |
| Inside box's guests (Docker, contexts) | Ansible, `ansible/box-guests.yaml`            |
| Apps on box                            | doco-cd, `.doco-cd.yaml` + `stacks/<app>/`    |
| Cloudflare tunnel and DNS (hp, VPN)    | OpenTofu, `tofu/cloudflare/`                  |

There are no custom wrapper scripts for guests any more; do not reintroduce them.

**OpenTofu.** From `tofu/`: `. ./env.sh` mints a two-hour `root@pam` ticket over SSH (root SSH is
the only credential; `root@pam`, not a token, is needed for bind mounts) and loads the state
passphrase. Then `tofu plan -var-file=hp.tfvars -out=x.tfplan`, review, `tofu apply x.tfplan`.
State is local and encrypted; back it up to `~/.config/opentofu/backups/` before each apply.
Guests have `prevent_destroy`.

**Ansible.** Always `--check --diff` first, and adopt existing state as a zero-diff change. Box's
guests are reached with `pct exec` through box (`community.proxmox.proxmox_pct_remote`), using the
inventory from `tofu output -json box_inventory > box-inventory.json`. A run is slow and loads
box's 6 cores; keep the default 5 forks (more trips sshd's `MaxStartups`).

## box's containers

The container ID is the last octet of its IP (`192.168.0.<id>`). `tofu/box.tf` lists them in
`local.box_guests` (cores, memory, root disk, tags, Proxmox description, mounts, firewall,
`vpn_route`); tv-cam (100, GPU relay) is a separate resource. Template 9000 (`docker-base`) is
being retired: new guests start from the stock Debian 13 template and `docker_guest` sets them up.

Mounts in every app container: `mp0` `/rpool/tools` → `/opt/tools` (ro: tools, Neovim, root's
dotfiles), `mp1` `/rpool/services` → `/srv/services` (ro: the services clone, pulled every minute
by `services-sync` on the host), `mp2`+ data volumes. doco-cd (110) has only `mp0`.

- New guest: add an entry with a free ID, plan/apply, regenerate the inventory, run
  `box-guests.yaml` (Docker, VPN route, doco-cd's key, pinned host key and Docker context), then add
  the stack.
- New volume: add `{ volume = "local-zfs" | "dpool", path = …, size = "10G" }` (`backup = false`
  for re-downloadable data). Existing volumes are named in full (`local-zfs:subvol-111-disk-1`).
- Removing a guest destroys its volumes: back it up (`vzdump <id> --storage pbs-box`), drop
  `prevent_destroy` for that apply, then rerun `box-guests.yaml` to drop its context.
- GPU passthrough (immich, jellyfin, tv-cam) uses raw `lxc.*` lines in `/etc/pve/lxc/<id>.conf`
  that the API can't set; they stay outside OpenTofu.

## hp's guests

`caddy-hp` (212), `monitoring-hp` (213), `syncthing-hp` (218), from `tofu/hp.tf`, configured by
`hp-services.yaml` with packaged, native services (no Docker). hp's Caddy serves hp-hosted
hostnames through the `wrocław-hp` tunnel and `*.hp.guzek.uk`.

## Deploying apps on box: doco-cd

- Layout: `.doco-cd.yaml` (one YAML document per stack: `name`, `working_dir: stacks/<app>`,
  `context: <app>`), `stacks/<app>/compose.yaml`, `stacks/<app>/.env` (SOPS), `.sops.yaml`.
- doco-cd runs in 110 and polls `main` every 60 s. It deploys each stack to its context
  (`ssh://root@192.168.0.<id>`), so containers run in the app's own LXC. It manages itself from
  `stacks/doco-cd`. Its secrets live only in 110: `/etc/doco-cd/git-token`, `/etc/doco-cd/age.key`.
- Check a deploy: `docker compose -p doco-cd logs` in 110, `docker ps` in the app LXC, and the
  `cd.doco.deployment.target.sha` label on its containers.

## Rules

**Config files.** Over a remote Docker context, bind-mount sources must exist inside the app LXC.
Mount config **directories** from the services clone, read-only:
`/srv/services/stacks/<app>/config:/etc/<app>:ro`. Never use repo-relative bind mounts, never
mount single files (git replaces files, so a single-file mount keeps the old copy), and never
bake config into images with `COPY`. Config changes arrive through `services-sync` within a
minute, without doco-cd. The app reloads on its own (Caddy `--watch`), or restart it.

**Data.** Use Proxmox volumes (a `mounts` entry in `tofu/box.tf`), never host bind mounts:
volumes are backed up, snapshotted and restored with their container. Databases go on `rpool`,
bulk data on `dpool`.

**Secrets.** App secrets only in SOPS-encrypted `stacks/<app>/.env`; host secrets in
`ansible/{host,group}_vars/*.sops.yaml`. Recipients in `.sops.yaml` are doco-cd's age key
(`age1242qk…`) and mav's (`age1wp0u…`, in `~/Library/Application Support/sops/age/keys.txt`).
Never commit plaintext; check for `ENC[` before staging. Never put Proxmox or root SSH
credentials in the repo, not even encrypted.

**Caddy on box** (112): `stacks/caddy/config/Caddyfile` with `import Caddyfile.*`;
`Caddyfile.vpn` holds VPN-only sites (`import vpn`). `trusted_proxies` = box host
(`192.168.0.227`), Cloudflare DNS challenge, sites listed for both HTTPS and `http://` (tunnel).
`--watch` **stops for good after a syntax error**; fix the file, then `docker restart caddy` in 112.
A public hostname on box needs `cf routes gliwice-box add <host> http://192.168.0.112` and an
explicit DNS record, which takes priority over the `*.guzek.uk` wildcard.

**Working style.**

- Investigate read-only first and report facts with evidence. Ask before changing infrastructure,
  and never push without being asked. Changes to live config should be zero-diff adoptions or
  explicitly approved changes.
- Prefer the tools' own idioms (OpenTofu resources, Ansible modules) over custom scripts.
- `pct exec` runs with a minimal PATH and the `C.UTF-8` locale.
- Prefer simple solutions; the user rejects over-engineering.
