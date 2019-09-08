FROM mcr.microsoft.com/dotnet/core/sdk:2.2-alpine AS build
WORKDIR /app

COPY src/. ./build/src/
COPY tests/. ./build/tests/

WORKDIR /app/build/tests
RUN dotnet test **/*.fsproj
