# 1. Build the image
# sudo docker build --build-arg PACKAGES_SOURCE=[packages-source] --build-arg PACKAGES_USERNAME=[packages-username] --build-arg PACKAGES_PASSWORD=[packages-password] -t hello-world .

# 2. Start a container
# sudo docker run -e HELLO_WORLD='Hello World!' -d -p 9880:80 hello-world

# 3. Pull the endpoint
# sudo curl http://localhost:9880/api/hello


FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine AS build
WORKDIR /build

ARG PACKAGES_SOURCE
ARG PACKAGES_USERNAME
ARG PACKAGES_PASSWORD

COPY tests/. ./tests/
COPY src/. ./src/

# build
RUN dotnet nuget add source $PACKAGES_SOURCE --name $PACKAGES_SOURCE --username $PACKAGES_USERNAME --password $PACKAGES_PASSWORD --store-password-in-clear-text
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