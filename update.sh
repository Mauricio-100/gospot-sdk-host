#!/usr/bin/env bash
# ==============================================================
#  GoSpot SDK Update Script  —  by Mauricio & Dragon
# ==============================================================
#  Ce script reconstruit le SDK, met à jour le tarball, commit,
#  push et donne le lien GitHub public final automatiquement.
# ==============================================================

set -e

SDK_DIR="gospot-sdk"
PUBLIC_DIR="public"
TARBALL="$PUBLIC_DIR/gospot-sdk-1.0.0.tar.gz"
BRANCH="main"
REPO_URL="https://github.com/Mauricio-100/gospot-sdk-host"
AUTHOR="Mauricio"
DATE=$(date -u +"%Y-%m-%d %H:%M:%SZ")

# --- Vérifications préliminaires --------------------------------
echo "=== [GoSpot SDK Auto-Updater] ==="
if [ ! -d "$SDK_DIR" ]; then
  echo "[❌] Dossier '$SDK_DIR' introuvable !"
  exit 1
fi

mkdir -p "$PUBLIC_DIR"

# --- Nettoyage ancien SDK ---------------------------------------
echo "[🧹] Nettoyage de l'ancien SDK..."
rm -f "$TARBALL"

# --- Reconstruction du tar.gz -----------------------------------
echo "[📦] Création du nouveau SDK..."
tar -czf "$TARBALL" "$SDK_DIR"

# --- Vérification du contenu ------------------------------------
echo "[🔍] Vérification du contenu :"
tar -tf "$TARBALL" | sed -n '1,10p'
echo "..."

# --- Git commit + push ------------------------------------------
echo "[💾] Commit et push des modifications..."

git add "$TARBALL"
git add "$SDK_DIR"
git commit -m "chore: update SDK package ($DATE)" || echo "[ℹ️] Aucun changement à commit."
git push origin "$BRANCH"

# --- Génération du lien GitHub direct ----------------------------
RAW_LINK="$REPO_URL/raw/$BRANCH/$TARBALL"

# --- Résumé final -----------------------------------------------
echo ""
echo "✅ [SUCCÈS] SDK reconstruit et poussé sur GitHub."
echo "📂 Archive disponible : $TARBALL"
echo "🌐 Lien public à utiliser dans ton CLI :"
echo "    $RAW_LINK"
echo ""
echo "=== Fin de mise à jour à $DATE ==="
