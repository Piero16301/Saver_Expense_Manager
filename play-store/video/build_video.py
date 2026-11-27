#!/usr/bin/env python3
"""Builds the Saver Play Store promo video from play-store/demo_saver.webm.

Usage (run from anywhere):
    python3 play-store/video/build_video.py            # 1080p @ 60fps -> play-store/video/saver_promo_1080p60.mp4
    python3 play-store/video/build_video.py 2160       # 4K    @ 60fps -> play-store/video/saver_promo_2160p60.mp4
    python3 play-store/video/build_video.py 2160 --no-music

Requires: ffmpeg, swiftc (macOS).
Edit SCENES here or text/colors in play-store/video/backgrounds.swift to customize.
"""
import os, re, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # play-store/
PROJ = os.path.dirname(ROOT)
VID = os.path.join(ROOT, "video")
BUILD = os.path.join(ROOT, "_build")
SRC = os.path.join(ROOT, "demo_saver.webm")
LOGO = os.path.join(PROJ, "web", "icons", "Icon-512.png")

args = [a for a in sys.argv[1:] if not a.startswith("--")]
flags = {a for a in sys.argv[1:] if a.startswith("--")}
H = int(args[0]) if args else 1080
W = H * 16 // 9
FPS = 60
XF = 0.35  # crossfade duration (seconds)
CRF = "15" if H <= 1080 else "17"
WITH_MUSIC = "--no-music" not in flags

work = os.path.join(BUILD, f"video_{H}")
os.makedirs(work, exist_ok=True)

# (background index, source start s, source end s, playback speed)
SCENES = [
    (0,    0.0,   3.5, 1.0),   # Intro: Saver hero (Expenses overview)
    (1,    3.5,  12.2, 1.7),   # Expense Tracking (category chips + smooth scrolling)
    (2,   17.4,  28.5, 2.1),   # Category Trends (Feeding curve + touch tooltips + movements)
    (3,   33.2,  42.2, 1.55),  # Gemini AI Savings Tips (Avoidable expenses + What you could cover)
    (4,   42.5,  52.5, 2.1),   # Smart Filters (Type -> Expense -> Category -> Feeding)
    (5,   56.0,  67.5, 2.2),   # Financial Summary (Incomes/Balance/Expenses 3-line chart + tooltips)
    (6,   68.8,  80.5, 2.2),   # Yearly Insights (2024-2026 curve + Top Categories carousel)
    (7,   84.8,  96.3, 2.0),   # AI Receipt Scanner (+ -> Scan -> auto-capture -> Gemini Flash)
    (8,   98.3, 103.8, 1.15),  # AI Auto-Fill (Gemini Flash -> auto-filled New transaction)
    (9,  115.2, 125.2, 1.8),   # Custom Themes & 6 Languages (Dark -> Light -> Orange -> EN/IT/ES)
    (10,   0.0,   3.6, 0.95),  # Outro CTA on clean English Expenses hero
]

def run(cmd):
    subprocess.run(cmd, check=True)

# 1. Compile and render backgrounds + rounded smartphone mask at exact target resolution
exe = os.path.join(work, "backgrounds")
run(["swiftc", "-module-cache-path", os.path.join(work, "mc"), os.path.join(VID, "backgrounds.swift"), "-o", exe])
bg_cmd = [exe, str(H), work]
if os.path.exists(LOGO):
    bg_cmd.append(LOGO)
info = subprocess.run(bg_cmd, check=True, capture_output=True, text=True).stdout
vx, vy, vw, vh = map(int, re.search(r"VIDEO_X (\d+) VIDEO_Y (\d+) VIDEO_W (\d+) VIDEO_H (\d+)", info).groups())
print(f"Rendered {len(SCENES)} backgrounds @ {W}x{H} (phone screen {vw}x{vh} at {vx},{vy})")

# 2. Render each scene clip at true 60fps
clips, durs = [], []
sharpen = ",unsharp=5:5:0.35:3:3:0.0" if vh > 1200 else ""
for n, (bg, s, e, sp) in enumerate(SCENES):
    dur = (e - s) / sp
    out = os.path.join(work, f"clip_{n}.mp4")
    fc = (
        f"[0:v]setpts=(PTS-STARTPTS)/{sp},fps={FPS},"
        f"scale={vw}:{vh}:flags=lanczos{sharpen},format=yuv420p[v];"
        f"[2:v]format=gray[m];"
        f"[v][m]alphamerge[va];"
        f"[1:v][va]overlay={vx}:{vy}:shortest=1,format=yuv420p[o]"
    )
    run([
        "ffmpeg", "-y", "-loglevel", "error",
        "-ss", f"{s:.3f}", "-t", f"{e - s:.3f}", "-i", SRC,
        "-loop", "1", "-framerate", str(FPS), "-t", f"{dur:.3f}", "-i", os.path.join(work, f"bg_{bg}.png"),
        "-loop", "1", "-framerate", str(FPS), "-t", f"{dur:.3f}", "-i", os.path.join(work, "mask.png"),
        "-filter_complex", fc, "-map", "[o]",
        "-r", str(FPS), "-t", f"{dur:.3f}",
        "-c:v", "libx264", "-crf", "13", "-preset", "fast", "-pix_fmt", "yuv420p",
        out,
    ])
    clips.append(out)
    durs.append(dur)

# 3. Calculate final timeline length and generate royalty-free soundtrack
total_dur = sum(durs) - XF * (len(clips) - 1)
audio_inputs, audio_maps, audio_opts = [], [], ["-an"]
if WITH_MUSIC:
    wav = os.path.join(work, "music.wav")
    run([sys.executable, os.path.join(VID, "make_music.py"), f"{total_dur + 0.2:.3f}", wav])
    audio_idx = len(clips)
    audio_inputs = ["-i", wav]
    audio_maps = ["-map", f"{audio_idx}:a"]
    audio_opts = ["-c:a", "aac", "-b:a", "192k", "-ar", "44100", "-shortest"]

# 4. Stitch scenes with smooth crossfades + YouTube-ready H.264 High @ 60fps
inputs = []
for c in clips:
    inputs += ["-i", c]
inputs += audio_inputs

chain, last, length = [], "[0:v]", durs[0]
for i in range(1, len(clips)):
    off = length - XF
    tag = f"[x{i}]"
    chain.append(f"{last}[{i}:v]xfade=transition=fade:duration={XF}:offset={off:.3f}{tag}")
    last, length = tag, length + durs[i] - XF

final = os.path.join(VID, f"saver_promo_{H}p{FPS}.mp4")
run([
    "ffmpeg", "-y", "-loglevel", "error",
    *inputs,
    "-filter_complex", ";".join(chain),
    "-map", last, *audio_maps,
    "-r", str(FPS), "-t", f"{length:.3f}",
    "-c:v", "libx264", "-crf", CRF, "-preset", "slow",
    "-pix_fmt", "yuv420p", "-profile:v", "high", "-level:v", "5.2" if H > 1080 else "4.2",
    "-color_primaries", "bt709", "-color_trc", "bt709", "-colorspace", "bt709",
    "-movflags", "+faststart",
    *audio_opts,
    final,
])
print(f"DONE {final} ({length:.1f}s, {W}x{H}@{FPS}fps, music={'on' if WITH_MUSIC else 'off'})")
