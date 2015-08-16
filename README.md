**Objective:**

I'm trying to create a minimal example of a page with a `<ctextbox>` which will allow the user to *instantly* filter the records displayed in an `<xml>` fragment below it, using:

- Ur/Web's dynamic page generation / FRP (`source`, `signal`, `<dyn>`);

- the function `queryX1` from [top.urs](https://github.com/urweb/urweb/blob/master/lib/ur/top.urs#L205-L208) / [top.ur](https://github.com/urweb/urweb/blob/master/lib/ur/top.ur#L284-L289);

- Ur/Web's [SQL `LIKE` operator](http://www.impredicative.com/pipermail/ur/2015-August/002189.html).

This would provide simple "live" filtering of recordsets, and possibly also lay the groundwork for later developing a data-bound type-ahead / auto-complete widget.

The page contains only the following two elements:

(1) a [`<ctextbox source={theFilterSource}/>`](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L41-L43)

(2) a function call [`{showRows theFilterSource}`](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L44) returning an `<xml>` fragment containing a `<dyn signal={...}/>` tag, which should either:

- show *all* records from table `thing` (if `theFilterSource = ""`);

- otherwise, show only *filtered* records from table `thing` - ie:

  `SELECT thing.Nam FROM thing WHERE  thing.Nam LIKE {[aFilterString]}`


**Previous, related work:**

The code connecting the `source` and the `signal` is closely modeled on:

(1) the Ur/Web [Increment](http://www.impredicative.com/ur/demo/increment.html) and [Batch](http://www.impredicative.com/ur/demo/batch.html) demos; [See Observation (1) below](#observation_1)

(2) the Ur/Web [`<cselect>`](https://github.com/urweb/urweb/blob/master/tests/cselect.ur) test;

(3) a very minimal (and correctly working) Ur/Web FRP example [urweb-cselect-echo](https://github.com/StefanScott/urweb-cselect-echo) which just instantly echoes the contents of a `<ctextbox>`, directly below the `<ctextbox>` itself.


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

(1) The `show` function in the Ur/Web demo [Batch](https://github.com/urweb/urweb/blob/master/demo/batch.ur#L21-L39) apparently has result type:

  **`xml`**

while the `show` function in [`queryX1dyn.ur`](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L5-L34) apparently has result type:

  **`transaction xml`** .

This *might* be a problem (and it *might* actually be the cause of the compile error shown below), but I'm unsure whether (or how) to change this.

(2) The [Batch demo](https://github.com/urweb/urweb/blob/master/demo/batch.ur) involves a [`<button>` with an `onclick` event](https://github.com/urweb/urweb/blob/master/demo/batch.ur#L67) and the [Increment demo](https://github.com/urweb/urweb/blob/master/demo/increment.ur) also involves a [`<button>` with an `onclick` event](https://github.com/urweb/urweb/blob/master/demo/increment.ur#L9).

The present example `queryX1dy` is different in two ways:

(a) Instead of having a `<button>` on the page, it has a [`<ctextbox source={theFilterSource}>`](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L41-L43) on the page, which receives the user's input, thus automatically changing [`theFilterSource`](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L37).

(b) The `onclick` event in both of those previous demos also *writes* some data on the server (batch-inserting records, or incrementing a sequence, respectively). But the present project `queryX1dyn` *does not write* any data on the server: it merely *reads* some data from the server. (Of course, even though the demos do a "write" while the present project merely does a "read", both the "read" and the "write" are still *transactional*, since they both involve *accessing* the database on the server.)

Therefore, it makes sense that:

- [the `onclick` event of the `<button>`](https://github.com/urweb/urweb/blob/master/demo/batch.ur#L67) in the [Batch demo](https://github.com/urweb/urweb/blob/master/demo/batch.ur), and 

- the [`onclick` event of the `<button>`](https://github.com/urweb/urweb/blob/master/demo/increment.ur#L9) in the [Increment demo](https://github.com/urweb/urweb/blob/master/demo/increment.ur)

would both be somewhat "longer", involving an initial `rpc` call (to write the data on the server).

Meanwhile, in the present example `queryX1dy`, the `<ctextbox>`:

- does *not* have an `on_` event (since, as the previous minimal example [urweb-cselect-echo](https://github.com/StefanScott/urweb-cselect-echo) demonstrates, in the case of a `<ctextbox>` the source updates the signal *automatically*, with no need for, eg, an `onkeyup` event); and

- the `<ctextbox>` in the present example does *not* perform an `rpc` call (since I believe this is unnecessary, because no data needs to be *written* on the server-side).


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


**Discussion:**

We can see that there is a record unification error involving incompatible constructors `Have: xml / Need: transaction`.

This apparently involves the `signal` attribute of the `<dyn>` tag - which means it might also involve the value of the function call which that tag returns - ie: [{showRows theFilterSource}](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L44).

Because the present project is closely modeled on the Ur/Web [Increment](http://www.impredicative.com/ur/demo/increment.html) and [Batch](http://www.impredicative.com/ur/demo/batch.html) demos, I am fairly confident that the connection between the source and the signal has been established correctly. 

However, I am not completely sure about this, since there are a couple of differences between the present project and those demos:

(1) The demos involve a `<button>` with an `onclick` event, while the present project involves a `<ctextbox>` with no event 

However, I believe that in the case of a `<ctextbox>` having a `source` attribute, no `on_` event is necessary - as apparently demonstrated by the very minimal (and correctly working) Ur/Web FRP example [urweb-cselect-echo](https://github.com/StefanScott/urweb-cselect-echo).

(2) The `onclick` event in the demos also perform an `rpc` call. 

However, I believe that no `rpc` call is necessary in the present project, because this project only *reads* data from the server, while the demos *write* data on the server.

It seems more likely that there is some simpler error, eg:

- (most likely, as these are the line numbers flagged by the compile error) a conflict between the type of [return ( showRows' aFilterSignal )](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L31) inside the `dyn` tag in function `showRows`; or

- (less likely?) possibly some incompatibility at the side where [{showRows theFilterSource}](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L44) is inserted into the `<xml>` returned by `main`.


Thanks for any help getting this to work!

###

<a id="observation_1">**Observation (1)**</a>

In particular, I have consciously copied an interesting "idiom" which I believe is found in both Ur/Web demos [Increment](http://www.impredicative.com/ur/demo/increment.html) and [Batch](http://www.impredicative.com/ur/demo/batch.html) demos:

- [`<dyn signal={n <- signal src; return <xml>{[n]}</xml>}/>`](https://github.com/urweb/urweb/blob/master/demo/increment.ur#L8)

- [`<dyn signal={ls <- signal lss; return <xml><table><tr><th>Id</th><th>A</th></tr>{show' ls}</table></xml>}`](https://github.com/urweb/urweb/blob/master/demo/batch.ur#L35)

Observe how in both cases:

- the expression *before* the semi-colon in the `signal` attribute of the `<dyn>` tag performs a call to `signal` on a `source` (`src` resp. `lss`) and then "assigns" the result to a new "variable" (`n` resp. `ls`); and

- the expression *after* the semi-colon uses the newly "assigned" "variable" to return some `<xml>`.

Also observe the following interesting interplay between the types in the second case (the Batch demo): 

(a) The [function call `{show' ls}`](https://github.com/urweb/urweb/blob/master/demo/batch.ur#L37) applies (auxiliary) function `show` to the "variable" `ls` - which was "assigned" earlier in the expression [`ls <- signal lss;...`](https://github.com/urweb/urweb/blob/master/demo/batch.ur#L35)

(b) Page 44 of the [manual](http://www.impredicative.com/ur/manual.pdf) has the declaration:

  `val signal : t ::: Type → source t → signal t`

which seems (to me) to indicate that `signal` takes something of type `source t` and returns something of type `signal t`.

(c) Meanwhile, judging by the `case of` expression in [the (auxiliary) function `show` in the Batch demo](https://github.com/urweb/urweb/blob/master/demo/batch.ur#L23-L33), this function appears to be defined to take an argument either of the form `Nil` or of the form `Cons ((id, a), ls)` - ie it does *not* appear to take something of type `source t`, but instead of a ("simpler") type `t`.

So, based on *my reading of the manual*, I would not have felt confident using the "idiom" described above, involving:

- [`ls <- signal lss;...`](https://github.com/urweb/urweb/blob/master/demo/batch.ur#L35) and

- [`{show' ls}`](https://github.com/urweb/urweb/blob/master/demo/batch.ur#L37)

since I would be afraid the types would conflict.

But based on the *actual working code in the Buffer demo*, I felt confident writing my code in a similar fashion:

(a) calling `signal` on `aFilterSource` to get `aFilterSignal`

[<dyn signal={aFilterSignal <- signal aFilterSource; return (showRows' aFilterSignal)}/>](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L27-L33)

(b) and then using `aFilterSignal` essentially as a ("simple") `string` type, for the argument being passed into [(auxiliary) function `showRows`](https://github.com/StefanScott/urweb-queryX1-dyn/blob/master/queryX1dyn.ur#L7-L25)

I am not sure why this apparently works. (I would like to conjecture that the `;` after `aFilterSignal <- signal aFilterSource` is somehow "unpacking" `aFilterSignal`, converting it from a value of some "monadic" type `signal t` to a value of some "simpler" `t`, in order to allow it to be used as an argument to `showRows`, which as we know expects a value of a "simpler" type `string` and not a value of a "monadic" type... but I have been told that you cannot "unpack" a value from a "monadic" type - so I will just accept that this apparently works for some reason.)

