//! Right-side status metrics for tmux: CPU, memory, network, disk.
//!
//! Callers are stateless; we stash the previous CPU/net/disk sample so rates
//! are computed as deltas between invocations (no blocking sleep).
//!
//! State is kept per-session (argv[1] = tmux session id) so each session
//! samples against its own previous reading. With one shared file, N sessions
//! refreshing every second would update it ~N times/sec, collapsing dt toward
//! zero and turning the rates into useless instantaneous spikes.

use std::fs;
use std::io::Write;
use std::os::unix::fs::OpenOptionsExt;
use std::path::PathBuf;
use std::time::{SystemTime, UNIX_EPOCH};

use procfs::{Current, CurrentSI};
use serde::{Deserialize, Serialize};

/// One reading of the raw monotonic counters, persisted between invocations.
#[derive(Serialize, Deserialize, Clone, Copy)]
struct Sample {
    /// Total CPU jiffies (busy + idle).
    cpu_total: u64,
    /// Idle CPU jiffies (idle + iowait).
    cpu_idle: u64,
    /// Cumulative bytes received across physical NICs.
    rx: u64,
    /// Cumulative bytes sent across physical NICs.
    tx: u64,
    /// Cumulative sectors read across whole disks.
    dread: u64,
    /// Cumulative sectors written across whole disks.
    dwrite: u64,
    /// Wall-clock time of this sample (unix seconds).
    time: u64,
}

fn main() {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);

    let (cur, wired) = collect(now);

    // Per-session state path. Sanitize the id (tmux session ids look like "$3")
    // and fall back to a shared file only if it is missing/empty.
    let session = std::env::args().nth(1).unwrap_or_default();
    let session: String = session
        .chars()
        .map(|c| {
            if c.is_ascii_alphanumeric() || matches!(c, '_' | '-') {
                c
            } else {
                '_'
            }
        })
        .collect();
    let session = if session.is_empty() {
        "shared".to_string()
    } else {
        session
    };
    let uid = procfs::process::Process::myself()
        .and_then(|p| p.uid())
        .unwrap_or(0);
    // Prefer the per-user runtime dir (0700, private); fall back to TMPDIR then
    // /tmp. The /tmp case is world-writable, so the write below uses O_NOFOLLOW
    // to refuse a symlink someone may have planted at our predictable name.
    let dir = std::env::var("XDG_RUNTIME_DIR")
        .or_else(|_| std::env::var("TMPDIR"))
        .unwrap_or_else(|_| "/tmp".to_string());
    let state: PathBuf = [dir, format!("tmux-status.{uid}.{session}")]
        .iter()
        .collect();

    // Previous sample defaults to the current one => zero deltas on first run.
    let cfg = bincode::config::standard();
    let prev: Sample = fs::read(&state)
        .ok()
        .and_then(|b| bincode::serde::decode_from_slice(&b, cfg).ok())
        .map(|(s, _)| s)
        .unwrap_or(cur);
    if let Ok(bytes) = bincode::serde::encode_to_vec(cur, cfg) {
        let _ = fs::OpenOptions::new()
            .write(true)
            .create(true)
            .truncate(true)
            .custom_flags(libc::O_NOFOLLOW)
            .open(&state)
            .and_then(|mut f| f.write_all(&bytes));
    }

    // dt is at least 1s so a burst of calls can't blow the rates up.
    let dt = (now.saturating_sub(prev.time)).max(1);

    let dcpu_total = cur.cpu_total.saturating_sub(prev.cpu_total);
    let dcpu_idle = cur.cpu_idle.saturating_sub(prev.cpu_idle);
    let cpu = (100 * dcpu_total.saturating_sub(dcpu_idle))
        .checked_div(dcpu_total)
        .unwrap_or(0);

    let (mem_total, mem_avail) = meminfo();
    let mem = (100 * mem_total.saturating_sub(mem_avail))
        .checked_div(mem_total)
        .unwrap_or(0);

    let down = cur.rx.saturating_sub(prev.rx) / dt;
    let up = cur.tx.saturating_sub(prev.tx) / dt;
    // Sectors are 512 bytes.
    let dr = cur.dread.saturating_sub(prev.dread) * 512 / dt;
    let dw = cur.dwrite.saturating_sub(prev.dwrite) * 512 / dt;

    // Nerdfont glyphs.
    let cpu_icon = '\u{f4bc}'; // nf-oct-cpu
    let mem_icon = '\u{f035b}'; // nf-md-memory
    let dsk_icon = '\u{f02ca}'; // nf-md-harddisk
    let eth_icon = '\u{f0200}'; // nf-md-ethernet
    let wifi_icon = '\u{f05a9}'; // nf-md-wifi
    let net_icon = if wired { eth_icon } else { wifi_icon };

    // Colors: glyphs dim, numbers bright. "dim" is the faint attribute (SGR 2)
    // on the terminal default fg, so it recedes against the live background in
    // any theme. The trailing dim of each field carries through the " │ "
    // separators, so glyphs stay dim without re-stating it. See shell.nix.
    let dim = "#[fg=default,dim]";
    let bri = "#[fg=default,nodim]";

    print!(
        "{dim}{cpu_icon} {bri}{cpu:3}{dim}% │ \
         {mem_icon} {bri}{mem:3}{dim}% │ \
         {net_icon} {bri}{down}{dim}↓ {bri}{up}{dim}↑ │ \
         {dsk_icon} {bri}{dr}{dim}R {bri}{dw}{dim}W ",
        down = human(down),
        up = human(up),
        dr = human(dr),
        dw = human(dw),
    );
}

/// Read the current raw counters into a [`Sample`], plus whether any wired NIC
/// has a link up (for the ethernet-vs-wifi glyph).
fn collect(now: u64) -> (Sample, bool) {
    let (cpu_total, cpu_idle) = cpu();
    let (rx, tx, wired) = net();
    let (dread, dwrite) = disk();
    let sample = Sample {
        cpu_total,
        cpu_idle,
        rx,
        tx,
        dread,
        dwrite,
        time: now,
    };
    (sample, wired)
}

/// Aggregate CPU jiffies: (total busy+idle, idle+iowait).
fn cpu() -> (u64, u64) {
    let Ok(stat) = procfs::KernelStats::current() else {
        return (0, 0);
    };
    let t = &stat.total;
    let iowait = t.iowait.unwrap_or(0);
    let total = t.user
        + t.nice
        + t.system
        + t.idle
        + iowait
        + t.irq.unwrap_or(0)
        + t.softirq.unwrap_or(0)
        + t.steal.unwrap_or(0);
    (total, t.idle + iowait)
}

/// Total and available memory in kB.
fn meminfo() -> (u64, u64) {
    let Ok(mi) = procfs::Meminfo::current() else {
        return (0, 0);
    };
    (mi.mem_total, mi.mem_available.unwrap_or(0))
}

/// Sum rx/tx bytes across real physical interfaces, and report whether any
/// wired NIC has a link up.
///
/// Only real NICs have a /sys/class/net/<iface>/device symlink, so this skips
/// lo, docker0, br-*, veth*, virbr*, tun*, etc. Both the traffic totals and the
/// wired-link probe key off the same /proc/net/dev interface list, so we walk it
/// once and stat each interface's /sys entry a single time.
fn net() -> (u64, u64, bool) {
    let Ok(devs) = procfs::net::dev_status() else {
        return (0, 0, false);
    };
    let mut rx = 0;
    let mut tx = 0;
    let mut wired = false;
    for (name, dev) in devs {
        let base = format!("/sys/class/net/{name}");
        // No backing device => virtual interface; skip for traffic and link.
        if fs::symlink_metadata(format!("{base}/device")).is_err() {
            continue;
        }
        rx += dev.recv_bytes;
        tx += dev.sent_bytes;

        if wired {
            continue; // already found a wired link; no need to stat more.
        }
        let wireless = fs::symlink_metadata(format!("{base}/wireless")).is_ok()
            || fs::symlink_metadata(format!("{base}/phy80211")).is_ok();
        let up = fs::read_to_string(format!("{base}/operstate"))
            .map(|s| s.trim() == "up")
            .unwrap_or(false);
        wired = !wireless && up;
    }
    (rx, tx, wired)
}

/// Sum sectors read/written across whole-disk devices only.
///
/// Skip partitions and dm-* (LUKS) so the same bytes aren't counted twice.
fn disk() -> (u64, u64) {
    let Ok(stats) = procfs::diskstats() else {
        return (0, 0);
    };
    let mut dread = 0;
    let mut dwrite = 0;
    for d in stats {
        if !is_whole_disk(&d.name) {
            continue;
        }
        dread += d.sectors_read;
        dwrite += d.sectors_written;
    }
    (dread, dwrite)
}

/// True for whole-disk device names (sda, nvme0n1, mmcblk0, …), not partitions.
fn is_whole_disk(name: &str) -> bool {
    let bytes = name.as_bytes();
    // sd[a-z] / vd[a-z] / xvd[a-z] / hd[a-z]
    let scsi = matches!(
        name.get(..name.len().saturating_sub(1)),
        Some("sd") | Some("vd") | Some("xvd") | Some("hd")
    ) && bytes.last().is_some_and(u8::is_ascii_lowercase);
    // nvme<N>n<M>: controller + namespace, no trailing "pX" partition.
    let nvme = name
        .strip_prefix("nvme")
        .and_then(|s| s.split_once('n')) // ("<N>", "<M>")
        .is_some_and(|(ctrl, ns)| {
            !ctrl.is_empty()
                && ctrl.bytes().all(|b| b.is_ascii_digit())
                && !ns.is_empty()
                && ns.bytes().all(|b| b.is_ascii_digit())
        });
    // mmcblk<N>  (no trailing "pX")
    let mmc =
        name.starts_with("mmcblk") && name["mmcblk".len()..].chars().all(|c| c.is_ascii_digit());
    scsi || nvme || mmc
}

/// Format a byte count as a fixed-width 6-char field so columns don't jitter:
/// e.g. "   66B", "4.00KB", "68.3MB", "1023KB". The unit fills the tail and the
/// decimal places shrink as the integer part grows.
fn human(bytes: u64) -> String {
    const UNITS: [&str; 6] = ["B", "KB", "MB", "GB", "TB", "PB"];
    let mut v = bytes as f64;
    let mut i = 0;
    while v >= 1024.0 && i < UNITS.len() - 1 {
        v /= 1024.0;
        i += 1;
    }
    let unit = UNITS[i];
    let w = 6 - unit.len(); // width left for the number
    if i == 0 {
        return format!("{bytes:>w$}{unit}");
    }
    let idig = (v.trunc() as u64).to_string().len(); // digits before the point
    let dec = (w as i64 - 1 - idig as i64).max(0) as usize; // minus 1 for the dot
    format!("{v:>w$.dec$}{unit}")
}
