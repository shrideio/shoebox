# 1. Build the image
# sudo docker build -t hello-world .

# 2. Start a container
# sudo docker run -e HELLO_WORLD='Hello World!' -d -p 9880:80 hello-world

# 3. Pull the endpoint
# sudo curl http://localhost:9880/api/hello

FROM mcr.microsoft.com/dotnet/core/sdk:2.2-alpine AS build
WORKDIR /build

COPY tests/. ./tests/
COPY src/. ./src/

# build
RUN dotnet build ./src/**/*.fsproj --verbosity normal --configuration Release
RUN dotnet build ./tests/**/*.fsproj --verbosity normal --configuration Release

# test
RUN dotnet test ./tests/**/*.fsproj --no-build --no-restore --verbosity normal --configuration Release

# publish
RUN dotnet publish ./src/ci.build.sample/ci.build.sample.fsproj --no-build --no-restore --verbosity normal --configuration Release --output /build/release

# containerize
FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-alpine AS runtime
WORKDIR /app
COPY --from=build /build/release ./
ENTRYPOINT ["dotnet", "ci.build.sample.dll"]