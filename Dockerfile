# Use .NET SDK for building the application
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine as build

# Set working directory
WORKDIR /app

# Copy only the project file and restore dependencies
COPY *.csproj ./
RUN dotnet restore

# Copy the rest of the application code and publish
COPY . ./
RUN dotnet publish -c Release -o /app/published-app

# Use a runtime image for running the application
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine as runtime

# Set working directory
WORKDIR /app

# Copy the published app from the build image
COPY --from=build /app/published-app /app

# Expose port 5000
EXPOSE 5000

# Set the ASP.NET Core URL environment variable
ENV ASPNETCORE_URLS=http://+:5000

# Add a non-root user and change ownership
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

# Define the entry point for the container
ENTRYPOINT ["dotnet", "IBASEmployeeService.dll"]
