# Writing Tool Descriptions

The `description` property on a `Tool` is injected into the LLM's system prompt. A well-written description is the single most important factor in whether the model calls your tool correctly.

## Header Hierarchy

`formatToolInstructions` renders each tool as a `## ToolName` header in the system prompt:

```markdown
## Read

[description content here]

```json
[parameters schema]
```
```

Because the tool name occupies `##` (h2), any markdown headers inside your `description` must use `###` (h3) or lower. Using `##` inside a description would create a sibling header to the tool name, breaking the document structure.

```swift
// Good — h3 inside description
"""
Executes a shell command with optional timeout.

### Safety
- NEVER run destructive commands without permission

### Committing changes with git
1. Run git status...
"""

// Bad — h2 inside description (conflicts with tool name header)
"""
Executes a shell command with optional timeout.

## Safety
- NEVER run destructive commands without permission
"""
```

## Anatomy of a Tool Description

```
[1-sentence summary — what the tool does, declaratively]

[Optional: Scope boundary — IMPORTANT: what this tool is NOT for]

Usage:
- [Capabilities with inline examples]
- [ALWAYS/NEVER behavioral directives]
- [Cross-tool references — use X instead of Y for Z]
- [Limitations — embedded as bullets, not a separate section]
- [FAIL conditions with recovery strategies]

[Optional: When NOT to use — only for tools with ambiguous scope]
```

Complexity scales with the tool: simple tools use a flat bullet list; complex tools add numbered procedures and sub-sections.

### 1. Opening Summary

One declarative sentence stating what the tool does. No adjectives, no marketing.

```swift
// Good
"Reads a file from the local filesystem."
"Performs exact string replacements in files."
"A powerful search tool built on ripgrep."

// Bad — too vague
"A file utility tool."
// Bad — too verbose
"This tool provides comprehensive file reading capabilities with support for..."
```

### 2. Scope Boundary

For tools that are commonly confused with others, add an `IMPORTANT:` block immediately after the summary that states what the tool is *not* for and redirects to the correct tool.

```swift
"""
Executes a shell command with optional timeout.

IMPORTANT: This tool is for terminal operations like git, npm, swift build, etc.
Do NOT use it for file operations - use the specialized tools instead:
- To read files use Read instead of cat, head, tail
- To edit files use Edit instead of sed or awk
- To search for files use Glob instead of find or ls
- To search the content of files use Grep instead of grep or rg
"""
```

This routing table pattern prevents the model from defaulting to a general-purpose tool (Bash) when a specialized tool exists.

### 3. Usage Section

Bullet-pointed instructions covering capabilities, constraints, and behavior rules. This is the core section — every tool needs it.

```swift
"""
Usage:
- The file_path parameter supports absolute paths, relative paths, or ~/ paths
- By default, it reads up to 2000 lines starting from the beginning of the file
- You can optionally specify a line offset and limit
- Any lines longer than 2000 characters will be truncated
- This tool can only read files, not directories
- NEVER use the Bash tool with cat, head, or tail to read files. ALWAYS use this tool instead
- Maximum file size: 1MB, UTF-8 text files only
"""
```

### 4. Behavioral Directives

Use directive keywords to express mandatory rules. The hierarchy from strongest to weakest:

| Keyword | Strength | When to Use |
|---------|----------|-------------|
| `CRITICAL` | Highest | Absolute requirements with no exceptions |
| `IMPORTANT` | High | Strong directives, often at the start of a block |
| `MUST` | High | Obligations the model cannot skip |
| `ALWAYS` / `NEVER` | Medium-high | Consistent behavior mandates |
| `DO NOT` | Medium | Prohibitions |
| *(no keyword)* | Low | Suggestions and guidance |

Pair `ALWAYS` and `NEVER` as opposites within the same bullet for maximum clarity:

```swift
"- ALWAYS prefer editing existing files. NEVER write new files unless explicitly required"
```

### 5. Cross-Tool References

Three reference patterns:

**Routing table** — For tools that overlap with multiple others (e.g., Bash):
```
- To read files use Read instead of cat, head, tail
- To edit files use Edit instead of sed or awk
```

**Prerequisite** — For tools that require another tool first (e.g., Edit, Write):
```
- You MUST use the Read tool at least once before editing a file
```

**Escalation** — For tools that should redirect to a more capable tool (e.g., Glob → Dispatch):
```
- When you need an open-ended search requiring multiple rounds, use Dispatch instead
```

### 6. Error Cases

Document failure conditions using capitalized `FAIL` and immediately provide a recovery strategy:

```swift
"- The edit will FAIL if old_string is not unique in the file. Either provide a larger string with more surrounding context to make it unique, or use replace_all=true"
```

### 7. Safety Protocols

For tools that can perform destructive operations, add explicit `NEVER` directives:

```swift
"""
Safety:
- NEVER run destructive commands (push --force, reset --hard, clean -f) without explicit user permission
- NEVER skip hooks (--no-verify) unless explicitly requested
- ALWAYS create NEW commits rather than amending, unless explicitly requested
"""
```

### 8. Structured Content with XML Tags

Use XML-like tags wrapped in backticks to create semantic boundaries within descriptions. While markdown headers (`###`, `####`) organize content hierarchically, backtick-escaped XML tags label the **role** of a content block — what it *is*, not where it sits in the outline.

| Tag | Purpose |
|-----|---------|
| `` `<example>` `` | Complete interaction scenario (user input → model behavior) |
| `` `<reasoning>` `` | Meta-explanation of why an example behaves that way |
| `` `<good-example>` `` / `` `<bad-example>` `` | Labeled correct vs incorrect usage snippets |
| `` `<commentary>` `` | Internal decision-making the model should follow |

Tags are backtick-escaped to prevent markdown/HTML interpretation while remaining parseable by the LLM as semantic delimiters.

**Good/bad pairs** — label correct vs incorrect approaches:

```
`<good-example>`
swift build --target MyApp
`</good-example>`

`<bad-example>`
cd /path/to/project && swift build
`</bad-example>`
```

**Examples with reasoning** — show expected behavior and explain why:

```
`<example>`
User: Fix the typo in line 42
Assistant: *Uses Edit tool directly without creating a todo list*

`<reasoning>`
The assistant did not use the todo list because this is a single,
straightforward task that can be completed in one step.
`</reasoning>`
`</example>`
```

The key distinction: markdown headers create document structure (`### Safety`, `### Usage`). Backtick-escaped XML tags label content blocks whose *type* matters — examples, reasoning, good/bad comparisons.

## Complete Example

```swift
public struct MySearchTool: Tool {
    public static let name = "Search"

    public static let description = """
    Searches a vector database and returns semantically similar documents.

    IMPORTANT: This tool is for semantic search over indexed documents. For exact
    string matching in source files, use Grep instead.

    Usage:
    - Provide a natural language query describing what you're looking for
    - Results are ranked by cosine similarity (highest first)
    - Use the limit parameter to control how many results are returned (default: 10)
    - Each result includes the document content, similarity score, and source metadata
    - You can filter results by collection name to search specific document sets
    - ALWAYS check the similarity score before trusting a result. Scores below 0.7 are
      likely irrelevant
    - NEVER use this tool for code search. Use Grep for pattern matching in source files
    - Results will FAIL if the specified collection does not exist. Use the list_collections
      operation first to verify available collections
    - When processing large result sets, store them in Notebook and use Dispatch to analyze
      chunks in parallel

    When NOT to use:
    - Exact string matching in files (use Grep)
    - File name search by pattern (use Glob)
    - Real-time web search (use WebSearch)
    """
}
```

## Checklist

Use this checklist when writing or reviewing a tool description:

- [ ] Starts with a 1-sentence declarative summary
- [ ] Has a `Usage:` section with bullet points
- [ ] Uses `ALWAYS`/`NEVER` for behavior the model must consistently follow
- [ ] References other tools where overlap exists (cross-tool guidance)
- [ ] Documents `FAIL` conditions with recovery strategies
- [ ] Adds `IMPORTANT:` scope boundary if the tool could be confused with another
- [ ] Includes safety protocols with `NEVER` directives for destructive operations
- [ ] Keeps limitations inline in Usage (not a separate section)
- [ ] Avoids few-shot examples in the description (describe constraints, not examples)
- [ ] Scales complexity to match the tool — simple tools stay concise
