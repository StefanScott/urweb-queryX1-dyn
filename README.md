**Objective**

I'm trying to create a page with a `<ctextbox>` which allows the user to *instantly* filter the records displayed in a table (using the SQL `LIKE` operator).

The page contains the following two elements:

(1) `<ctextbox source={theFilterSource}/>`

(2) an `<xml>` fragment using a `<dyn signal={...}/>` tag, which should show either:

- if `theFilterSource = ""`, then show *all* records from table `thing`;

- otherwise, show only *filtered* records from table `thing` - ie, `WHERE thing.Nam LIKE theFilterSource`


**Questions & Remarks:**

(1) I *thought* that the source and signal were connected together correctly. However, there is some error, possibly involving the result type of the code used in the tag: 
```
  <dyn signal={...}>
```

(2) Does Ur/Web enforce some restriction on the *result* type of the code used in a `<dyn signal={...}>` tag?


(3) The compiler is complaining, saying "have xml, need transaction". 

The error apparently is occurring in the `<dyn signal={...}>` tag, which calls `showRows aFilterSource`.


(4) Based on the declaration of `queryX1` in `top.urs`:

  https://github.com/urweb/urweb/blob/master/lib/ur/top.urs

I believe that the result type of:
```
  fun showRows aFilterSource
```
is:
```
  transaction (xml ctx [] [])
```


**Error in code - gives a compile error, reproduced further below:**

The part of the code which the compiler is complaining about is lines 27-33:
```
(* file queryX1dyn.ur *)

    <xml><dyn signal=    (*** LINE 27 IN ERR MSG ***)
      { aFilterSignal <- signal aFilterSource
        ;
        return
        ( showRows' aFilterSignal )
      } 
    /></xml>   (*** LINE 33 IN ERR MSG ***)
  end
```


**Compile error - "have xml, need transaction":**
```
$ urweb -dbms postgres -db "host=localhost port=5432 user=scott password='pw' dbname=queryx1_dyn" queryX1dyn

queryX1dyn.ur:27:13: (to 33:8) Error in final record unification

Can't unify record constructors

   Have: 

[Signal =
  signal (xml ([Dyn = (), Body = (), MakeForm = ()]) ([]) ([]))]

   Need: 

<UNIF:U284::{Type}> ++
 [Signal =
   signal
    (transaction
      (xml (([Body = ()]) ++ <UNIF:U86::{Unit}>) <UNIF:O::{Type}>
        ([])))]

  Field:  #Signal

Value 1: 

signal (xml ([Dyn = (), Body = (), MakeForm = ()]) ([]) ([]))

Value 2: 

signal
 (transaction
   (xml (([Body = ()]) ++ <UNIF:U86::{Unit}>) <UNIF:O::{Type}> ([])))

Incompatible constructors

Have:  xml ([Dyn = (), Body = (), MakeForm = ()]) ([])

Need:  transaction

$ 
```

**References:**

This work is based on:

(1) the Ur/Web demos Increment and Batch:

  http://www.impredicative.com/ur/demo/increment.html

  http://www.impredicative.com/ur/demo/batch.html

(2) the Ur/Web `<cselect>` test:

  https://github.com/urweb/urweb/blob/master/tests/cselect.ur

(3) a working, minimal example which simply echoes the contents of a <ctextbox> directly below it:
```
fun main () =
  s <- source "";
  return 
  <xml><body>
    <ctextbox source={s}/><br/>
    <dyn signal={s <- signal s; return <xml>{[s]}</xml>}/>
  </body></xml>
```

Thanks for any help getting this to work!

###

