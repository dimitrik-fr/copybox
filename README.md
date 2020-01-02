# CopyBox

This is a plugin for [Micro Editor](https://github.com/zyedidia/micro) covering the missed
features (at least for me) around Copy/Paste stuff.
No idea why, but on some Terminal session Copy/Paste in Micro is not working for me (sometimes
allows to Select but not Paste, sometimes just nothing at all). And, finally, Micro Copy/Paste
stuff is simply impossible to involve if I'm opening SSH session from my iPad (or at least I did
not find until now a Terminal app for iPad allowing to do so ;-))

All in all, it was more simple to write a plugin for Micro to do exactly what I need ;-))

In short, CopyBox allows:

* select Start & End text selection points by keys..
* save/restore text selection to/from file..
* execute text selection or the current line as Bash script..

By default it uses F3 to toggle Selection ON/OFF (allowing to mark the beginning and the end
of Selection). This Selection is saved internally, so you can move in editor to any other
place and press F5 to copy to the current place previously selected text.

By pressing F4 you can save the Selection to external file. And by pressing F6 you can read the
contents of this file to the current position in editor (pretty useful when you need to copy
or reuse some blocks of your code to other files, etc.). By default `/tmp/copybox.out` file
name is used, but you can change it via `settings.json`, for ex:

```
  "copybox_filename" : "/tmp/copybox-dim.out",
```

or directly within Micro by pressing Ctrl-E and then typing "set copybox_filename ..."

And finally by pressing F9 you can execute the Selected text as shell script -- but this is 
probably rather my own "life-hack" which I'm trying to have in any editor I'm using ;-))
Generally instead of keeping in notes or in scripts tons of various shell commands I may need
to use on the given server (or project, etc.) I'm just keeping them within a dedicated file
from which I can start it directly from the editor whenever I need..

For ex. it's enough to place my cursor to any of the following lines and press F9 to
execute the given command directly from the editor:
```
  lscpu
  fdisk -l | grep Disk
  parted -l
```

And by selecting several lines more commands can be executed together, including more
"logic" as well, for ex.:
```
  for nm in host1 host2 host3
  do
    scp *.tgz $nm:/apps/tmp
  done
```

Along with Fn keys shortcuts assigned by default, there are also few commands added to Micro
allowing you to execute them via Ctrl-E prompt (can still solve when your Terminal is not 
sending Fn keys expected by Micro):

* copy_set -- set Selection begin/end
* copy_paste -- Paste Selection
* copy_save -- Save Selection to file
* copy_load -- Load from file
* copy_exec -- Execute Selection as shell command/script

To install the plugin just copy copybox.lua file into your Micro plugins directory
and restart Micro:

```
  mkdir -p ~/.config/micro/plugins/copybox
  cp copybox.lua ~/.config/micro/plugins/copybox
```

In case this will help someone else -- have fun & enjoy ;-)) 

While, to be honest, would love to see these features implemented "natively" in Micro, as
it could be done then much more efficiently and better integrated..

Rgds, -Dimitri
