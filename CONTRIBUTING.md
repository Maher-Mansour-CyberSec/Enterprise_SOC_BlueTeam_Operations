# Contributing to Enterprise SOC Lab

Thank you for your interest in contributing to the Enterprise SOC Lab project! This document provides guidelines for contributing to this repository.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [How to Contribute](#how-to-contribute)
3. [Contribution Types](#contribution-types)
4. [Documentation Standards](#documentation-standards)
5. [Pull Request Process](#pull-request-process)
6. [Development Workflow](#development-workflow)

---

## Code of Conduct

### Our Standards

- Be respectful and inclusive in all interactions
- Focus on constructive feedback and improvement
- Respect differing viewpoints and experiences
- Accept constructive criticism gracefully
- Prioritize community benefit over individual gain

### Unacceptable Behavior

- Harassment, discrimination, or intimidation of any kind
- Trolling, insulting/derogatory comments, or personal attacks
- Publishing others' private information without permission
- Other conduct that could reasonably be considered inappropriate

---

## How to Contribute

### Getting Started

1. **Fork the Repository**: Create your own fork of the project
2. **Clone Your Fork**: `git clone https://github.com/yourusername/enterprise-soc-lab.git`
3. **Create a Branch**: `git checkout -b feature/your-feature-name`
4. **Make Changes**: Implement your contribution
5. **Test**: Verify your changes work as expected
6. **Commit**: `git commit -m "Add: description of your changes"`
7. **Push**: `git push origin feature/your-feature-name`
8. **Pull Request**: Submit a PR with detailed description

### Reporting Issues

When reporting issues, please include:

- **Title**: Clear, concise description
- **Description**: Detailed explanation of the issue
- **Steps to Reproduce**: Numbered steps to recreate
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Environment**: OS, versions, configurations
- **Screenshots**: If applicable
- **Additional Context**: Any other relevant information

---

## Contribution Types

### Documentation Improvements

- Fix typos or grammatical errors
- Clarify existing documentation
- Add missing documentation
- Improve examples and screenshots
- Translate documentation

### New Features

- Additional attack scenarios
- New detection rules
- Extended MITRE ATT&CK coverage
- Additional SIEM integrations
- New visualization dashboards

### Bug Fixes

- Configuration corrections
- Documentation inaccuracies
- Broken links or references
- Outdated information

### Attack Scenarios

When contributing new attack scenarios:

1. **MITRE ATT&CK Alignment**: Map to specific technique ID
2. **Validation Steps**: Include expected detection outcomes
3. **Safety Notes**: Highlight any safety considerations
4. **Tool Requirements**: List required tools and versions
5. **Detection Rules**: Provide corresponding detection logic

### Detection Rules

When contributing detection rules:

1. **Rule Format**: Follow existing format (SPL or KQL)
2. **MITRE Mapping**: Include technique ID and tactic
3. **False Positive Notes**: Document expected FPs and tuning
4. **Testing**: Validate rule with actual attack data
5. **Performance**: Consider query performance impact

---

## Documentation Standards

### Markdown Formatting

- Use ATX-style headers (`#` not underlines)
- Maximum header depth: 4 levels
- Use code blocks with language specification
- Use tables for structured data
- Include a table of contents for long documents

### Code Examples

```markdown
# Good Example

```bash
# This command does something useful
sudo systemctl start elasticsearch
```

```spl
# Splunk detection rule
index=windows EventCode=4625
| stats count by src_ip
| where count > 5
```
```

### File Naming

- Use lowercase with hyphens: `file-name.md`
- Be descriptive but concise
- Group related files in directories

### Diagrams

- Prefer Mermaid for simple diagrams (version controlled)
- Use PNG/SVG for complex diagrams
- Include source files when possible
- Maintain consistent style

---

## Pull Request Process

### Before Submitting

1. **Update Documentation**: Ensure docs reflect your changes
2. **Add Tests**: If applicable, add validation steps
3. **Check Formatting**: Verify markdown renders correctly
4. **Review Your Changes**: Self-review before submitting

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Attack scenario
- [ ] Detection rule

## Related Issue
Fixes #(issue number)

## Testing
- [ ] Tested in lab environment
- [ ] Validated detection rules
- [ ] Verified documentation

## Checklist
- [ ] Code follows project style
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

### Review Process

1. **Automated Checks**: CI/CD validation
2. **Maintainer Review**: At least one approval required
3. **Feedback Integration**: Address review comments
4. **Merge**: Maintainers will merge approved PRs

---

## Development Workflow

### Branch Naming

- `feature/description` - New features
- `bugfix/description` - Bug fixes
- `docs/description` - Documentation updates
- `attack/scenario-name` - New attack scenarios
- `detection/technique-id` - New detection rules

### Commit Messages

Use conventional commit format:

```
type(scope): subject

body (optional)

footer (optional)
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting changes
- `refactor`: Code refactoring
- `test`: Test additions/changes
- `chore`: Maintenance tasks

**Examples:**
```
feat(detection): add brute force detection rule for RDP

docs(architecture): update network diagram with new VLANs

fix(splunk): correct field extraction in saved search
```

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Incompatible changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

---

## Recognition

Contributors will be recognized in:

- CHANGELOG.md for each release
- README.md contributors section
- Release notes

---

## Questions?

If you have questions about contributing:

1. Check existing documentation
2. Search closed issues/PRs
3. Open a new issue with the "question" label

Thank you for contributing to the Enterprise SOC Lab!
