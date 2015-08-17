layout_binary_tree(nil,nil,I,I,X).
layout_binary_tree(t(W,L,R),t(W,X,Y,PL,PR),Iin,Iout,Y) :- 
   layout_binary_tree(L,PL,Iin,X,s(Y)), 
   layout_binary_tree(R,PR,s(X),Iout,s(Y)).

layout_binary_tree(T,PT) :- layout_binary_tree(T,PT,o,X,o).

?-layout_binary_tree(t(n,t(k,t(c,t(a,nil,nil),t(h,t(g,t(e,nil,nil),nil),nil)),t(m,nil,nil)),
   t(u,t(p,nil,t(s,t(q,nil,nil),nil)),nil)),PT).
