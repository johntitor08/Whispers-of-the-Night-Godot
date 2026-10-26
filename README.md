# Whispers of the Night — Godot

Unity'de yapılmış *Whispers of the Night* (Gecenin Fısıltıları) görsel roman / RPG'sinin Godot 4.6 (GDScript) portu.

- `tools/` — Unity sahne, prefab ve ScriptableObject verisini Godot sahnelerine çeviren Python dönüştürücü (`cd tools && python3 convert.py`).
- `scripts/u/` — Unity yaşam döngüsü, uGUI düzeni ve olay sisteminin GDScript karşılığı.
- `scripts/game/`, `scripts/minigame/` — oyun, diyalog, savaş, görev, dükkân, kayıt ve mini oyun scriptleri.

Çalıştırma: projeyi Godot 4.6 ile açıp oynat; ana sahne `scenes/MainMenu.tscn`.
