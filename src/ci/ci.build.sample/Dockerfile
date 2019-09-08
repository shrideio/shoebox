FROM mcr.microsoft.com/dotnet/core/sdk:2.2-alpine AS build
WORKDIR /app

COPY tests/. ./build/tests/
COPY src/. ./build/src/

RUN dotnet test ./build/tests/**/*.fsproj --verbosity normal

RUN dotnet publish ./build/src/ci.build.sample/ci.build.sample.fsproj --verbosity normal -c Release -o /app/out

FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-alpine AS runtime
WORKDIR /app
COPY --from=build /app/out ./
ENTRYPOINT ["dotnet", "ci.build.sample.dll"]