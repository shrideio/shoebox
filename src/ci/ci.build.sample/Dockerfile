# 1. Build the image
# sudo docker build -t hello-world .

# 2. Start a container
# sudo docker run -e HELLO_WORLD='Hello World!' -d -p 9880:80 hello-world

# 3. Pull the endpoint
# sudo curl http://localhost:9880/api/hello

FROM mcr.microsoft.com/dotnet/core/sdk:2.2-alpine AS build
WORKDIR /app

COPY tests/. ./build/tests/
COPY src/. ./build/src/

RUN for file in $(find ./build -name '*.fsproj'); do dotnet restore $file --verbosity normal; done

RUN dotnet test ./build/tests/**/*.fsproj --no-restore --verbosity normal
RUN dotnet publish ./build/src/ci.build.sample/ci.build.sample.fsproj --no-restore --verbosity normal -c Release -o /app/out

FROM mcr.microsoft.com/dotnet/core/aspnet:2.2-alpine AS runtime
WORKDIR /app
COPY --from=build /app/out ./
ENTRYPOINT ["dotnet", "ci.build.sample.dll"]