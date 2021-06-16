FROM mcr.microsoft.com/dotnet/runtime:3.1 AS base
WORKDIR /app

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
# RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
# USER appuser

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["AzCliCred.csproj", "./"]
RUN dotnet restore "AzCliCred.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "AzCliCred.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "AzCliCred.csproj" -c Release -o /app/publish

FROM base AS final

RUN rm /usr/bin/dotnet

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        \
        # .NET dependencies
        libc6 \
        libgcc1 \
        libgssapi-krb5-2 \
        libssl1.1 \
        libstdc++6 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin -Channel 5.0 -Runtime dotnet -InstallDir /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "AzCliCred.dll"]
