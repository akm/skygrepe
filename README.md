# skygrepe

Skype had /search command to search over multi conversations. But it have gone away.
We need other tools. skygrepe is one of them.

## Installation

    $ gem install skygrepe

If you use rbenv, you should run

    $ rbenv rehash

## Usage

    $ skygrepe KEYWORD

### First time

Before searching, skygrepe require path to database of Skype.

```
$ skygrepe fooobar
 1 /Users/akima/Library/Application Support/Skype/takeshi_akima/main.db
 2 Other
Choose path: 
```

Enter the number of skype path. If you choose "Other",

```
please type path/to/main.db: 
```


## Uninstall

```
$ gem uninstall skygrepe
$ rm $HOME/.skygrepe
```
