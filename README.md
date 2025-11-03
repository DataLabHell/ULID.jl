# ULID

[![Build Status](https://github.com/DataLabHell/ULID.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/DataLabHell/ULID.jl/actions/workflows/CI.yml?query=branch%3Amain)

Unique Lexicographically Sortable Identifier [ULID](https://github.com/ulid/spec). Binary implementation in julia.


### Install
```julia
import Pkg
Pkg.add("https://github.com/DataLabHell/ULID.jl")
```


### Usage
```julia
using ULID
# generate time sortable id
u = ulid() # ULID("01K8X9KNDDYVSTF4XBE6A250RB")
# parse binary representation of ULID from string
parse(Ulid, "01K8X9KNDDYVSTF4XBE6A250RB")
```
