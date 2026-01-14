# Build stage
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["ZavaStorefront.csproj", "./"]
RUN dotnet restore "ZavaStorefront.csproj"

# Copy remaining source code and build
COPY . .
RUN dotnet build "ZavaStorefront.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "ZavaStorefront.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS final
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Create non-root user for security
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ZavaStorefront.dll"]
