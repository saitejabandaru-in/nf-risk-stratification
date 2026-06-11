# Contributing to nf-risk-stratification

Thank you for your interest in contributing to `nf-risk-stratification`! This project provides tools for reproducible clinical risk stratification in necrotizing fasciitis, supporting both Python and R ecosystems.

We welcome contributions from biostatisticians, data scientists, clinical researchers, and software engineers.

---

## Code of Conduct

By participating in this project, you agree to maintain a professional, respectful, and collaborative environment.

---

## How to Contribute

### 1. Reporting Bugs & Requesting Features
* Search the [issue tracker](https://github.com/saitejabandaru-in/nf-risk-stratification/issues) to see if your problem or idea has already been discussed.
* If not, open a new issue. Use a clear title and provide as much context as possible (including reproducible code snippets for bug reports).

### 2. Submitting Pull Requests
* Fork the repository and create a new branch from `main`.
* Write clean, documented code.
* Ensure all code matches the project's styling and structure:
  * For Python: Package source is under `python/`. Tests are under `tests_python/`.
  * For R: Package source is under `R/`. Unit tests are under `tests/testthat/`.
* Write tests to verify your changes.
* Run the test suite before submitting:
  * For Python: `pytest tests_python/`
  * For R: `devtools::test()`
* Open a PR targeting the `main` branch. Provide a detailed description of your changes and reference any related issues.

---

## Development Setup

### Python Environment
1. Create a virtual environment:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```
2. Install the package in editable mode with test dependencies:
   ```bash
   pip install -e ".[test]"
   ```
3. Run tests:
   ```bash
   pytest tests_python/
   ```

### R Environment
1. Install dependencies:
   ```r
   install.packages(c("devtools", "roxygen2", "testthat"))
   ```
2. Load the package and document:
   ```r
   devtools::load_all()
   devtools::document()
   ```
3. Run tests:
   ```r
   devtools::test()
   ```

---

## Licensing

By contributing to `nf-risk-stratification`, you agree that your contributions will be licensed under the project's **MIT License**.
