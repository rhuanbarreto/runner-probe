#!/usr/bin/env bash
set +e
echo "== os"; . /etc/os-release; echo "$PRETTY_NAME"; uname -r; ldd --version | head -1
echo "== virt"; systemd-detect-virt 2>/dev/null; nproc; free -m | sed -n 2p
echo "== user"; id
echo "== sysctls"
for k in kernel.apparmor_restrict_unprivileged_userns kernel.apparmor_restrict_unprivileged_unconfined kernel.unprivileged_userns_clone user.max_user_namespaces kernel.yama.ptrace_scope; do printf '%s = ' $k; sysctl -n $k 2>&1; done
echo "== apparmor"; cat /sys/module/apparmor/parameters/enabled 2>&1; ls /etc/apparmor.d 2>/dev/null | grep -iE 'unshare|userns|bwrap|unprivileged' ; cat /proc/self/attr/current 2>&1
echo "== unshare probe"; unshare --map-root-user --mount --pid --fork bash -c 'id -u; mount --make-rprivate / && echo mount-ok'; echo "exit=$?"
echo "== unshare -r only"; unshare -r true; echo "exit=$?"
echo "== cwd/tmp"; echo "TMPDIR=$TMPDIR RUNNER_TEMP=$RUNNER_TEMP"; df -h /tmp | tail -1
