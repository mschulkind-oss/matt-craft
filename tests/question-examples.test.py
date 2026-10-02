"""Check question specimens that the Markdown gate deliberately ignores in fences.

Baseline: specimens used `oq`, which Vantage 0.8.0 deprecates and which older
viewers offer to answer on 🔒/✅. Success: each specimen writes `question` under a
title that asks the decision.
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
                        self.assertEqual(name, "question", "Vantage 0.8.0 writes `question` in every state")
                        self.assertIn("?", title, "The bold title must ask the decision")
                        self.assertTrue(body[match.end() - match.start():].startswith("\n\n"),
                                        "The title must be a paragraph of its own")
                        if marker not in ("🔒", "✅"):
                            leaning = re.search(r'_Leaning:_ (.*?)(?=\n\n|\Z)', body, re.S)
                            value = re.search(r' leaning="([^"]*)"', attrs)
                            self.assertIsNotNone(leaning)
                            self.assertIsNotNone(value)
                            self.assertEqual(" ".join(leaning[1].split()), value[1])
            self.assertGreater(count, 0, skill)
        self.assertTrue({"💬", "💬 🤷", "🔒", "✅"}.issubset(seen))

    def test_examples_with_planning_checker(self):
        # The normal gate ignores fenced specimens, so check them as real
        # documents with the release the skills teach, never a skip.
        command = shlex.split(os.environ.get("VANTAGE_CHECK", "uvx vantage-check@0.8.0"))
        help_result = subprocess.run(command + ["help"], capture_output=True, text=True)
        self.assertEqual(help_result.returncode, 0, help_result.stderr)
        self.assertIn("vantage/oq-deprecated", help_result.stdout,
                      "This checker predates Vantage 0.8.0, whose notation the skills teach")
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
                    # A state change keeps the directive and its leaning. Exercise
                    # the same specimen in every state, including no emoji.
                    for match, body in questions(block):
                        if ' leaning="' not in body:
                            continue
                        for marker in ("💬", "🔒", "✅", ""):
                            changed = re.sub(r"^\d+\. (💬(?: 🤷)?|🔒|✅) ",
                                             "1. " + (marker + " " if marker else ""), body)
                            path = pathlib.Path(directory) / f"state-{len(paths)}.md"
                            path.write_text(changed)
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
