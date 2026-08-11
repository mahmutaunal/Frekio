#!/usr/bin/env python3
"""Validate repository documentation, privacy HTML, and store field limits."""

from html.parser import HTMLParser
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parent.parent


class PolicyParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.ids: list[str] = []
        self.hrefs: list[str] = []

    def handle_starttag(
        self, tag: str, attrs: list[tuple[str, str | None]]
    ) -> None:
        values = dict(attrs)
        if values.get("id"):
            self.ids.append(values["id"] or "")
        if tag == "a" and values.get("href"):
            self.hrefs.append(values["href"] or "")


def verify_readme_links() -> None:
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    missing: list[str] = []
    for target in re.findall(r'(?:href|src)="([^"]+)"', readme):
        if target.startswith(("http://", "https://", "mailto:", "#")):
            continue
        path = ROOT / target.split("#", 1)[0]
        if not path.exists():
            missing.append(target)
    if missing:
        raise SystemExit(f"Missing README paths: {missing}")


def verify_privacy_html() -> None:
    html = (ROOT / "docs/index.html").read_text(encoding="utf-8")
    parser = PolicyParser()
    parser.feed(html)
    duplicate_ids = sorted(
        {value for value in parser.ids if parser.ids.count(value) > 1}
    )
    broken_anchors = sorted(
        {
            href
            for href in parser.hrefs
            if href.startswith("#") and href[1:] not in parser.ids
        }
    )
    if duplicate_ids:
        raise SystemExit(f"Duplicate HTML ids: {duplicate_ids}")
    if broken_anchors:
        raise SystemExit(f"Broken privacy-page anchors: {broken_anchors}")
    required = (
        'id="english"',
        'id="turkce"',
        "contact@alpwarestudio.com",
        "Radio Browser",
    )
    missing = [value for value in required if value not in html]
    if missing:
        raise SystemExit(f"Missing privacy disclosures: {missing}")


def verify_store_fields() -> None:
    fields = {
        "English app name": ("Frekio: Internet Radio", 30),
        "English App Store subtitle": ("Live radio, simply", 30),
        "English Play short description": (
            "Live radio from Turkey and around the world, without ads or accounts",
            80,
        ),
        "Turkish app name": ("Frekio: İnternet Radyosu", 30),
        "Turkish App Store subtitle": ("Canlı radyo, sade ve hızlı", 30),
        "Turkish Play short description": (
            "Türkiye’den ve dünyadan canlı radyolar; reklamsız, hesapsız ve sade",
            80,
        ),
    }
    for label, (value, limit) in fields.items():
        if len(value) > limit:
            raise SystemExit(f"{label} exceeds {limit} characters: {len(value)}")

    for language in ("EN", "TR"):
        path = ROOT / f"docs/STORE_LISTING_{language}.md"
        content = path.read_text(encoding="utf-8")
        match = re.search(r"```text\n(.*?)\n```", content, re.DOTALL)
        if not match:
            raise SystemExit(f"Missing full description in {path.name}")
        if len(match.group(1)) > 4000:
            raise SystemExit(
                f"Full description in {path.name} exceeds 4,000 characters"
            )


def main() -> None:
    verify_readme_links()
    verify_privacy_html()
    verify_store_fields()
    print("Documentation, privacy HTML, and store field limits: OK")


if __name__ == "__main__":
    main()
