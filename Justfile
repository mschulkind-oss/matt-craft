# matt-craft Justfile

default:
    @just --list

# Verify all skills pass the corpus validator
test:
    ./scripts/check-skills skills
    sh tests/status-lines.test.sh
    sh tests/briefing.test.sh
    python3 tests/question-examples.test.py

# Run vantage-check on documentation, the routing briefing, and skills
check:
    uvx vantage-check README.md briefing/*.md skills/*/SKILL.md

# Run all quality checks before committing
done: test check
