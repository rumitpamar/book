# FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
# COPY certificate.pfx /https/certificate.pfx
# WORKDIR /app

# ############################## Server build ################################
# FROM mcr.microsoft.com/dotnet/sdk:7.0 AS serverbuild
# WORKDIR /app
# COPY . .
# RUN dotnet publish /app/src/Acme.BookStore.HttpApi.Host/Acme.BookStore.HttpApi.Host.csproj -c Release -o /app/publish/host &&\
#     dotnet publish /app/src/Acme.BookStore.Web/Acme.BookStore.Web.csproj -c Release -o /app/publish/web &&\
#     dotnet publish /app/src/Acme.BookStore.AuthServer/Acme.BookStore.AuthServer.csproj -c Release -o /app/publish/auth &&\
#     dotnet publish /app/src/Acme.BookStore.DbMigrator/Acme.BookStore.DbMigrator.csproj -c Release -o /app/publish/mig

# FROM mcr.microsoft.com/dotnet/sdk:7.0 AS db-migration
# WORKDIR /app
# COPY --from=serverbuild /app/publish/mig .
# CMD ["dotnet", "Acme.BookStore.DbMigrator.dll"]

# # FROM mcr.microsoft.com/dotnet/sdk:7.0 AS db-migration
# # WORKDIR /app
# # COPY --from=serverbuild /app/publish/mig .
# # CMD ["dotnet", "Acme.BookStore.DbMigrator.dll"]

# # CMD ["dotnet", "Acme.BookStore.DbMigrator.dll"]


# FROM base AS backend
# WORKDIR /app
# COPY --from=serverbuild /app/publish/host .
# CMD ["dotnet", "Acme.BookStore.HttpApi.Host.dll"]

# FROM base AS frontend
# WORKDIR /app
# COPY --from=serverbuild /app/publish/web .
# CMD ["dotnet", "Acme.BookStore.Web.dll"]

# FROM base AS auth
# WORKDIR /app
# COPY --from=serverbuild /app/publish/auth .
# CMD ["dotnet", "Acme.BookStore.AuthServer.dll"]




# Stage 1: Base image
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
COPY certificate.pfx /https/certificate.pfx
WORKDIR /app

# Stage 2: Build image
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS serverbuild
WORKDIR /app
COPY . .
RUN dotnet publish /app/src/Acme.BookStore.HttpApi.Host/Acme.BookStore.HttpApi.Host.csproj -c Release -o /app/publish/host &&\
    dotnet publish /app/src/Acme.BookStore.Web/Acme.BookStore.Web.csproj -c Release -o /app/publish/web &&\
    dotnet publish /app/src/Acme.BookStore.AuthServer/Acme.BookStore.AuthServer.csproj -c Release -o /app/publish/auth &&\
    dotnet publish /app/src/Acme.BookStore.DbMigrator/Acme.BookStore.DbMigrator.csproj -c Release -o /app/publish/mig

# Stage 3: Migrator image
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS db-migration
WORKDIR /app
COPY --from=serverbuild /app/publish/mig .
CMD ["dotnet", "Acme.BookStore.DbMigrator.dll"]

# Stage 4: Backend image
FROM base AS backend
WORKDIR /app
COPY --from=serverbuild /app/publish/host .
CMD ["dotnet", "Acme.BookStore.HttpApi.Host.dll"]

# Stage 5: Frontend image
FROM base AS frontend
WORKDIR /app
COPY --from=serverbuild /app/publish/web .
CMD ["dotnet", "Acme.BookStore.Web.dll"]

# Stage 6: Auth image
FROM base AS auth
WORKDIR /app
COPY --from=serverbuild /app/publish/auth .
CMD ["dotnet", "Acme.BookStore.AuthServer.dll"]
