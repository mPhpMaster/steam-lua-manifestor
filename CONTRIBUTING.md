# Contributing to Steam Lua Manifestor

Thank you for your interest in contributing to Steam Lua Manifestor! We welcome contributions from the community.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Enhancements](#suggesting-enhancements)

## Code of Conduct

This project and everyone participating in it is governed by our commitment to providing a welcoming and inclusive environment. Please be respectful and constructive in all interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples** (code snippets, files, etc.)
- **Describe the behavior you observed and what you expected**
- **Include your environment details** (OS, Lua version, etc.)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **A clear and descriptive title**
- **A detailed description of the proposed feature**
- **Explain why this enhancement would be useful**
- **Include examples of how it would work**

### Code Contributions

1. Fork the repository
2. Create a new branch for your feature or bugfix
3. Make your changes
4. Test your changes thoroughly
5. Submit a pull request

## Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mPhpMaster/steam-lua-manifestor.git
   cd steam-lua-manifestor
   ```

2. **Install Lua** (if not already installed)
   - Ensure you have Lua 5.1 or later

3. **Set up your development environment:**
   - Use your preferred text editor or IDE
   - Consider using a Lua linter for code quality

## Coding Standards

### Lua Style Guide

- **Indentation:** Use 4 spaces (no tabs)
- **Line Length:** Keep lines under 100 characters when possible
- **Naming Conventions:**
  - Variables and functions: `snake_case`
  - Constants: `UPPER_SNAKE_CASE`
  - Classes/Modules: `PascalCase`
  
- **Comments:**
  - Use `--` for single-line comments
  - Use `--[[  ]]` for multi-line comments
  - Document all public functions with clear descriptions

### Code Quality

- Write clear, readable, and maintainable code
- Add comments for complex logic
- Remove unused code and debug statements
- Follow DRY (Don't Repeat Yourself) principles
- Write modular, reusable code

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(manifest): add support for workshop items
fix(parser): correct parsing of special characters
docs(readme): update installation instructions
```

### Commit Best Practices

- Write clear, concise commit messages
- Make atomic commits (one logical change per commit)
- Reference issue numbers when applicable (e.g., "fixes #123")

## Pull Request Process

1. **Before submitting:**
   - Ensure your code follows the coding standards
   - Update documentation if needed
   - Test your changes thoroughly
   - Rebase your branch on the latest main branch

2. **Submitting the PR:**
   - Use a clear and descriptive title
   - Provide a detailed description of changes
   - Reference any related issues
   - Include screenshots/examples if applicable

3. **After submitting:**
   - Respond to review comments promptly
   - Make requested changes in new commits
   - Keep the PR up to date with the main branch

4. **PR Review:**
   - At least one maintainer review is required
   - All CI checks must pass
   - Address all review comments

## Testing

- Test your changes with various scenarios
- Ensure existing functionality isn't broken
- Add tests for new features when applicable
- Verify Steam manifest files are generated correctly

## Documentation

- Update README.md if you change functionality
- Add inline code comments for complex logic
- Update examples if the API changes
- Keep documentation clear and up to date

## Questions?

If you have questions or need help:

- Open an issue with the "question" label
- Provide context and what you've tried
- Be patient and respectful

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to Steam Lua Manifestor! 🎮