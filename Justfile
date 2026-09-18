# matt-craft Justfile

default:
    @just --list

# Verify all skills pass the corpus validator
test:
    ./scripts/check-skills skills

# Run vantage-check on documentation and skills
check:
    uvx vantage-check README.md skills/*/SKILL.md

# Run all quality checks before committing
done: test check
