# 1. Build the image
# sudo docker build -t hello-world .

# 2. Start a container
# sudo docker run -e HELLO_WORLD='Hello World!' -d -p 9880:80 hello-world

# 3. Pull the endpoint
# sudo curl http://localhost:9880/api/hello


ARG PACKAGES_SOURCE
ARG PACKAGES_USERNAME
ARG PACKAGES_PASSWORD

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine AS build
WORKDIR /build

COPY tests/. ./tests/
COPY src/. ./src/

# build
RUN dotnet nuget add source $PACKAGES_SOURCE --name (awk -F/ '{print $3}' <<< $PACKAGES_SOURCE) --username $PACKAGES_USERNAME --password $PACKAGES_PASSWORD --store-password-in-clear-text
RUN dotnet build ./src/**/*.fsproj --verbosity normal --configuration Release
RUN dotnet build ./tests/**/*.fsproj --verbosity normal --configuration Release

# test
RUN dotnet test ./tests/**/*.fsproj --no-build --no-restore --verbosity normal --configuration Release

# publish
RUN dotnet publish ./src/ci.build.sample/ci.build.sample.fsproj --no-build --no-restore --verbosity normal --configuration Release --output /build/release

# containerize
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-alpine AS runtime
WORKDIR /app
COPY --from=build /build/release ./
ENTRYPOINT ["dotnet", "ci.build.sample.dll"]
