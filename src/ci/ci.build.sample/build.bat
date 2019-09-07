dotnet restore src/ci.build.sample
dotnet build src/ci.build.sample

dotnet restore tests/ci.build.sample.Tests
dotnet build tests/ci.build.sample.Tests
dotnet test tests/ci.build.sample.Tests
