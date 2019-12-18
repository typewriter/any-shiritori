# any-shiritori

しりとり (Shiritori)

## Usage

```bash
$ echo -e "scp\nls\nps\nssh\ntouch\nsort" | crystal src/any_shiritori.cr
Answers:
  ls -> scp -> ps -> sort -> touch
Solves:
  ls -> scp -> ps -> sort -> touch
  ls -> scp -> ps -> ssh
  scp -> ps -> sort -> touch
  ps -> sort -> touch
  ls -> sort -> touch
  scp -> ps -> ssh
  sort -> touch
  ps -> ssh
  ps -> scp
  ls -> ssh
  touch
  ssh
```

```bash
$ cat words.txt
ip
ifconfig
netstat
ping
traceroute
$ crystal src/any_shiritori.cr words.txt
Answers:
  ip -> ping
  netstat -> traceroute
Solves:
  netstat -> traceroute
  ip -> ping
  traceroute
  ping
  ifconfig
```
