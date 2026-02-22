# Architecture Pattern Reference

How to detect target architecture from `target_structure.txt` and map source components correctly.

---

## Pattern Detection Heuristics

Scan `target_structure.txt` for these folder/project name signals:
TODO:: full path to target_structure.txt
---

## Unmapped Component Handling

When a source component has no clear target home:

1. Check if the target_structure.txt has a `Common/`, `Shared/`, or `CrossCutting/` folder → default landing zone
2. If not, flag with `⚠️ UNMAPPED` and include a placement recommendation:
   - Utility/helper classes → suggest `Common/`
   - Background jobs → suggest adding `BackgroundJobs/` or `Workers/` to target
   - Scheduled tasks → suggest `Infrastructure/BackgroundServices/`
3. Never silently discard — everything must have a destination or an explicit delete decision

---

## Anti-patterns to flag during mapping

| Anti-pattern | How to detect | Recommendation |
|---|---|---|
| God class | Single class >500 lines or >20 public methods | Split before migrating |
| Circular project refs | A → B → A in dependency graph | Extract shared interface to new project |
| Business logic in controllers | Controller methods >30 lines with data manipulation | Extract to service/handler during ADAPT |
| Direct DbContext in controllers | `using (var db = new AppDbContext())` in controller | Move to repository pattern |
| Static service locator | `ServiceLocator.Current.GetInstance<T>()` | Replace with constructor DI |
| Hardcoded connection strings in code | `new SqlConnection("Server=prod...")` | Move to IConfiguration |