using ULID: ulid, Ulid, _build_ulid
using Test
using Random

@testset "building" begin
    u = Ulid(UInt128(0))
    @test iszero(u.value)
    # test manual building
    rng = Random.seed!(0)
    xr = rand(rng, UInt128)
    t = rand(rng, UInt128)
    Random.seed!(0)
    uv1 = _build_ulid(rng, t)
    Random.seed!(rng, 0)
    uv2 = _build_ulid(rng, t)
    @test uv1 == uv2
    us = bitstring(uv1.value)
    # first 48bits are the timestamp
    @test us[1:48] == bitstring(t)[end-47:end]
    # the next from the rng
    @test us[49:end] == bitstring(xr)[1:80]
    # ulids should be sorted by creation time
    u1 = ulid(rng)
    sleep(0.1)
    u2 = ulid()
    @test u1 <= u2
    @test u1 != u2
end

@testset "print and parse" begin
    U = [ulid() for _ in 1:10]
    @test all(u -> length(string(u)) == 26, U)
    @test all(u -> parse(Ulid, string(u)).value == u.value, U)
    u0 = Ulid(UInt128(0))
    @test string(u0) == "0"^26
    @test u0 == parse(Ulid, "0"^26)
    @test parse(Ulid, "0"^13 * "1"^13).value == UInt128(0x1084210842108421)
    @test parse(Ulid, "Z"^26).value == typemax(UInt128)
end
