"""Register product-owned Swift files in Flutter's generated iOS project."""

from pathlib import Path
import sys


project = Path(__file__).resolve().parents[1] / "ios/Runner.xcodeproj/project.pbxproj"
if not project.exists():
    print(f"Missing generated Xcode project: {project}", file=sys.stderr)
    sys.exit(1)

text = project.read_text(encoding="utf-8")
text = text.replace("com.alpwarestudio.frekioRadio", "com.alpwarestudio.frekio")
if "CarPlaySceneDelegate.swift in Sources" in text:
    project.write_text(text, encoding="utf-8")
    print("CarPlaySceneDelegate.swift is already registered in Xcode.")
    sys.exit(0)

build_id = "A1B2C3D4E5F60718293A4B5C"
file_id = "A1B2C3D4E5F60718293A4B5D"

replacements = [
    (
        "/* Begin PBXBuildFile section */",
        "/* Begin PBXBuildFile section */\n"
        f"\t\t{build_id} /* CarPlaySceneDelegate.swift in Sources */ = "
        f"{{isa = PBXBuildFile; fileRef = {file_id} /* CarPlaySceneDelegate.swift */; }};",
    ),
    (
        "/* Begin PBXFileReference section */",
        "/* Begin PBXFileReference section */\n"
        f"\t\t{file_id} /* CarPlaySceneDelegate.swift */ = "
        "{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; "
        'path = CarPlaySceneDelegate.swift; sourceTree = "<group>"; };',
    ),
    (
        "74858FAE1ED2DC5600515810 /* AppDelegate.swift */,",
        "74858FAE1ED2DC5600515810 /* AppDelegate.swift */,\n"
        f"\t\t\t\t{file_id} /* CarPlaySceneDelegate.swift */,",
    ),
    (
        "74858FAF1ED2DC5600515810 /* AppDelegate.swift in Sources */,",
        "74858FAF1ED2DC5600515810 /* AppDelegate.swift in Sources */,\n"
        f"\t\t\t\t{build_id} /* CarPlaySceneDelegate.swift in Sources */,",
    ),
]

for old, new in replacements:
    if old not in text:
        print(f"Unexpected Xcode project format; marker not found: {old}", file=sys.stderr)
        sys.exit(1)
    text = text.replace(old, new, 1)

project.write_text(text, encoding="utf-8")
print("Registered CarPlaySceneDelegate.swift in the Runner target.")
