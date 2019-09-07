namespace ci.build.sample

open Microsoft.Extensions.Configuration

module HttpHandlers =

    open Microsoft.AspNetCore.Http
    open FSharp.Control.Tasks.V2.ContextInsensitive
    open Giraffe
    open ci.build.sample.Models

    let helloWorld =
        fun (next : HttpFunc) (ctx : HttpContext) ->
            task {
                let helloWorld = ctx.GetService<IConfiguration>().["HELLO_WORLD"]
                return! text helloWorld next ctx
            }