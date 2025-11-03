# Copyright 2025 Data Lab Hell GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""
ULID

Unique Lexicographically Sortable Identifier [ULID](https://github.com/ulid/spec).
Binary implementation in julia.
"""
module ULID

using Random

export ulid, Ulid

"""
Represents a Unique Lexicographically Sortable Identifier (ULID).
Uses `UInt128` for storage.
"""
struct Ulid
  value::UInt128
end
Ulid(u::Ulid) = u

Base.UInt128(u::Ulid) = u.value

# Crockford's base-32 encoding
const _ENCODING = UInt8['0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J',
                        'K', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V',
                        'W', 'X', 'Y', 'Z']

function _build_ulid(rng::AbstractRNG, timestamp::UInt128)
    bytes = rand(rng, UInt128)
    # make space for the timestamp
    bytes >>= UInt128(48)

    bytes |= timestamp << UInt128(80)

    return Ulid(bytes)
end

"""
```
    ulid([rng=Random.RandomDevice()])
```
Generate a ULID using the default rng for randomness and `Base.time` for reading the current time.

```
    ulid(rng)
```
Generate random part of the ULID with a user defined rng.
"""
function ulid(rng::AbstractRNG=Random.RandomDevice())
    # current time in ms, rounded to an Integer
    timestamp = round(UInt128, time() * 1e3)
    _build_ulid(rng, timestamp)
end

function Base.string(u::Ulid)
  u = u.value
  # use Base.StringMemory(26) in newer version
  a = Base.StringVector(26)
  for i in 26:-1:1
    # divide by 32 (0x1f == 31)
    @inbounds a[i] = _ENCODING[1 + u & 0x1f]
    u >>= 5
  end
  return String(a)
end

Base.print(io::IO, u::Ulid) = print(io, string(u))
Base.show(io::IO, u::Ulid) = print(io, ULID, "(\"", u, "\")")


function __convert_digit(c::UInt8)
    x = findfirst(==(c), _ENCODING)
    if isnothing(x)
        return nothing
    end
    return UInt8(x - 1)
end

function Base.tryparse(::Type{Ulid}, s::AbstractString)
    u = UInt128(0)
    shift = 0
    ncodeunits(s) != 26 && return nothing
    for i in 26:-1:1
        x = __convert_digit(codeunit(s, i))
        isnothing(x) && return nothing
        u |= UInt128(x) << shift
        shift += 5
    end
    return Ulid(u)
end

function Base.parse(::Type{Ulid}, s::AbstractString)
    x = tryparse(Ulid, s)
    isnothing(x) && throw("Could not parse $s as ULID")
    return x
end

Base.isless(u1::Ulid, u2::Ulid) = isless(u1.value, u2.value)
Base.isequal(u1::Ulid, u2::Ulid) = isequal(u1.value, u2.value)
Base.hash(u::Ulid) = hash(u.value)
end # module
