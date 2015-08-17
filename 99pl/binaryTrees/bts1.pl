istree(nil).
istree(t(X,L,R)) :- istree(L),istree(R).

?- istree(t(a,t(b,nil,nil),nil)).
