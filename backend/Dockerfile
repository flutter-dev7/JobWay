# ---- Build stage ----
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Копируем только csproj-файлы сначала — для кэширования restore
COPY src/JobWay.API/JobWay.API.csproj src/JobWay.API/
COPY src/JobWay.Application/JobWay.Application.csproj src/JobWay.Application/
COPY src/JobWay.Domain/JobWay.Domain.csproj src/JobWay.Domain/
COPY src/JobWay.Infrastructure/JobWay.Infrastructure.csproj src/JobWay.Infrastructure/

RUN dotnet restore src/JobWay.API/JobWay.API.csproj

# Теперь копируем весь остальной код
COPY src/ src/

WORKDIR /src/src/JobWay.API
RUN dotnet publish -c Release -o /app/publish --no-restore

# ---- Runtime stage ----
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

# Render прокидывает порт через переменную PORT
ENV ASPNETCORE_URLS=http://+:${PORT:-8080}
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "JobWay.API.dll"]
