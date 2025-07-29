| allowed-tools | description |
|---|---|
| Bash, Read | Load context for a new agent session by analyzing codebase structure and README |

# Prime

This command loads essential context for a new agent session by examining the codebase structure and reading the project README.

## Instructions

- Analyze the codebase structure using the best available tool
- Read the README.md to understand the project purpose, setup instructions, and key information  
- Provide a concise overview of the project based on the gathered context

## Context

- Codebase structure: ! `eza . --tree || git ls-files`
- Project README: @README.md 