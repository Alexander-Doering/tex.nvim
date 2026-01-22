# tex.nvim

## How to install

Lazy:

```lua
return {
  "eczovian/tex.nvim",
  ft = 'tex',
  opts={output_dir=${relative or absolute path} },
}
```

## Goals of this fork
[ ] Make output folder variable

[ ] Open LaTeX File in window

[ ] Exclude speicfic files from compiling (i.e structure / preamble, so you can write them without nvim.tex having a stroke)
