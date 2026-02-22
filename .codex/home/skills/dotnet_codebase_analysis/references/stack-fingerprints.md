# Extended Stack Fingerprint Reference

Supplement to the main scan in SKILL.md Step 2c.
Look up any `using` directive or base class not covered in the main skill.

---

## Web Frameworks

| Detected in source | Technology | .NET 8 target |
|---|---|---|
| `System.Web.Mvc` | ASP.NET MVC 5 | ASP.NET Core MVC |
| `System.Web.Http` | ASP.NET Web API 2 | ASP.NET Core controllers or Minimal API |
| `System.Web.UI` / `.aspx` files | WebForms | Blazor / Razor Pages (REWRITE) |
| `System.ServiceModel` | WCF | CoreWCF (server) / `System.ServiceModel.Http` (client) |
| `Microsoft.AspNet.SignalR` | SignalR 2 | ASP.NET Core SignalR |
| `Nancy` | Nancy framework | ASP.NET Core Minimal API |
| `ServiceStack` | ServiceStack | ServiceStack v8 (compatible) or ASP.NET Core |
| `Grpc.Core` | gRPC (legacy) | `Grpc.AspNetCore` |
| `Microsoft.Azure.Functions` | Azure Functions v1/v2 | Azure Functions v4 isolated worker |

---

## ORMs & Data Access

| Detected in source | Technology | .NET 8 target |
|---|---|---|
| `System.Data.Entity` / `DbContext` | Entity Framework 6 | EF Core 8 (REPLACE) |
| `NHibernate.ISession` | NHibernate | NHibernate 5.x (compatible, ADAPT) |
| `Dapper` | Dapper | Dapper 2.x (LIFT) |
| `PetaPoco` | PetaPoco | PetaPoco 6.x (compatible) |
| `LinqToSql` / `DataContext` | LINQ to SQL | EF Core (REPLACE) |
| `MongoDB.Driver` | MongoDB | MongoDB.Driver 2.x / 3.x (ADAPT) |
| `StackExchange.Redis` | Redis | StackExchange.Redis 2.x (LIFT) |
| `Cassandra.Data` | Apache Cassandra | CassandraCSharpDriver 3.x (ADAPT) |
| `Oracle.DataAccess` | Oracle ODP.NET | `Oracle.ManagedDataAccess.Core` (REPLACE) |
| `Npgsql` | PostgreSQL | Npgsql 8.x (ADAPT) |
| `MySql.Data` | MySQL | MySql.Data 8.x or Pomelo.EntityFrameworkCore.MySql |

---

## Authentication & Authorization

| Detected in source | Technology | .NET 8 target |
|---|---|---|
| `System.Web.Security.FormsAuthentication` | Forms auth | ASP.NET Core cookie auth |
| `Microsoft.AspNet.Identity` | ASP.NET Identity 2 | ASP.NET Core Identity (REPLACE) |
| `Microsoft.Owin.Security.OAuth` | OWIN OAuth 2 | ASP.NET Core OAuth / OIDC middleware |
| `IdentityServer3` | IdentityServer 3 | Duende IdentityServer 6/7 or OpenIddict |
| `System.IdentityModel.Tokens.Jwt` | JWT (old) | `Microsoft.IdentityModel.Tokens` + `System.IdentityModel.Tokens.Jwt` 7.x |
| `WindowsIdentity` / `Negotiate` | Windows auth | `UseWindowsAuthentication()` + Negotiate middleware |
| `Thinktecture.IdentityModel` | Thinktecture | `IdentityModel` 6.x by Duende |

---

## Dependency Injection Containers

| Detected in source | Technology | .NET 8 target |
|---|---|---|
| `Autofac.IContainer` | Autofac | Autofac 8.x + `Autofac.Extensions.DependencyInjection` |
| `IUnityContainer` | Unity | Built-in `IServiceCollection` (REPLACE) |
| `IKernel` (Ninject) | Ninject | Built-in DI (REPLACE) |
| `IWindsorContainer` | Castle Windsor | Windsor 5.x (compatible) or built-in DI |
| `IContainer` (StructureMap) | StructureMap | Lamar (successor) |
| `DependencyResolver.Current` | MVC DependencyResolver | Built-in DI in ASP.NET Core |

---

## Logging

| Detected in source | Technology | .NET 8 target |
|---|---|---|
| `log4net.ILog` | log4net | Serilog / `Microsoft.Extensions.Logging` + log4net appender |
| `NLog.ILogger` | NLog | NLog 5.x (compatible, LIFT) |
| `Common.Logging` | Common.Logging | `Microsoft.Extensions.Logging.Abstractions` |
| `Serilog.ILogger` | Serilog | Serilog 4.x (LIFT) |
| `Microsoft.Extensions.Logging` | MEL | Already target-compatible |

---

## Messaging & Background Processing

| Detected in source | Technology | .NET 8 target |
|---|---|---|
| `MassTransit.IBus` | MassTransit < 7 | MassTransit 8.x (significant API changes — ADAPT) |
| `NServiceBus.IBus` | NServiceBus | NServiceBus 8.x (compatible with adaptations) |
| `Rebus.IBus` | Rebus | Rebus 7.x (compatible) |
| `RabbitMQ.Client.IModel` | RabbitMQ direct | RabbitMQ.Client 6.x (LIFT) |
| `Azure.Messaging.ServiceBus` | Azure Service Bus (new) | Already compatible |
| `Microsoft.Azure.ServiceBus` | Azure Service Bus (old) | Migrate to `Azure.Messaging.ServiceBus` |
| `Hangfire` | Hangfire | Hangfire 1.8.x (LIFT) |
| `Quartz.IScheduler` | Quartz.NET | Quartz.NET 3.x (ADAPT) |

---

## Caching

| Detected in source | Technology | .NET 8 target |
|---|---|---|
| `HttpRuntime.Cache` | ASP.NET Cache | `IMemoryCache` |
| `System.Runtime.Caching.MemoryCache` | Object Cache | `IMemoryCache` (ADAPT) |
| `OutputCacheAttribute` (MVC) | Output cache | ASP.NET Core Output Cache middleware |
| `StackExchange.Redis` | Distributed cache | `IDistributedCache` + StackExchange.Redis |

---

## Mapping & Validation

| Detected in source | Technology | .NET 8 target |
|---|---|---|
| `AutoMapper.IMapper` | AutoMapper | AutoMapper 13.x (LIFT, watch for LINQ projection changes) |
| `Mapster` | Mapster | Mapster 7.x (LIFT) |
| `FluentValidation.AbstractValidator` | FluentValidation | FluentValidation 11.x (LIFT) |
| `DataAnnotations.ValidationAttribute` | Data Annotations | Still valid in .NET 8 |

---

## File / Cloud Storage

| Detected in source | Technology | .NET 8 target |
|---|---|---|
| `Microsoft.WindowsAzure.Storage` | Azure Storage (old) | `Azure.Storage.Blobs` (REPLACE) |
| `Amazon.S3` | AWS SDK v2 | AWS SDK v4 (ADAPT) |
| `System.IO.Compression` | ZIP handling | Unchanged |
| `Microsoft.Office.Interop` | Office COM | `DocumentFormat.OpenXml` / ClosedXML (REPLACE) |
| `System.Drawing` (server-side) | GDI+ | SkiaSharp or ImageSharp (REPLACE) |

---

## Testing

| Detected in source | Technology | .NET 8 target |
|---|---|---|
| `NUnit.Framework` | NUnit 2/3 | NUnit 4.x (ADAPT — some attributes changed) |
| `Xunit.Fact` / `Xunit.Theory` | xUnit | xUnit 2.x (LIFT) |
| `Microsoft.VisualStudio.TestTools` | MSTest | MSTest 3.x (ADAPT) |
| `Moq.Mock<T>` | Moq | Moq 4.20.x (LIFT) |
| `NSubstitute` | NSubstitute | NSubstitute 5.x (LIFT) |
| `FakeItEasy` | FakeItEasy | FakeItEasy 8.x (LIFT) |
| `FluentAssertions` | FluentAssertions | FluentAssertions 7.x (ADAPT — breaking changes in v7) |
| `Bogus` | Bogus | Bogus 35.x (LIFT) |
| `WireMock.Net` | WireMock | WireMock.Net 1.x (LIFT) |
| `Microsoft.AspNetCore.TestHost` | TestServer | Still valid in .NET 8 |