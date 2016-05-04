immutable File
    name::AbstractString
    hash::ASCIIString
    origins::Dict{AbstractString, AbstractString}
end

File(name, hash) = File(name, hash, Dict{AbstractString, AbstractString}())
File(name, hash, origin::AbstractString, id::AbstractString) = begin
    a = File(name, hash)
    a.origins[origin] = id
    a
end

import Base: hash, isequal

Base.hash(x::File, y::UInt64) = hash(hash(x.name, parse(UInt64, x.hash, 16)), y)

Base.isequal(x::File, y::File) = x.name == y.name && x.hash == y.hash
