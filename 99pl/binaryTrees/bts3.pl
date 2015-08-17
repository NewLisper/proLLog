mirror(nil,nil).
mirror(t(X,L1,R1),t(Y,L2,R2)) :- mirror(L1,R2),mirror(R1,L2).

symmetric(nil).
symmetric(t(X,L,R)) :- mirror(L,R).

?-symmetric(t(c,t(f,nil,t(a,nil,nil)),t(e,t(b,nil,nil),nil))).
