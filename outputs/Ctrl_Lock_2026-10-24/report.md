# Ctrl camera lock

Added StarterPlayerScripts.MidnightCtrlLock.
Left/Right Ctrl toggles requested lock on desktop keyboard/mouse. Default Roblox camera handles mouse look. Active lock centers/hides cursor, adds shoulder offset and aligns avatar yaw to camera. Center dot indicates active state.
Suspends for Kitchen, Shop, photo preview/scriptable cameras, focused text fields, Roblox menu, window focus loss, sitting/death/missing character. Restores original Humanoid.AutoRotate/CameraOffset and mouse icon on release. Resumes requested lock after modal closes. CharacterRemoving cleanup.
StarterPlayer.EnableMouseLockOption changed true->false to avoid built-in Shift-lock conflict.

Testing:
Original production script initially confirmed Ctrl requested/active, MouseBehavior.LockCenter, AutoRotate=false. Original Right Ctrl off restored AutoRotate.
Automation changes window focus, correctly pausing production lock, so extended checks used a runtime-only clone with window focus guard disabled. All11 checks passed: request/active, camera-facing yaw, Kitchen/Shop/typing/scriptable-camera release and resume. Right Ctrl off also passed. Clone removed by Stop; production focus guard remains.
Physical mouse-look feel in standalone Player, real Alt-Tab and respawn behavior not independently verified. No claim of full external Player test.
Play stopped. Publish from Studio to deploy.

