immutable File
    name::AbstractString
    hash::ASCIIString
    origins::Set{ASCIIString}
end

File(name, hash) = File(name, hash, Set{ASCIIString}())
File(name, hash, origin::AbstractString) = begin
    a = File(name, hash)
    push!(a.origins, origin)
    a
end

import Base: hash, isequal

Base.hash(x::File, y::UInt64) = hash(hash(x.name, parse(UInt64, x.hash, 16)), y)

Base.isequal(x::File, y::File) = x.name == y.name && x.hash == y.hash
