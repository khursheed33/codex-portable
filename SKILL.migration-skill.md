---
name: migration_steps
description: >
  Step-by-step .NET 4.x → .NET 8/10 migration planning and execution. Use this skill
  whenever the user mentions migrating, upgrading, porting, or modernizing a .NET
  Framework project. Also triggers for questions about TFM changes, SDK-style projects,
  web.config → appsettings, WCF, WebForms, System.Web removal, or any request to
  "start the migration". Always activate for migration roadmap or assessment requests.
---

# Skill: migration_steps

Guides the full lifecycle of upgrading a .NET 4.x codebase to .NET 8/10.

## Step 0 — Orient with sequential-thinking

Before anything else, call the `sequential-thinking` MCP tool with:
- What is being migrated (app type, size estimate)
- Known constraints (deadline, team size, can-rewrite vs must-preserve)

Use its output to shape the plan below.

## Step 1 — Assess the solution

```
1. Read the .sln file → list all projects and types
2. For each .csproj:
   - Check <TargetFrameworkVersion> (net4x) or <TargetFramework>
   - Identify project type: Web (System.Web), WinForms, WPF, Class Library, Console, WCF, Test
   - Note packages.config vs PackageReference
3. Flag high-risk project types:
   - System.Web / WebForms → no direct equivalent; needs Blazor or Razor Pages port
   - WCF server → needs CoreWCF or gRPC rewrite
   - COM Interop → Windows-only on .NET 8
   - HttpContext.Current → must refactor to DI
```

Use the `filesystem` MCP to read `.csproj`, `.sln`, `packages.config`, `web.config`.  
Use `context7` MCP to verify compatibility status of any identified dependency.

## Step 2 — Build the migration order

Apply this ordering heuristic (use `sequential-thinking` to validate):

```
1. Shared/utility class libraries (fewest dependencies)
2. Domain / core logic libraries
3. Infrastructure libraries (data access, messaging)
4. API / service hosts
5. UI projects last (most breaking)
```

Output a numbered migration sequence with rationale.

## Step 3 — Upgrade each project

For each project in order:

### 3a. Convert project file to SDK style
```xml
<!-- FROM -->
<Project ToolsVersion="15.0" ...>
  ...hundreds of lines...

<!-- TO -->
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
</Project>
```
Remove: `packages.config`, `AssemblyInfo.cs` (move attributes to csproj), `<Reference>` blocks replaced by `<PackageReference>`.

### 3b. Update NuGet packages
- Run dependency identification skill first (see `dependency_graph_identification`)
- Replace unmaintained packages using the compatibility table in `references/package-replacements.md`
- Prefer `dotnet add package` over manual edits

### 3c. Fix breaking API changes
Consult `references/breaking-changes.md` for common patterns.  
Key areas: `System.Web`, `HttpContext`, `ConfigurationManager`, `Thread.Abort`, `BinaryFormatter`.

### 3d. Migrate configuration
```
web.config / app.config  →  appsettings.json + IConfiguration
connection strings       →  IConfiguration["ConnectionStrings:X"]  
custom config sections   →  strongly-typed Options classes
```

### 3e. Update DI / startup
```
Global.asax / Startup.cs (OWIN)  →  Program.cs minimal hosting model
HttpModule / HttpHandler         →  ASP.NET Core Middleware
```

## Step 4 — Validate

After each project migration:
1. `dotnet build` — zero errors required before proceeding
2. `dotnet test` — all existing tests must pass
3. Log result in `MIGRATION_LOG.md`

If build fails, **stop and invoke the `compilation_running_fixing` skill**.

## Step 5 — Log the change

Append to `MIGRATION_LOG.md`:
```markdown
## [ProjectName] — migrated YYYY-MM-DD
- TFM: net4x → net8.0
- Packages updated: X
- Breaking changes addressed: Y
- Tests: passing / N failures (link to CI run)
```

## Reference files

- `references/breaking-changes.md` — Common API removals and their replacements
- `references/package-replacements.md` — NuGet package compatibility & alternatives
