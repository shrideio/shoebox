FROM mcr.microsoft.com/dotnet/core/sdk:2.2-alpine AS build
WORKDIR /app

COPY src/. ./build/src/
COPY test/. ./build/test/

WORKDIR /app/build/test
RUN dotnet test