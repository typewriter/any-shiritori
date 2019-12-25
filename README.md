# any-shiritori

Find the longest shiritori (しりとり) from words

## Usage

```bash
$ echo -e "scp\nls\nps\nssh\ntouch\nsort" | crystal src/any_shiritori.cr
Length: 5
Shiritori: ls => scp => ps => sort => touch
```

```bash
$ cat words.txt
ip
ifconfig
netstat
ping
traceroute
$ crystal src/any_shiritori.cr words.txt
Length: 2
Shiritori: netstat => traceroute
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

