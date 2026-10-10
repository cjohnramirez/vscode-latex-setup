# LaTeX Setup Guide (VS Code + MiKTeX + Strawberry Perl)

This guide shows you how to write and compile LaTeX in VS Code on Windows. Follow the steps in order.

## What you need

- **Strawberry Perl**: `latexmk` (the tool that builds your PDF) needs Perl to run, and MiKTeX does not come with it.
- **MiKTeX**: the LaTeX engine. It can download missing packages by itself while you compile.
- **VS Code** with the **LaTeX Workshop** extension: the editor and the build button.

---

## Step 1: Install Strawberry Perl

1. Download the installer from https://strawberryperl.com
2. Run it and keep the default options. Let it add Perl to your PATH.
3. Open a new terminal (PowerShell) and check it works:

```powershell
perl -v
```

If you see a version number, you're good. If it says "not recognized", restart your computer or add `C:\Strawberry\perl\bin` to your PATH manually.

## Step 2: Install MiKTeX

1. Download the installer from https://miktex.org/download
2. Run it. Pick **Install for anyone who uses this computer** (needs admin) or **Install only for me**. Either works.
3. When it asks about missing packages, set **Install missing packages on-the-fly** to **Always**. This is the auto install part.
4. Finish the install, then open a **new** terminal and check:

```powershell
pdflatex --version
initexmf --version
```

Both should print version info.

## Step 3: Turn on auto install for packages

If you skipped it in the installer, or want to change it later:

**Using the app:** open **MiKTeX Console**, go to **Settings**, then **General**, and set **Install missing packages on-the-fly** to **Always**.

**Using the terminal:**

```powershell
initexmf --set-config-value "[MPM]AutoInstall=1"
```

(`1` means always install, `2` means ask first, `0` means never.)

Why **Always** and not **Ask me first**? When VS Code builds in the background, a popup asking for permission can hide behind other windows and make the build look stuck.

Good to know:
- The first build takes longer because MiKTeX downloads what it needs. After that it's fast.
- You need internet for the first time a package is used.
- Keep things updated once in a while: MiKTeX Console, then **Updates**, then **Check for updates**.

## Step 4: Set up VS Code

1. Install VS Code: https://code.visualstudio.com
2. Open the Extensions tab (`Ctrl+Shift+X`) and install **LaTeX Workshop** (by James Yu).
3. Open settings as JSON: press `Ctrl+Shift+P`, type **Preferences: Open User Settings (JSON)**, and paste this inside the main `{ }`:

```json
"latex-workshop.latex.autoBuild.run": "onSave",
"latex-workshop.latex.recipe.default": "first",
"latex-workshop.view.pdf.viewer": "tab",
"latex-workshop.latex.outDir": "%DIR%/build",
"latex-workshop.latex.autoClean.run": "never",
"latex-workshop.message.update.show": false,
"latex-workshop.latex.tools": [
  {
    "name": "latexmk",
    "command": "latexmk",
    "args": [
      "-synctex=1",
      "-interaction=nonstopmode",
      "-file-line-error",
      "-pdf",
      "-outdir=%OUTDIR%",
      "%DOC%"
    ]
  }
],
"latex-workshop.latex.recipes": [
  {
    "name": "latexmk",
    "tools": ["latexmk"]
  }
]
```

What these do:

| Setting | What it does |
| --- | --- |
| `autoBuild.run: onSave` | Rebuilds the PDF every time you save |
| `view.pdf.viewer: tab` | Shows the PDF in a VS Code tab next to your code |
| `outDir: %DIR%/build` | Puts all the messy `.aux`, `.log`, etc. files in a `build` folder |
| `-interaction=nonstopmode` | Doesn't freeze on errors, so you see them all at once |
| `-synctex=1` | Lets you jump between the code and the PDF |

4. Restart VS Code.

## Step 5: Build your first PDF

1. Open your `.tex` file.
2. Press `Ctrl+Alt+B` (or click the green play button in the **TeX** sidebar) to build.
3. Press `Ctrl+Alt+V` to view the PDF.
4. From now on it rebuilds on save.

The first build may take a minute while MiKTeX downloads packages. Be patient, and don't close VS Code.

**Tip:** `Ctrl+Click` on the PDF jumps to the matching line in your code. `Ctrl+Alt+J` goes from code to PDF.

---

## Folder structure

```
├── main.tex            <- preamble + chapter list (the file you build)
├── thesis-refs.bib     <- all citations
├── .latexmkrc          <- lets BibTeX find the .bib file
└── chapters/
    ├── 01-introduction/
    │   ├── chapter.tex <- main file of the chapter, hosts its sections
    │   ├── background.tex
    │   └── ...
    ├── 02-literature/
    │   ├── chapter.tex
    │   ├── sample.tex
    │   └── ...
    └── 03-methodology/
        ├── chapter.tex
        ├── model.tex
        └── ...
```

The chapters and sections in this repo are only samples. Rename, remove, or add your own.

**How it fits together:** `main.tex` loads each `chapter.tex`, and each `chapter.tex` loads its section files.

`main.tex`:

```latex
\input{chapters/01-introduction/chapter}
```

`chapters/01-introduction/chapter.tex`:

```latex
\section{Introduction}
\input{chapters/01-introduction/background}
```

`chapters/01-introduction/background.tex`:

```latex
\subsection{Background of the Study}
Your text here.
```

- **New section:** create the file, then add an `\input` line to its `chapter.tex`.
- **New chapter:** create a numbered folder with a `chapter.tex`, then add an `\input` line to `main.tex`.
- **Paths** always start from the folder that holds `main.tex`.
- **Always build `main.tex`.** Chapter and section files will not compile on their own.
- **One section per file** keeps Git merges painless.

---

## Working together with Git (branching)

With several authors, everyone editing `main` leads to merge conflicts and a broken build. Use short branches instead.

**Rules:**
- `main` always compiles. Nobody commits to it directly.
- Each person makes a short branch for what they're working on, like `intro-rewrite` or `rq-table`.
- Open a pull request when you're done, and merge within a few days. Long-lived branches cause the most conflicts.
- Check that the PDF still compiles before you merge.

```
main:      A---B-----------E---F
                \         /
intro-rewrite    C---D---
```

**The flow:**

1. Start from an up-to-date `main`:
   ```powershell
   git checkout main
   git pull
   ```
2. Make your branch:
   ```powershell
   git checkout -b intro-rewrite
   ```
3. Edit, commit, and push the branch:
   ```powershell
   git add .
   git commit -m "rewrite intro"
   git push -u origin intro-rewrite
   ```
4. Open a pull request on GitHub into `main`. Someone takes a quick look, then you merge.
5. Go back to `main`, pull, and start your next branch from there. Delete the old branch after merging.

---

## Keep the repo clean (`.gitignore`)

If you use Git, add this so build files don't get committed:

```
build/
*.aux
*.log
*.out
*.toc
*.bbl
*.blg
*.synctex.gz
*.fdb_latexmk
*.fls
```

## Make compiling faster

- Only load packages you actually use. Heavy ones like `tikz`, `pgfplots`, and `tcolorbox` slow things down a lot.
- Comment out unused packages in the preamble while drafting.
- Put big figures (TikZ) in separate files and compile them on their own.
- Turn off `hyperref` while drafting and turn it on for the final build.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `latexmk` is not recognized | Open a **new** terminal or restart VS Code so it picks up the PATH |
| `latexmk` says Perl is missing or gives Perl errors | Strawberry Perl isn't installed or isn't in PATH. Redo Step 1 |
| Build looks stuck on the first run | MiKTeX may be waiting on a popup or downloading. Check for a hidden window, and set auto install to **Always** (Step 3) |
| `File 'xxx.sty' not found` | Auto install is off or you have no internet. Check Step 3, or install the package in MiKTeX Console under **Packages** |
| Citations show as `[?]` | Build twice, or check that your `.bib` file name matches `\bibliography{...}`. If `build/main.blg` says "I couldn't open database file", check that `.latexmkrc` is next to `main.tex`. If it says "I didn't find a database entry", run `kpsewhich -all yourname.bib`: if it lists a file inside MiKTeX, rename your `.bib` to something unique |
| PDF won't update or "permission denied" | Close the PDF in any other viewer (Acrobat, etc.) |
| Weird errors after an update | In MiKTeX Console, run **Tasks**, then **Refresh file name database** |
| Two Perls conflict | Make sure Strawberry Perl comes first in PATH, or uninstall the extra Perl |

## Quick checklist

- [ ] `perl -v` works
- [ ] `pdflatex --version` works
- [ ] MiKTeX auto install set to **Always**
- [ ] LaTeX Workshop installed
- [ ] Settings JSON pasted
- [ ] `Ctrl+Alt+B` builds a PDF