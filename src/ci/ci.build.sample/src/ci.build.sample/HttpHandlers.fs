namespace ci.build.sample

open Microsoft.Extensions.Configuration
open package.sample

module HttpHandlers =

    open Microsoft.AspNetCore.Http
    open FSharp.Control.Tasks.V2.ContextInsensitive
    open Giraffe

    let helloWorld =
        fun (next : HttpFunc) (ctx : HttpContext) ->
            task {
                let helloWorld = Shoebox.say <| ctx.GetService<IConfiguration>().["HELLO_WORLD"]
                return! text helloWorld next ctx
            }