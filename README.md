# compe-conjure
compe-nvim source for conjure

## Usage 

Make sure that compe-nvim is loaded.
```clojure
((. (require :compe_conjure) :attach))
```

```lua
require'compe_conjure'.attach()
```

## TODO

- Fix the slight delay when initializing the source for the first time.
- Add extra source to fennel https://github.com/gbaptista/sublime-text-fennel/blob/master/Fennel.sublime-completions
- Hide suffix until the prefix is written with `.`

