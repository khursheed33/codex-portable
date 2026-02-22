# NuGet Package Replacements: .NET 4.x → .NET 8

## Logging

| Old package | .NET 8 replacement |
|---|---|
| `log4net` | `Microsoft.Extensions.Logging` + `Serilog` or keep log4net (compatible) |
| `NLog` | NLog 5.x (compatible with .NET 8) |
| `Common.Logging` | `Microsoft.Extensions.Logging.Abstractions` |
| `elmah` | `Serilog.Sinks.File` + `Serilog.AspNetCore` |

## Dependency Injection

| Old package | .NET 8 replacement |
|---|---|
| `Autofac` | Autofac 7.x + `Autofac.Extensions.DependencyInjection` |
| `Unity` | `Microsoft.Extensions.DependencyInjection` (built-in) |
| `Ninject` | Built-in DI or Autofac |
| `StructureMap` | `Lamar` (successor) or built-in DI |
| `Castle.Windsor` | Castle.Windsor 5.x (compatible) |

## ORM / Data Access

| Old package | .NET 8 replacement |
|---|---|
| `EntityFramework` (EF6) | `Microsoft.EntityFrameworkCore` 8.x |
| `Dapper` | Dapper 2.x (compatible, no changes needed) |
| `NHibernate` | NHibernate 5.x (compatible) |
| `System.Data.SqlClient` | `Microsoft.Data.SqlClient` 5.x |

## Web / HTTP

| Old package | .NET 8 replacement |
|---|---|
| `Microsoft.AspNet.Mvc` | `Microsoft.AspNetCore.Mvc` (built-in SDK) |
| `Microsoft.AspNet.WebApi` | `Microsoft.AspNetCore` controllers |
| `Microsoft.Owin` / `Owin` | ASP.NET Core pipeline (no Owin needed) |
| `RestSharp` < 107 | RestSharp 110+ (breaking changes in API) |
| `Flurl` | Flurl 3.x (compatible) |

## Serialization

| Old package | .NET 8 replacement |
|---|---|
| `Newtonsoft.Json` | Keep (compatible) or migrate to `System.Text.Json` |
| `protobuf-net` | protobuf-net 3.x (compatible) |
| `MessagePack` | MessagePack 2.x (compatible) |

## Messaging / Background Jobs

| Old package | .NET 8 replacement |
|---|---|
| `Hangfire` | Hangfire 1.8.x (compatible) |
| `Quartz.NET` | Quartz.NET 3.x (compatible) |
| `MassTransit` < 7 | MassTransit 8.x (significant API changes) |
| `RabbitMQ.Client` | RabbitMQ.Client 6.x (compatible) |

## Testing

| Old package | .NET 8 replacement |
|---|---|
| `NUnit` | NUnit 4.x (compatible) |
| `xUnit` | xUnit 2.x (compatible) |
| `MSTest.TestFramework` < 2 | MSTest 3.x |
| `Moq` | Moq 4.18+ (compatible) |
| `NSubstitute` | NSubstitute 5.x (compatible) |

## Security / Auth

| Old package | .NET 8 replacement |
|---|---|
| `Microsoft.Owin.Security` | `Microsoft.AspNetCore.Authentication` |
| `IdentityServer3` | `Duende.IdentityServer` or `OpenIddict` |
| `DotNetOpenAuth` | `IdentityModel` + ASP.NET Core auth |

## ⚠️ No Compatible Replacement (manual rewrite required)

| Old package | Action |
|---|---|
| `Microsoft.Reporting.WebForms` | Use FastReport, SSRS REST API, or Crystal Reports alternative |
| `System.Drawing` (server GDI+) | `SkiaSharp` or `ImageSharp` |
| `Microsoft.Web.Infrastructure` | Remove — no longer needed |
| `Telerik.Web.UI` (WebForms) | Migrate to Telerik Blazor components |
| `DevExpress.Web` (WebForms) | Migrate to DevExpress Blazor components |