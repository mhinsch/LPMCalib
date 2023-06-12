module DeclUtils
    export @decl_setters, @decl_getters, @decl_getsetters, @export_forward

    setter_name(field) = Symbol(String(field) * "!")
    getter_name(field) = field

    function setter(field, type) 
        name = setter_name(field)
        :($(esc(name))(x::$(esc(type)), value) = (x.$field = value))
    end

    function getter(field, type) 
        name = getter_name(field)
        :($(esc(name))(x::$(esc(type))) = x.$field)
    end

    macro decl_setters(type, fields...)
        Expr(:Block, [setter(f, type) for f in fields])
    end

    macro decl_getters(type, fields...)
        Expr(:Block, [setter(f, type) for f in fields])
    end

    macro decl_getsetters(type, fields...)
        Expr(:block, 
             [[setter(f, type) for f in fields] ;
              [getter(f, type) for f in fields]]...)
    end

    function subsetter(field, type, sub) 
        name = setter_name(field)
        :($(esc(name))(x::$(esc(type)), value) = (x.$sub.$field = value))
    end

    function subgetter(field, type, sub) 
        name = getter_name(field)
        :($(esc(name))(x::$(esc(type))) = x.$sub.$field)
    end

    
    function getset_export(field)
        gname = getter_name(field)
        sname = setter_name(field)

        :(export $(esc(gname)), $(esc(sname)))
    end

    macro export_forward(type, fieldvec)
        @assert fieldvec.head == :vect
        fields = fieldvec.args
        Expr(:block,
            [setter(f, type) for f in fields]...,
            [getter(f, type) for f in fields]...,
            [getset_export(f) for f in fields]...)
    end

    macro export_forward(type, sub, fieldvec)
        @assert fieldvec.head == :vect
        fields = fieldvec.args
        Expr(:block,
            [subsetter(f, type, sub) for f in fields]...,
            [subgetter(f, type, sub) for f in fields]...,
            [getset_export(f) for f in fields]...)
    end
end # DeclUtils
