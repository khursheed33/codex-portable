---
name: dotnet_codebase_analysis
description: >
  Deep-scan a .NET 4.x codebase to identify tech stack, frameworks, databases,
  authentication patterns, third-party integrations, and architectural style.
  Then read target_structure.txt and produce a concrete mapping of every source
  component to its destination in the new architecture, plus a prioritized
  migration change plan. Use this skill whenever the user says "analyze the
  codebase", "scan the project", "what stack are we on", "where do we start",
  "assess the project", "what needs to change", or "map to the new structure".
  Always run this skill FIRST on any new migration engagement, before
  dependency_graph_identification or migration_steps.
---

# Skill: codebase_analysis

Produces a complete picture of what exists, what the target looks like, and
exactly what changes are required — before a single line of code is touched.

---

## Step 0 — Think first

Call `sequential-thinking` MCP with:
- The root path of the source repo
- Whether `target_structure.txt` is present and its location
- The user's stated goal (full migration? incremental? strangler-fig?)

Use its output to decide scan depth and reporting format.

---

## Step 1 — Locate and read target_structure.txt

```
Search order:
  1. Repo root: ./target_structure.txt
  2. Docs folder: ./docs/target_structure.txt
  3. .codex folder: ./.codex/target_structure.txt
  4. Ask the user for the path if not found
```

Use `filesystem` MCP to read the file in full.

Parse it for:
- **Project / layer names** (e.g., `MyApp.Api`, `MyApp.Domain`, `MyApp.Infrastructure`)
- **Folder structure** (namespace hierarchy, feature slices, layer boundaries)
- **Explicit technology callouts** (e.g., "uses MediatR", "Postgres via EF Core", "gRPC")
- **Architectural pattern** — detect from structure:
  - Clean Architecture (Domain / Application / Infrastructure / Presentation)
  - Vertical Slice (Features/{FeatureName}/...)
  - Modular Monolith (Modules/{ModuleName}/...)
  - Microservices (one repo per service)
  - Layered / N-Tier (classic MVC + DAL)

Store the parsed target as a structured map. All subsequent steps reference it.

---

## Step 2 — Scan the source codebase

Use `filesystem` MCP to read each file category below. Work through them in order.

### 2a. Solution & projects
```
Read: *.sln
      **/*.csproj
      **/packages.config

Extract per project:
  - Name, path, type (Web / Library / Console / Test / WCF / WinForms / WPF)
  - <TargetFrameworkVersion> or <TargetFramework>
  - <ProjectReference> list
  - <PackageReference> / packages.config entries
```

### 2b. Entry points & hosting
```
Read: Global.asax, Global.asax.cs
      Startup.cs (OWIN)
      Web.config, App.config
      Program.cs (if any)

Identify:
  - Hosting model (IIS / OWIN self-host / Windows Service / Console)
  - HTTP pipeline setup (modules, handlers, routes)
  - DI container registration (Autofac, Unity, Ninject, Windsor, none)
  - Configuration sources
```

### 2c. Tech stack fingerprinting
```
Scan *.cs, *.cshtml, *.aspx for using directives and base classes.

Framework layer — detect any of:
  System.Web.Mvc            → ASP.NET MVC
  System.Web.Http           → ASP.NET Web API
  System.Web.UI             → WebForms
  System.ServiceModel       → WCF
  Microsoft.AspNet.SignalR  → SignalR 2
  System.Web.Optimization   → Bundling

ORM / data access:
  using System.Data.Entity  → Entity Framework 6
  DbContext subclass        → EF 6
  using Dapper              → Dapper
  NHibernate.ISession       → NHibernate
  SqlConnection / SqlCommand → raw ADO.NET
  IMongoCollection<T>       → MongoDB driver
  IDatabase (StackExchange) → Redis

Database indicators (also check connection strings in web.config):
  Data Source= / Server=    → SQL Server
  Host= / Port=5432         → PostgreSQL
  mongodb://                → MongoDB
  redis://                  → Redis
  Data Source=*.db          → SQLite
  OracleConnection          → Oracle

Auth / identity:
  FormsAuthentication       → Forms auth
  WindowsIdentity           → Windows auth
  OAuthAuthorizationServer  → OAuth 2 (OWIN)
  Microsoft.AspNet.Identity → ASP.NET Identity 2
  ClaimsPrincipal           → Claims-based

Messaging / async:
  IBus (MassTransit/NServiceBus) → service bus
  IModel (RabbitMQ)              → RabbitMQ direct
  CloudQueueClient               → Azure Storage Queue

Cross-cutting:
  ILog / LogManager (log4net) → log4net
  ILogger (NLog)              → NLog
  AutoMapper.IMapper          → AutoMapper
  FluentValidation            → FluentValidation
  Polly                       → Polly
```

### 2d. Database schema discovery
```
Read: **/Migrations/**/*.cs    (EF code-first migrations)
      **/Models/*.cs            (entity classes)
      **/Entities/*.cs
      **/*.edmx                 (EF designer — list entity sets)
      **/Stored Procedures/**   (if SQL scripts present)
      web.config <connectionStrings>

Produce:
  - Database engine(s) and connection string patterns
  - ORM approach (code-first / DB-first / raw)
  - Approximate entity/table count
  - Notable patterns: soft delete, audit columns, multi-tenancy, row versioning
```

### 2e. API surface
```
Read all controllers: **/*Controller.cs

For each controller:
  - Base class (ApiController = Web API, Controller = MVC)
  - Route pattern ([Route], RouteConfig, attribute vs convention)
  - Auth attributes ([Authorize], roles, policies)
  - Request/response types

Produce:
  - Total endpoint count
  - Auth coverage (% of endpoints protected)
  - Notable patterns (file upload, streaming, versioning)
```

### 2f. Test coverage
```
Read: **/*Tests*/*.csproj   (test projects)
      **/*Test.cs, **/*Tests.cs, **/*Spec.cs

Identify:
  - Test framework (NUnit / xUnit / MSTest)
  - Mock framework (Moq / NSubstitute / Rhino)
  - Approximate test count (line count heuristic: divide file lines by ~10)
  - Test categories present (unit / integration / e2e)
```

---

## Step 3 — Map source → target

For every source component identified in Step 2, assign it a destination in the
target structure from Step 1.

Use this template per component:

```
SOURCE                         → TARGET
------------------------------   ------------------------------------
MyApp.Web (MVC controllers)    → MyApp.Api / Controllers/
MyApp.Web (Startup/DI)         → MyApp.Api / Program.cs
MyApp.Business (services)      → MyApp.Application / Features/{Name}/
MyApp.Business (interfaces)    → MyApp.Domain / Abstractions/
MyApp.Data (DbContext)         → MyApp.Infrastructure / Persistence/
MyApp.Data (repositories)      → MyApp.Infrastructure / Repositories/
MyApp.Data (Migrations)        → MyApp.Infrastructure / Migrations/
MyApp.Domain (entities)        → MyApp.Domain / Entities/
Web.config auth                → MyApp.Api / Program.cs (auth middleware)
Web.config connection strings  → appsettings.json + IConfiguration
log4net                        → Serilog / ILogger<T>
AutoMapper profiles            → MyApp.Application / Mappings/
```

If the target structure has no clear home for something, flag it as:
`⚠️ UNMAPPED — needs placement decision`

---

## Step 4 — Classify required changes

For every mapped component, assign a change type:

| Type | Meaning |
|---|---|
| `LIFT` | Move file, update namespace, adjust `using` — no logic change |
| `ADAPT` | Logic is correct but API surface changes (e.g., base class swap) |
| `REPLACE` | Same capability, entirely different implementation (e.g., EF6→EF Core) |
| `REWRITE` | No equivalent pattern in target; must be redesigned (e.g., WebForms pages) |
| `DELETE` | No longer needed in new architecture (e.g., Global.asax, packages.config) |

---

## Step 5 — Prioritize the migration backlog

Use `sequential-thinking` to validate this ordering:

```
Priority 1 — Foundation (do first, everything depends on these)
  - Domain entities and interfaces (LIFT or ADAPT)
  - New project scaffold matching target_structure.txt
  - EF Core DbContext + Migrations baseline
  - DI setup in Program.cs

Priority 2 — Core logic
  - Application services / use cases / handlers
  - Repository implementations
  - Shared utilities and cross-cutting concerns (logging, validation)

Priority 3 — API surface
  - Controllers → minimal API or controller-based
  - Auth middleware
  - Request/response DTOs and validators

Priority 4 — Infrastructure
  - External integrations (messaging, caches, email)
  - Background jobs

Priority 5 — Tests
  - Update test projects to net8.0
  - Fix broken tests arising from refactor
  - Add missing coverage for rewritten components

Priority 6 — UI (if applicable)
  - WebForms / MVC views → Blazor / Razor Pages (rewrite)
```

Within each priority group, order by: LIFT → ADAPT → REPLACE → REWRITE.

---

## Step 6 — Produce ANALYSIS_REPORT.md

Write to repo root. Structure:

```markdown
# Codebase Analysis Report

Generated: <date>
Source TFM: net4x  →  Target TFM: net8.0

## Tech Stack Summary
[table: layer → technology]

## Database Summary
[engine, ORM, entity count, migration status]

## API Surface
[endpoint count, auth coverage, route patterns]

## Test Coverage Baseline
[test count estimate, frameworks, gaps]

## Source → Target Component Map
[full table from Step 3]

## Change Classification Summary
[count of LIFT / ADAPT / REPLACE / REWRITE / DELETE]

## Migration Backlog (prioritized)
[numbered list from Step 5]

## Risk Flags
[items marked REWRITE or UNMAPPED, with notes]
```

---

## Step 7 — Handoff to next skills

After report is written, tell the user:

```
Analysis complete. Suggested next steps:

1. Review ANALYSIS_REPORT.md — confirm the source→target mapping and backlog.
2. Run `dependency_graph_identification` skill to validate project build order.
3. Begin migration with `migration_steps` skill starting at Priority 1 items,
   using target_structure.txt as the structural guide for all new files.
```

Do not begin migration automatically. The user must confirm the report first.

---

## Reference files

- `references/arch-patterns.md` — How to detect and map Clean Architecture,
  Vertical Slice, Modular Monolith, and N-Tier patterns.
- `references/stack-fingerprints.md` — Extended using-directive → technology
  lookup table for less common packages.