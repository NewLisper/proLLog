module Main where
import System.IO
import System.Environment
import Text.ParserCombinators.Parsec
import Data.Map as Map
import Data.List as List

data TermList = Cons Term TermList
              | Improper Term Term
              | Nil

data Term = Atom String
     	  | Lis TermList
          | Var String
          | Functor String Int [Term]

data Tag = A | L | V | F

parseAtom :: Parser Term
parseAtom = do first <- lower
 	       rest  <- many $ alphaNum <|> char '_'
 	       return $ Atom (first:rest)

parseVar = do first <- upper <|> char '_'
              rest  <- many $ alphaNum <|> char '_'
              return $  Var (first:rest)

parseFunctor = do (Atom name) <- parseAtom
	       	  char '('
		  spaces
		  args <- parseTerms
                  spaces
		  char ')'
		  return $ Functor name (length args) args


parseTail = do char '|'
	       spaces
	       t <- parseTerm
	       spaces
 	       char ']'
	       return $ Improper (Atom "uglyPlaceholderTrick")  t
        <|> do char ']'
	       return Nil

parseTermList = do char '['
	           spaces
	           ts <- parseTerms
	           spaces
	           ta <- parseTail
	           return $ Lis (makelst ts ta)
                where makelst [] Nil = Nil
		      makelst [x] (Improper _ t) = Improper x t
		      makelst [] (Improper _ _) = error "invalid improper list"
	    	      makelst (x:xs) t = Cons x (makelst xs t)

parseCut = do char '!'
	      return $ Functor "!" 0 []


parseTerm = try parseFunctor
        <|> parseAtom
        <|> parseVar
	<|> parseTermList
	<|> parseCut

parseTerms = sepBy parseTerm (spaces >> char ',' >> spaces)

parseClause = do spaces
	      	 head <- parseTerm
		 spaces
		 body <- (string ":-" >> spaces >> parseTerms)
		         <|> (return [])
		 char '.'
		 spaces
		 return (head,body)

parseGoal  = do spaces
		string "?-"
		spaces
		ts <- parseTerms
		char '.'
		spaces
		return ts

parseProgram = do 
	       cs <- many parseClause
	       g  <- parseGoal
	       return (g,cs)


compileProgram (g,cs) = (compileGoal g) ++ ((compileClauses.mergeClauses) cs)

compileGoal ts = let (codes,i) = compileBody ts Map.empty 0
	         in renameTab Map.empty $ ["alloc "++ show i] ++ codes ++ ["find_answer","dealloc","proceed"]


compileSubClause (head,body) = let (codeh,v,i) = compileHead head Map.empty 0
                                   (codeb,li)  = compileBody body v i
		               in renameTab Map.empty $ ["alloc "++ show li] ++ codeh ++ codeb ++ ["dealloc","proceed"]


compileClause (c@((Functor n a _),_):[]) = ["label "++n++" "++show a]++compileSubClause c

compileClause (c@((Functor n a _),_):rs) = ["label "++n++" "++show a,"try_me_else "++n++" "++show a]++(compileSubClause c)++(compileRs rs 2)
                       where compileRs (x@((Functor n a _),_):[]) i = ["label "++n++" "++show a,"trust_me"]++(compileSubClause x)
		             compileRs (x@((Functor n a _),_):xs) i = ["label "++n++" "++show a,"retry_me_else "++n++" "++show a++" "++show i]++(compileSubClause x)++(compileRs xs (i+1))
				   	     	      	           
compileClause _ = error "invalid clause" 

compileClauses [] = []
compileClauses (x:xs) = (compileClause x) ++ (compileClauses xs)

mergeClauses [] = []
mergeClauses (x:xs) = insert x (mergeClauses xs)
 	     	      where insert (head,body) [] = [[(head,body)]]
		      	    insert c1@(head,_) (c2@((head',_):_):ys)
			    	   	       | sameHead head head' = (c1:c2):ys
					       | otherwise = c2:(insert c1 ys)
			    sameHead (Functor n1 a1 _) (Functor n2 a2 _) = n1 == n2 && a1 == a2
			    sameHead _ _ = error "Invalid clause head"


-- addressing code 
computeAddr i addrmap [] = ([],addrmap)
computeAddr i addrmap (x:xs) = let strs =  (words x)
	    	               in if strs!!0 == "label"
		       	             then computeAddr i (Map.insertWith (\x1 x2->x2++x1) (strs!!1,strs!!2) [(show i)] addrmap) xs
				     else let (codes,lmap) = computeAddr (i+1) addrmap xs
				     	  in (x:codes,lmap) 

putAddr (cs,addrmap) = List.map (\c -> case (words c) of
	       	       	      	     	  "call":n:a:[] -> "call "++ (case (Map.lookup (n,a) addrmap) of
					  		   	     	   Just addr -> (addr!!0)
									   Nothing -> error $ "call invalid functor " ++n++" "++a) ++" "++a
					  "try_me_else":n:a:[] -> "try_me_else "++ case (Map.lookup (n,a) addrmap) of
                                          		       	     	                 Just addr -> (addr!!1)
                                                                          		 Nothing -> error $ "try_me_else invalid functor" ++n++" "++a
					  "retry_me_else":n:a:i:[]-> "retry_me_else "++ case (Map.lookup (n,a) addrmap) of
                                          			     		       	          Just addr -> (addr!!(read i))
                                                                          			  Nothing -> error $ "retry_me_else invalid functor" ++n++" "++a
                                          _ -> c) cs  
                                 

-- rename xxx_tab instruction in a clause or goal
renameTab occurmap [] = []

renameTab occurmap (c:cs) =  case (words c) of
	  	   	       "set_tab":i:[] -> case (Map.lookup i occurmap) of
			       		      	      Just _ -> ["set_value "++i]++(renameTab occurmap cs)
						      Nothing -> ["set_variable "++i]++(renameTab (Map.insert i True occurmap) cs)
			       "put_tab":i:a:[] -> case (Map.lookup i occurmap) of
			       		      	      Just _ ->	["put_value "++i++" "++a]++(renameTab occurmap cs)
						      Nothing -> ["put_variable "++i++" "++a]++(renameTab (Map.insert i True occurmap) cs)
 			       "get_tab":i:a:[] -> case (Map.lookup i occurmap) of
                                                      Just _ -> ["get_value "++i++" "++a]++(renameTab occurmap cs)
                                                      Nothing -> ["get_variable "++i++" "++a]++(renameTab (Map.insert i True occurmap) cs)
			       "unify_tab":i:[] -> case (Map.lookup i occurmap) of
			       		      	      Just _ ->	["unify_value "++i]++(renameTab occurmap cs)
                                                      Nothing -> ["unify_variable "++i]++(renameTab (Map.insert i True occurmap) cs)
			       _ -> c:(renameTab occurmap cs)

-- (tag,code,temp register/ 0 for var atom , map, var index,temp register index)
compilePutTerm (Atom name) varmap index reg = (A,["set_const "++name],0,varmap,index,reg)

-- codes sequence will be reordered,set_variable or set_value can't be determined at compiling time,so set_tab is used here 
compilePutTerm (Var name) varmap index reg = case (Map.lookup name varmap) of
					          Just vi -> (V,["set_tab "++show vi],0,varmap,index,reg) 
					          Nothing -> (V,["set_tab "++show index],0,        
					      	      	        Map.insert name index varmap, index+1,reg)

compilePutTerm (Functor n a ts) varmap index reg = let (xs,v,i,r) = compileSub ts varmap index reg
	       		    	       	           in (F,getCode xs r,r,v,i,r+1)
	       		    	       	           where compileSub [] v i r = ([],v,i,r) 
					     	         compileSub (x:xs) v i r = let (tag,code,treg,nvarmap,nindex,nreg) = compilePutTerm x v i r
						   	      	                       (rs,lvarmap,lindex,lreg) = compileSub xs nvarmap nindex nreg
									           in  ((tag,code,treg):rs,lvarmap,lindex,lreg)
 							 getCode xs r = let pre = concat $  List.map (\(t,c,r) -> case t of 
 							 	      	    	  	    	     	       	      F -> c 
														      L -> c
														      _ ->[]) xs
							 	            mid = ["put_struct "++n++" "++show a++" "++show r]
									    post = concat $ List.map (\(t,c,r) -> case t of
									    	   	    	     	       	       F -> ["set_reg "++show r] 
														       L -> ["set_reg "++show r]
														       _ -> c)  xs
								        in pre++mid++post 

compilePutTerm (Lis ts) varmap index reg = let (xs,v,i,r) = compileList ts varmap index reg
                                           in if (length xs) == 2 then (L,getCode xs r,r,v,i,r+1) else let [(_,c,_)] = xs in (A,c,0,v,i,r)
	      	       	      	    	   where compileList Nil v i r = ([(A,["set_const nil"],0)],v,i,r)
					  	 compileList (Improper t1 t2) v i r = let (tag1,code1,treg1,nvarmap,nindex,nreg) = compilePutTerm t1 v i r
							      	      	       	     	  (tag2,code2,treg2,lvarmap,lindex,lreg) = compilePutTerm t2 nvarmap nindex nreg
										      in ([(tag1,code1,treg1),(tag2,code2,treg2)],lvarmap,lindex,lreg)
						 compileList (Cons t ts) v i r = let (tag1,code1,treg1,nvarmap,nindex,nreg) = compilePutTerm t v i r
                                                                                     (tag2,code2,treg2,lvarmap,lindex,lreg) = compilePutTerm (Lis ts) nvarmap nindex nreg
                                                                                 in  ([(tag1,code1,treg1),(tag2,code2,treg2)],lvarmap,lindex,lreg)
					         getCode xs r = let pre = concat $  List.map (\(t,c,r) -> case t of
                                                                                                               F -> c
                                                                                                               L -> c
                                                                                                               _ ->[]) xs
                                                                    mid = ["put_list "++show r]
                                                                    post = concat $ List.map (\(t,c,r) -> case t of
                                                                                                               F -> ["set_reg "++show r]
                                                                                                               L -> ["set_reg "++show r]
                                                                                                               _ -> c)  xs
                                                                in pre++mid++post
compileBody [] varmap index = ([],index)

compileBody ((Atom "fail"):ys) varmap index = let (rs,li) = compileBody ys varmap index
                                              in (["fail"]++rs,li)
compileBody ((Functor "!" 0 _):ys) varmap index = let (rs,li) = compileBody ys varmap index
	    	      	    	   	  	  in (["cut"]++rs,li)
compileBody ((Functor n a ts):ys) varmap index = let (xs,v,i,r) = compileCall ts varmap index a
                                                     (rs,li) = compileBody ys v i
	    	       	 	                 in  ((getCode xs) ++ (("call "++n++" "++show a):rs),li)
                                                 where compileCall [] v i r = ([],v,i,r) 
				                       compileCall (x:xs) v i r = let (tag,code,treg,nvarmap,nindex,nreg) = compilePutTerm x v i r
				       		     	      	                      (rs,lvarmap,lindex,lreg) = compileCall xs nvarmap nindex nreg
                                                                                  in  ((tag,code,treg):rs,lvarmap,lindex,lreg)
                                                       getCode xs = let  pre = concat $ List.map (\(t,c,r) -> case t of
                                                                                                               F -> c
                                                                                                               L -> c
                                                                                                               _ ->[]) xs
                                                                         post = List.map (\((t,c,r),i) -> case t of
							       	 	  		                     A -> "put"++((dropWhile(/='_') . head) c)++" "++show i
							                                                     V -> "put"++((dropWhile(/='_') . head) c)++" "++show i
											                     _ -> "put_via_reg "++show r++" "++show i) (zip xs [0..])
						                    in pre++post                           				      
compileBody (_:xs) _ _ = error "call to non functor" 


compileGetTerm (Atom name) varmap index reg = (A,["unify_const "++name],0,varmap,index,reg)

compileGetTerm (Var name) varmap index reg = case (Map.lookup name varmap) of
                                                  Just vi -> (V,["unify_tab "++show vi],0,varmap,index,reg)
                                                  Nothing -> (V,["unify_tab "++show index],0,
                                                                 Map.insert name index varmap, index+1,reg)

compileGetTerm (Functor n a ts) varmap index reg = let (xs,v,i,r) = compileSub ts varmap index reg
                                                   in (F,getCode xs r,r,v,i,r+1)
                                                   where compileSub [] v i r = ([],v,i,r)
                                                         compileSub (x:xs) v i r = let (tag,code,treg,nvarmap,nindex,nreg) = compileGetTerm x v i r
                                                                                       (rs,lvarmap,lindex,lreg) = compileSub xs nvarmap nindex nreg
                                                                                   in  ((tag,code,treg):rs,lvarmap,lindex,lreg)
                                                         getCode xs r = let pre = concat $  List.map (\(t,c,r) -> case t of
                                                                                                                      F -> c
                                                                                                                      L -> c
                                                                                                                      _ ->[]) xs
                                                                            mid = ["get_struct "++n++" "++show a++" "++show r]
                                                                            post = concat $ List.map (\(t,c,r) -> case t of
                                                                                                                       F -> ["unify_reg "++show r]
                                                                                                                       L -> ["unify_reg "++show r]
                                                                                                                       _ -> c)  xs
                                                                        in mid++post++pre

compileGetTerm (Lis ts) varmap index reg = let (xs,v,i,r) = compileList ts varmap index reg
                                           in if (length xs) == 2 then (L,getCode xs r,r,v,i,r+1) else let [(_,c,_)] = xs in (A,c,0,v,i,r)
                                           where compileList Nil v i r = ([(A,["unify_const nil"],0)],v,i,r)
                                                 compileList (Improper t1 t2) v i r = let (tag1,code1,treg1,nvarmap,nindex,nreg) = compileGetTerm t1 v i r
                                                                                          (tag2,code2,treg2,lvarmap,lindex,lreg) = compileGetTerm t2 nvarmap nindex nreg
                                                                                      in ([(tag1,code1,treg1),(tag2,code2,treg2)],lvarmap,lindex,lreg)
                                                 compileList (Cons t ts) v i r = let (tag1,code1,treg1,nvarmap,nindex,nreg) = compileGetTerm t v i r
                                                                                     (tag2,code2,treg2,lvarmap,lindex,lreg) = compileGetTerm (Lis ts) nvarmap nindex nreg
                                                                                 in  ([(tag1,code1,treg1),(tag2,code2,treg2)],lvarmap,lindex,lreg)
                                                 getCode xs r = let pre = concat $  List.map (\(t,c,r) -> case t of
                                                                                                               F -> c
                                                                                                               L -> c
                                                                                                               _ ->[]) xs
                                                                    mid = ["get_list "++show r]
                                                                    post = concat $ List.map (\(t,c,r) -> case t of
                                                                                                               F -> ["unify_reg "++show r]
                                                                                                               L -> ["unify_reg "++show r]
							            					       _ -> c) xs
							            in mid++post++pre						

compileHead (Functor n a ts) varmap index = let (xs,v,i,r) = compileSub ts varmap index a
                                            in  (getCode xs,v,i)
                                            where compileSub [] v i r = ([],v,i,r)
                                                  compileSub (x:xs) v i r = let (tag,code,treg,nvarmap,nindex,nreg) = compileGetTerm x v i r
                                                                                (rs,lvarmap,lindex,lreg) = compileSub xs nvarmap nindex nreg
                                                                            in  ((tag,code,treg):rs,lvarmap,lindex,lreg)
                                                  getCode xs = let  pre = concat $ List.map (\(t,c,r) -> case t of
                                                                                                            F -> c
                                                                                                            L -> c
                                                                                                            _ ->[]) xs
                                                                    post = List.map (\((t,c,r),i) -> case t of
                                                                                                        A -> "get"++((dropWhile(/='_') . head) c)++" "++show i
                                                                                                        V -> "get"++((dropWhile(/='_') . head) c)++" "++show i
                                                                                                        _ -> "get_via_reg "++show r++" "++show i) (zip xs [0..])
                                                               in post++pre
compileHead _ _ _ = error "call to non functor"       	 

readcode code = case parse parseProgram "prolog" code of
         Left err -> "error" ++ show err
	 Right val -> (concat . intersperse "\n". putAddr . computeAddr 0 Map.empty . compileProgram) val

main = do args <- getArgs
       	  let filename = (args !! 0) 
              in do code <- readFile (filename ++ ".pl")
	            writeFile (filename ++ ".wam") (readcode code)