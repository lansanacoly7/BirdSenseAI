import io

def fix_main():
    with io.open('lib/main.dart', 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()
    content = content.replace(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:flutter/foundation.dart';"
    )
    content = content.replace(
        "ref.read(syncServiceProvider).recoverInterruptedSyncs();",
        "if (!kIsWeb) { ref.read(syncServiceProvider).recoverInterruptedSyncs(); }"
    )
    with io.open('lib/main.dart', 'w', encoding='utf-8') as f:
        f.write(content)

fix_main()
print("Fixed main.dart")
