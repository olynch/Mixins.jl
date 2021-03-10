module TestMixins
using Test
using Mixins

@define_mixin f begin
  x::Int
  y::String
end

@define_mixin g begin
  z::Symbol
end

@use_mixins struct Cocktail
  @mixin(f)
  @mixin(g)
end

c = Cocktail(2,"gin",:tonic)
@test c.x == 2
@test c.y == "gin"
@test c.z == :tonic

end
