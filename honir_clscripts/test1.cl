procedure test1( nodpattern )
string nodpattern

begin

    int nod_num
    string newletter, nod_letter[99], nod_current
    bool nlexist

    nod_num=0
    for( i=1; i< strlen( nodpattern ); i+=1 ){
    	nlexist = no
	nod_current = substr( nodpattern, i, i)
        for( j=1; j<=nod_num; j+=1 ){
	    if ( nod_letter[j] == nod_current )
	        nlexist = yes
	}
	if ( nlexist == no ){
	    nod_num += 1
	    nod_letter[nod_num] = nod_current
	}
    }
    for( i=1; i<=nod_num; i+=1 ){
        printf("%s\n", nod_letter[i] )
    }

end

#end