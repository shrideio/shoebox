module Tests

open System
open System.IO
open System.Net
open System.Net.Http
open Xunit
open Microsoft.AspNetCore.Builder
open Microsoft.AspNetCore.Hosting
open Microsoft.AspNetCore.TestHost
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Configuration
open System.Collections.Generic

// ---------------------------------
// Helper functions (extend as you need)
// ---------------------------------

let buildConfiguration () =
    fun  _ (builder : IConfigurationBuilder) ->
        builder
            .AddInMemoryCollection([ KeyValuePair("HELLO_WORLD", "Hello test!") ])
            .Build()
            |> ignore

let createHost() =
    WebHostBuilder()
        .UseContentRoot(Directory.GetCurrentDirectory())
        .ConfigureAppConfiguration(buildConfiguration())
        .Configure(Action<IApplicationBuilder> ci.build.sample.App.configureApp)
        .ConfigureServices(Action<IServiceCollection> ci.build.sample.App.configureServices)

let runTask task =
    task
    |> Async.AwaitTask
    |> Async.RunSynchronously

let httpGet (path : string) (client : HttpClient) =
    path
    |> client.GetAsync
    |> runTask

let isStatus (code : HttpStatusCode) (response : HttpResponseMessage) =
    Assert.Equal(code, response.StatusCode)
    response

let ensureSuccess (response : HttpResponseMessage) =
    if not response.IsSuccessStatusCode
    then response.Content.ReadAsStringAsync() |> runTask |> failwithf "%A"
    else response

let readText (response : HttpResponseMessage) =
    response.Content.ReadAsStringAsync()
    |> runTask

let shouldEqual expected actual =
    Assert.Equal(expected, actual)

let shouldContain (expected : string) (actual : string) =
    Assert.True(actual.Contains expected)

// ---------------------------------
// Tests
// ---------------------------------

[<Fact>]
let ``Route /api/hello returns "Hello world test!"`` () =
    use server = new TestServer(createHost())
    use client = server.CreateClient()

    client
    |> httpGet "/api/hello"
    |> ensureSuccess
    |> readText
    |> shouldContain "Hello test!"

[<Fact>]
let ``Route which doesn't exist returns 404 Page not found`` () =
    use server = new TestServer(createHost())
    use client = server.CreateClient()

    client
    |> httpGet "/route/which/does/not/exist"
    |> isStatus HttpStatusCode.NotFound
    |> readText
    |> shouldEqual "Not Found"