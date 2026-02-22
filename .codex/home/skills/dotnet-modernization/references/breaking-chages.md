# Breaking Changes Reference: .NET 4.x → .NET 8

## System.Web (Removed entirely)

| .NET 4.x | .NET 8 replacement |
|---|---|
| `System.Web.HttpContext` | `Microsoft.AspNetCore.Http.HttpContext` (via DI) |
| `HttpContext.Current` | `IHttpContextAccessor` injected via DI |
| `HttpRuntime.Cache` | `IMemoryCache` / `IDistributedCache` |
| `HttpResponse.End()` | `HttpContext.Abort()` |
| `Server.MapPath()` | `IWebHostEnvironment.WebRootPath` |
| `System.Web.UI.*` (WebForms) | Blazor / Razor Pages (rewrite required) |
| `Global.asax` | `Program.cs` + `WebApplication.CreateBuilder()` |
| `HttpHandler` / `IHttpHandler` | ASP.NET Core Middleware |
| `HttpModule` | ASP.NET Core Middleware |
| `Session["key"]` | `ISession` + `HttpContext.Session` |

## Configuration

| .NET 4.x | .NET 8 replacement |
|---|---|
| `ConfigurationManager.AppSettings["k"]` | `IConfiguration["k"]` |
| `ConfigurationManager.ConnectionStrings` | `IConfiguration.GetConnectionString()` |
| `web.config` / `app.config` | `appsettings.json` + env-specific overrides |
| Custom `ConfigurationSection` | Strongly-typed `IOptions<T>` |

## Threading

| .NET 4.x | .NET 8 replacement |
|---|---|
| `Thread.Abort()` | Cooperative cancellation via `CancellationToken` |
| `Thread.Suspend()` | Removed — redesign required |
| `AppDomain.CreateDomain()` | Single AppDomain only; use `AssemblyLoadContext` |

## Serialization

| .NET 4.x | .NET 8 replacement |
|---|---|
| `BinaryFormatter` | `System.Text.Json`, `MessagePack`, or `Protobuf` |
| `SoapFormatter` | `System.Text.Json` |
| `XmlSerializer` (most cases) | Unchanged — still works |
| `DataContractSerializer` | Mostly unchanged |

## Networking

| .NET 4.x | .NET 8 replacement |
|---|---|
| `WebClient` | `HttpClient` (prefer `IHttpClientFactory`) |
| `HttpWebRequest` | `HttpClient` |
| `ServicePointManager` | `SocketsHttpHandler` properties |
| `WCF client` | `System.ServiceModel.Http` NuGet (compatible) |
| `WCF server` | `CoreWCF` package or gRPC rewrite |

## Security

| .NET 4.x | .NET 8 replacement |
|---|---|
| `FormsAuthentication` | ASP.NET Core Identity / Cookie middleware |
| `RoleProvider` / `MembershipProvider` | ASP.NET Core Identity |
| `WindowsAuthenticationModule` | `UseWindowsAuthentication()` middleware |
| `MD5CryptoServiceProvider` (for passwords) | `BCrypt.Net` or PBKDF2 |

## Entity Framework

| .NET 4.x | .NET 8 replacement |
|---|---|
| EF 6.x | EF Core 8 (migration required; EDMX → code-first) |
| `ObjectContext` | `DbContext` |
| `EntityObject` | POCO classes |
| EDMX / designer | Code-first migrations |

## Common Compiler Errors After Upgrade

```
CS0246: The type or namespace 'HttpContext' could not be found
→ Remove `using System.Web;` — add `using Microsoft.AspNetCore.Http;`

CS0246: The type or namespace 'ConfigurationManager'
→ Add package: System.Configuration.ConfigurationManager (for compat shim)
   Or refactor to IConfiguration

CA2300: BinaryFormatter is insecure
→ Replace with System.Text.Json / MessagePack

NETSDK1045: Current .NET SDK does not support targeting .NET 8
→ Install .NET 8 SDK: https://dot.net/download