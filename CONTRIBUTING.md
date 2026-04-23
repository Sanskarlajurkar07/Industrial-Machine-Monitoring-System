# Contributing to Industrial Machine Monitoring System

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/industrial-machine-monitoring.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes thoroughly
6. Commit with clear messages: `git commit -m "Add: feature description"`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Open a Pull Request

## Development Setup

### Backend Development
```bash
cd backend/Industrialmonitor
./mvnw clean install
./mvnw spring-boot:run
```

### Simulator Development
```bash
cd simulator
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python sensor_simulator.py
```

### Dashboard Development
```bash
cd dashboard
mkdir build && cd build
cmake ..
make
```

## Code Standards

### Java (Backend)
- Follow Java 8 coding conventions
- Use meaningful variable and method names
- Add JavaDoc comments for public APIs
- Write unit tests for new features
- Ensure all tests pass: `./mvnw test`

### Python (Simulator)
- Follow PEP 8 style guide
- Use type hints where applicable
- Add docstrings to functions and classes
- Format code with `black` (optional)

### C++ (Dashboard)
- Follow Qt coding conventions
- Use modern C++ features (C++17)
- Add comments for complex logic
- Ensure proper memory management

## Testing

- Write tests for all new features
- Ensure existing tests pass
- Add integration tests for API changes
- Test edge cases and error conditions

## Pull Request Guidelines

- Provide a clear description of changes
- Reference related issues (e.g., "Fixes #123")
- Include screenshots for UI changes
- Ensure CI/CD checks pass
- Keep PRs focused on a single feature/fix
- Update documentation if needed

## Commit Message Format

```
Type: Brief description (50 chars or less)

Detailed explanation if needed (wrap at 72 chars)

- Bullet points for multiple changes
- Reference issues: Fixes #123, Closes #456
```

**Types:**
- `Add:` New feature or functionality
- `Fix:` Bug fix
- `Update:` Changes to existing features
- `Refactor:` Code restructuring
- `Docs:` Documentation changes
- `Test:` Adding or updating tests
- `Chore:` Maintenance tasks

## Questions?

Feel free to open an issue for questions or discussions!
