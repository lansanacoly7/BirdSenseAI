"""conftest.py — Configuration pytest globale pour BirdSense AI (périmètre Pathé Fall).

Ajoute la racine du projet au sys.path pour que les imports
`from backend.app.analytics.fusion import ...` fonctionnent sans installation du package.
"""

import sys
import os

# Ajoute la racine du repo au path Python
sys.path.insert(0, os.path.dirname(__file__))
