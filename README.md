**Objective:**

I'm trying to create a minimal example of a page with a `<ctextbox>` which uses allows the user to *instantly* filter the records displayed in an `<xml>` fragment below it, using:

- Ur/Web's dynamic page generation / FRP (`source`, `signal`, `<dyn>`);

- the function `queryX1` from [top.urs](https://github.com/urweb/urweb/blob/master/lib/ur/top.urs#L205-L208) / [top.ur](https://github.com/urweb/urweb/blob/master/lib/ur/top.ur#L284-L289);

- Ur/Web's [SQL `LIKE` operator](http://www.impredicative.com/pipermail/ur/2015-August/002189.html).

This would provide simple "live" filtering of recordsets, and possibly also lay the groundwork for a data-bound type-ahead / auto-complete widget.

The page contains only the following two elements:

(1) `<ctextbox source={theFilterSource}/>`

(2) a function call [`{showRows theFilterSource}`](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L44) returning an `<xml>` fragment containing a `<dyn signal={...}/>` tag, which should either:

- if `theFilterSource = ""`, then show *all* records from table `thing`;

- otherwise, show only *filtered* records from table `thing` - ie:

  `SELECT thing.Nam FROM thing WHERE  thing.Nam LIKE {[aFilterString]}`


**Previous, related work:**

The code connecting the `source` and the `signal` is closely modeled on:

(1) the Ur/Web [Increment](http://www.impredicative.com/ur/demo/increment.html) and [Batch](http://www.impredicative.com/ur/demo/batch.html) demos;

(2) the Ur/Web [`<cselect>`](https://github.com/urweb/urweb/blob/master/tests/cselect.ur) test;

(3) a very minimal (and correctly working) FRP example which just instantly echoes the contents of a `<ctextbox>` directly below it:
```
fun main () =
  s <- source "";
  return 
  <xml><body>
    <ctextbox source={s}/><br/>
    <dyn signal={s <- signal s; return <xml>{[s]}</xml>}/>
  </body></xml>
```

**Results:**

The part of the code which the compiler is complaining about is [lines 27-33](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L27-L33) in file [queryX1dyn.ur](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur):
```
    <xml><dyn signal=
      { aFilterSignal <- signal aFilterSource
        ;
        return
        ( showRows' aFilterSignal )
      } 
    /></xml>
  end
```

**Remarks:**

(1) Looking at `queryX1` in [top.urs](https://github.com/urweb/urweb/blob/master/lib/ur/top.urs#L205-L208) / [top.ur](https://github.com/urweb/urweb/blob/master/lib/ur/top.ur#L284-L289), I believe that the result type of `fun showRows aFilterSource` is `transaction xml`.

This *may or may not* be compatible with what is expected by the containing `<dyn signal={...}>` tag, or the containing `<xml>` tag!


**Questions:**

(1) Does Ur/Web impose some restriction on the *result* type of the code used in a `<dyn signal={...}>` tag?


**Similarities and differences between `queryX1dyn.ur` and previous work:**

*Similarities:*

(1) The `show` function (and its auxiliary `show'` function) in [`queryX1dyn.ur`](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L5-L34) are very closely modeled on the `show` function (and its auxiliary `show'` function) in the Ur/Web demo [Batch](https://github.com/urweb/urweb/blob/master/demo/batch.ur#L21-L39).

*Differences:*

(1) The `show` function (and its auxiliary `show'` function) in the Ur/Web demo [Batch](https://github.com/urweb/urweb/blob/master/demo/batch.ur#L21-L39) apparently has result type:

  **`xml`**

while the `show` function (and its auxiliary `show'` function) in [`queryX1dyn.ur`](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L5-L34) apparently has result type:

  **`transaction xml`** .

This could be a problem (and it could actually be the cause of the compile error shown below), but I'm unsure whether (or how) to change this.

(2) The [Batch demo](https://github.com/urweb/urweb/blob/master/demo/batch.ur) involves a [`<button>` with an `onclick` event](https://github.com/urweb/urweb/blob/master/demo/batch.ur#L67) and the [Increment demo](https://github.com/urweb/urweb/blob/master/demo/increment.ur) also involves a [`<button>` with an `onclick` event](https://github.com/urweb/urweb/blob/master/demo/increment.ur#L9).

The present example `queryX1dy` is different in two ways:

(a) Instead of having a `<button>` on the page, it has a [`<ctextbox source={theFilterSource}>`](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L41-L43) on the page, which receives the user's input, thus changing [`theFilterSource`](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L37).

(b) The `onclick` event in both of those previous demos also *updates* some data on the server (batch-inserting records, or incrementing a sequence, respectively). But the current project `queryX1dyn` *does not update* any data on the server: it merely gets some data from the server. (Of course, even though the demos do a "write" and the current project merely does a "read", *both* operations are still *transactional*, since they involve accessing the database on the server.)


**Compile error message `Have: xml / Need: transaction`:**

The entire compile error message is:

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

Thanks for any help getting this to work!

###

