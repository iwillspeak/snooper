# Snooper

Snooper is a lightweight test automation tool, it monitors files and folders while you work and re-runs your tests when you change something. Snooper doesn't care what language you're using or what framework you are testing with, it's all configureable.

## Useage

```bash
$ snooper <--config CONFIG | -h> <command>
```

See [snooper(1)](http://iwillspeak.github.com/snooper/snooper.1.html) for more information.

## Options

Snooper expects a YAML document of key-value pairs; each pair specifies an 
option. Unknown options are ignored. Options that can contain a list of values
may also be given a single value.

String options: `base_path:`, `command:`

String Array options: `paths:`, `filters:`, `ignored:`
   
_Note_: `filters:` and `ignored:` are regular expressions. This means that
`\.c` will match both `foo.c` and `bar.cfg`, `\.c$` will only match `.c` files.

<script src="https://gist.github.com/iwillspeak/5191785.js"></script>

## Licence

Snooper is open source! For more information check out [the licence](LICENCE.md).