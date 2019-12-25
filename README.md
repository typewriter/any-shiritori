# any-shiritori

Find the longest shiritori (しりとり) from words

## Usage

```bash
$ echo -e "scp\nls\nps\nssh\ntouch\nsort" | crystal src/any_shiritori.cr
Length: 5
Shiritori: ls => scp => ps => sort => touch
```

```bash
$ crystal src/any_shiritori.cr examples/alpine-3.10.3.txt
Length: 173
Shiritori: whoami => ipcs => strings => setlogcons => setkeycodes => swapoff => fgrep => powertop => pmap => pgrep => pwd => depmod => dd => dc => crontab => brctl => lzma => add-shell => login => nologin => nsenter => rmdir => rm => microcom => md5sum => mkdir => reset => timeout => test => ttysize => ether-wake => env => volname => eject => touch => halt => tr => realpath => hdparm => modinfo => openvt => truncate => expr => raidautorun => nl => logger => rfkill => lzopcat => tunctl => lzcat => tail => ln => nmeter => remove-shell => lsusb => bc => chown => nproc => comm => mpstat => tac => crond => dnsdomainname => expand => dirname => ed => deluser => rmmod => date => echo => od => deallocvt => tar => readahead => dumpkmap => passwd => delgroup => ping => gzip => patch => hexdump => pkill => lzop => printenv => vconfig => gunzip => pwdx => xzcat => top => pscan => nc => cksum => mkpasswd => du => unlzma => arping => getopt => true => egrep => printf => fsync => cal => lsof => fdflush => hostid => diff => fbsplash => head => df => fstrim => mesg => getconf => fsck => killall => losetup => poweroff => flock => klogd => dmesg => grep => pidof => findfs => sysctl => ls => setserial => less => sum => mkmntdirs => sha512sum => mkdosfs => su => unix2dos => sync => clear => run-parts => slattach => hd => dumpleases => sendmail => ldconfig => groups => sha3sum => mktemp => ps => sha256sum => mkswap => pipe_progress => sha1sum => mknod => dos2unix => xargs => shuf => fuser => rev => vi => ifconfig => getent => tty => yes => scanelf => fatattr => readlink => kill => lspci => ipcalc => cryptpw => whois => swapon => nameif => factor => rdev => vlock => killall5
```

**Use search problem solver**

Use the `-sp` option

```bash
$ echo -e "scp\nls\nps\nssh\ntouch\nsort" | crystal src/any_shiritori.cr -- -sp
Searching...

Size: 5
Words: [ls -> scp -> ps -> sort -> touch]
----------------------------------------------------------------------------
Length: 5
Shiritori: ls => scp => ps => sort => touch
```

## Reference

[Solving the Longest Shiritori Problem](https://ci.nii.ac.jp/naid/110002768734)

## License

MIT

