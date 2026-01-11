# Contributing to quantum-d

Thank you for your interest in contributing to quantum-d! 

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/quantum-d.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Run tests: `dub run`
6. Commit your changes: `git commit -m "Add your feature"`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Open a Pull Request

## Development Setup

### Prerequisites
- D compiler (DMD, LDC, or GDC)
- DUB package manager

### Building
```bash
dub build
```

### Running Tests
```bash
dub run
```

## Code Style

- Use 4 spaces for indentation
- Add ddoc comments for all public functions
- Keep lines under 100 characters when possible
- Use meaningful variable names

## Reporting Issues

When reporting issues, please include:
- D compiler version (`dmd --version`)
- Operating system
- Steps to reproduce
- Expected vs actual behavior

## Feature Requests

Feature requests are welcome! Please open an issue describing:
- The feature you'd like to see
- Why it would be useful
- Any implementation ideas you have

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
