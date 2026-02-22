---
name: compilation_running_fixing
description: >
  Diagnose and fix .NET build errors, runtime exceptions, test failures, and startup
  crashes that occur during or after a .NET 4.x → .NET 8/10 migration. Use this skill
  whenever the user shares a build error, compiler warning, stack trace, test failure,
  or says "it won't compile", "broken build", "can't run", "tests failing", or pastes
  error output. Also triggers when the user asks how to run the migrated app for the
  first time. Always activate before attempting any fix.
---

# Skill: compilation_running_fixing

Systematic approach to diagnosing and resolving build and runtime issues post-migration.

## Step 0 — Reason before fixing

Call `sequential-thinking` MCP with:
- The raw error text
- Which project/file it originates from
- What was last changed before the error appeared

Do not guess. Let sequential-thinking identify the root cause category before touching code.

## Step 1 — Classify the error

Read the full error output. Classify into one of:

| Category | Indicators |
|---|---|
| **Missing type / namespace** | `CS0246`, `CS0234`, `are you missing a using directive?` |
| **Removed API** | Known .NET 4.x-only API, `does not contain a definition for` |
| **Package not found** | `NU1101`, `Unable to find package`, `Could not resolve` |
| **SDK / TFM mismatch** | `NETSDK1045`, `NETSDK1005`, `targets .NETFramework` |
| **Ambiguous reference** | `CS0104`, two assemblies define the same type |
| **Nullable warning as error** | `CS8600`, `CS8602`, `CS8603`, `CS8618` |
| **Runtime exception** | Stack trace in output; app starts but crashes |
| **Test failure** | `FAILED` in `dotnet test` output |

## Step 2 — Gather context

Use `filesystem` MCP to read:
- The file referenced in the error
- The `.csproj` of that project (check `<TargetFramework>`, `<PackageReference>` list)
- `global.json` if present (SDK version pinning)

Use `context7` MCP to look up:
- The specific error code + "net8" to find official guidance
- The offending API to find its replacement

## Step 3 — Fix by category

### Missing type / namespace
```
1. Check if the type moved to a new namespace → update `using`
2. Check if it's in a NuGet package → `dotnet add package <pkg>`
3. If System.Web.* → consult breaking-changes reference in migration_steps skill
```

### Removed API
```
1. Identify the .NET 8 replacement (context7 MCP or breaking-changes.md)
2. Show the replacement code to user before applying
3. Apply targeted fix — do not refactor surrounding code
```

### Package not found
```
1. Check package name on nuget.org (context7 or web search)
2. Check if package has a .NET 8 compatible version
3. If not → check package-replacements.md in migration_steps skill
4. dotnet add package <correct-package> --version <latest-stable>
```

### SDK / TFM mismatch
```
# Verify installed SDKs
dotnet --list-sdks

# If .NET 8 SDK missing → user must install from https://dot.net/download

# Check global.json isn't pinning an old SDK version
cat global.json

# Ensure .csproj has correct TFM
<TargetFramework>net8.0</TargetFramework>   ✓
<TargetFramework>net48</TargetFramework>    ✗ (not migrated yet)
```

### Nullable warnings as errors
```csharp
// Option A — fix the nullability (preferred)
string name = GetName() ?? throw new InvalidOperationException("name required");

// Option B — suppress project-wide if too noisy during migration
<Nullable>enable</Nullable>
<WarningsAsErrors>Nullable</WarningsAsErrors>   ← remove this line temporarily
```

### Runtime exception
```
1. Read full stack trace — identify the top frame in user's code
2. Use filesystem MCP to read that file
3. Check if it's a DI registration issue (common: services not registered in Program.cs)
4. Check if it's a missing appsettings.json key (NullReferenceException on IConfiguration)
5. Check if middleware order is wrong (UseRouting before UseAuthorization, etc.)
```

### Test failures
```
1. Run: dotnet test --logger "console;verbosity=detailed"
2. Read the failure message and stack trace
3. Check if test project TFM is net8.0
4. Check for test infrastructure issues (WebApplicationFactory, TestServer setup)
5. Fix one test at a time; do not mass-edit
```

## Step 4 — Apply and verify

For every fix:
1. Show the diff to the user before applying
2. Apply the minimal change — do not refactor scope beyond the error
3. Run `dotnet build` after each fix
4. If build passes, run `dotnet test`
5. If new errors appear, return to Step 1 with the new error

## Step 5 — Document

If the fix addresses a systemic pattern (e.g., every project uses `HttpContext.Current`):
- Note the pattern in `MIGRATION_LOG.md`
- Suggest a search across the solution: `grep -rn "HttpContext.Current" --include="*.cs"`

## Running the migrated app for the first time

```bash
# Restore + build
dotnet restore
dotnet build --configuration Release

# Run (web app)
dotnet run --project src/MyApp.Web

# Run (console)
dotnet run --project src/MyApp.Console

# Run with watch (dev)
dotnet watch --project src/MyApp.Web

# Common first-run issues:
# - Port conflicts → change in launchSettings.json
# - Missing appsettings.json → copy from appsettings.example.json
# - DB migration needed → dotnet ef database update