table thing : {
  Nam : string
}

fun showRows aFilterSource = 
  let 
    fun showRows' aFilterString = 
      case aFilterString of
          "" =>
            queryX1 
               ( SELECT thing.Nam 
                 FROM   thing )
              ( fn r => 
                <xml>
                  {[r.Nam]}<br/>
                </xml> )
        | _ =>
            queryX1 
              ( SELECT thing.Nam 
                FROM   thing
                WHERE  thing.Nam LIKE {[aFilterString]} )
              ( fn r => 
                <xml>
                  {[r.Nam]}<br/>
                </xml> )
  in
    <xml><dyn signal=
      { aFilterSignal <- signal aFilterSource
        ;
        return
        ( showRows' aFilterSignal )
      } 
    /></xml>
  end

fun main () =
  theFilterSource <- source ""
  ;
  return 
  <xml><body>
    <ctextbox
      source={theFilterSource}
    /><br/>
    {showRows theFilterSource}
  </body></xml>