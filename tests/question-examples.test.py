"""Check question specimens that the Markdown gate deliberately ignores in fences.

Baseline: blocked/answered specimens used oq, offering an answer button in older
viewers. Success: each specimen has the marker's directive and a question title.
This is a deterministic packaging regression, not a live-model behavior evaluation.
"""
import os
import pathlib
import re
import shlex
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]


def examples(text):
    return re.findall(r"^```markdown\n(.*?)^```$", text, re.M | re.S)


def questions(block):
    starts = list(re.finditer(r"^\d+\. (💬(?: 🤷)?|🔒|✅) \*\*(OQ-[A-Z]*\d+): (.*?)\*\*", block, re.M))
    for i, match in enumerate(starts):
        end = starts[i + 1].start() if i + 1 < len(starts) else len(block)
        yield match, block[match.start():end]


class QuestionExamples(unittest.TestCase):
    def test_copyable_questions(self):
        seen = set()
        for skill in ("design-doc", "user-stories", "vantage-docs"):
            text = (ROOT / "skills" / skill / "SKILL.md").read_text()
            count = 0
            for block in examples(text):
                for match, body in questions(block):
                    marker, ident, title = match.groups()
                    seen.add(marker)
                    count += 1
                    with self.subTest(skill=skill, question=ident):
                        directives = re.findall(r"<!-- vantage: (oq|question) id=(OQ-[A-Z]*\d+)(.*?) -->", body)
                        self.assertEqual(len(directives), 1, body)
                        name, directive_id, attrs = directives[0]
                        self.assertEqual(directive_id, ident)
                        self.assertEqual(name, "question" if marker in ("🔒", "✅") else "oq")
                        if name == "question":
                            self.assertEqual(attrs, "")
                        self.assertIn("?", title, "The bold title must ask the decision")
                        if name == "oq":
                            leaning = re.search(r'_Leaning:_ (.*?)(?=\n\n|\Z)', body, re.S)
                            value = re.search(r' leaning="([^"]*)"', attrs)
                            self.assertIsNotNone(leaning)
                            self.assertIsNotNone(value)
                            self.assertEqual(" ".join(leaning[1].split()), value[1])
            self.assertGreater(count, 0, skill)
        self.assertTrue({"💬", "💬 🤷", "🔒", "✅"}.issubset(seen))

    def test_examples_with_planning_checker(self):
        # The normal gate ignores fenced specimens. Run these as real documents
        # when a matching checker is available, never silently pass an old one.
        command = shlex.split(os.environ.get("VANTAGE_CHECK", "uvx vantage-check"))
        help_result = subprocess.run(command + ["help"], capture_output=True, text=True)
        self.assertEqual(help_result.returncode, 0, help_result.stderr)
        if "vantage/question-name" not in help_result.stdout:
            if "VANTAGE_CHECK" in os.environ:
                self.fail("Explicit checker lacks vantage/question-name")
            self.skipTest("Published checker lacks 0.8 question-name; specimens checked statically only")
        with tempfile.TemporaryDirectory(prefix="question-examples-") as directory:
            paths = []
            for skill in ("design-doc", "user-stories", "vantage-docs"):
                text = (ROOT / "skills" / skill / "SKILL.md").read_text()
                for i, block in enumerate(examples(text)):
                    if not list(questions(block)):
                        continue
                    path = pathlib.Path(directory) / f"{skill}-{i}.md"
                    path.write_text(block)
                    paths.append(str(path))
            result = subprocess.run(command + ["check", "--no-config", "--strict"] + paths,
                                    capture_output=True, text=True, cwd=directory)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_graduation_checks_both_directives(self):
        text = (ROOT / "skills/system-doc/SKILL.md").read_text()
        self.assertIn(r"vantage:\s*(oq|question)\b", text)

    def test_checker_policy_preserves_human_target(self):
        text = (ROOT / "skills/vantage-docs/SKILL.md").read_text()
        self.assertIn("**Never change `target`.**", text)
        self.assertIn("A checker older than the document is not a finding about the document", text)
        self.assertNotIn("it is the same binary", text)


if __name__ == "__main__":
    unittest.main()
