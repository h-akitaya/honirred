#
# apstr.cl
#   return aperture enumerate string
#
#     Ver 1.00  2005. 8.10  H. Akitaya
#

procedure apstr( max_ap, retmode )

int max_ap {prompt = "max number of apetrures : "}
string retmode ="all" { enum="odd|even|all", prompt = "type of result (odd|even|all): "}

begin

    int i, len
    string str_result = ""

    for( i = 1; i <= max_ap; i+=1 ){
        if( retmode == "even" && mod(i, 2) != 0 )
            next
        if( retmode == "odd" && mod(i, 2) != 1 )
            next
        str_result = str_result//","//i
    }

    len = strlen( str_result )
    if( len != 0 )
        str_result = substr( str_result, 2, len )
    printf("%s\n", str_result )

    bye

end

#end

