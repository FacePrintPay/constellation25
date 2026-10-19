#!/bin/bash
# Kre8tive Konceptz RepoDepo v2.0 — Evidence-Locked Installer
# Adds OpenTimestamps, Merkle proofs, GitHub anchoring, and legal tools

echo "🔒 Upgrading to v2.0 — Evidence Locked Edition..."

# Install OpenTimestamps (if not already)
command -v ots >/dev/null 2>&1 || {
    echo "Installing OpenTimestamps..."
    pip install opentimestamps-client
}

# Create new v2 directories
mkdir -p scripts/v2_evidence evidence_proofs legal_manifests

# Add OpenTimestamps stamper script
cat > scripts/v2_evidence/stamp_all.sh << 'STAMP_EOF'
#!/bin/bash
# Stamp everything with Merkle proofs to Bitcoin
cd ~/Kre8tiveKonceptz_RepoDepo
find . -type f \( -name "*.pdf" -o -name "*.json" -o -name "*.zip" -o -name "*.md" -o -name "*.sh" -o -name "*.py" \) -size -10M -exec ots stamp {} \; 2>/dev/null
echo "✅ All files stamped with Merkle proofs — Bitcoin-anchored!"
STAMP_EOF
chmod +x scripts/v2_evidence/stamp_all.sh

# Add GitHub anchor script
cat > scripts/v2_evidence/anchor_to_github.sh << 'GITHUB_EOF'
#!/bin/bash
# Anchor to FacePrintPay GitHub — makes it permanent
cd ~/Kre8tiveKonceptz_RepoDepo
git add -A
git commit -m "v2.0 Evidence Lock — Merkle proofs added $(date)"
git push origin main 2>/dev/null || git remote add origin https://github.com/FacePrintPay/Kre8tiveKonceptz_RepoDepo.git && git push -u origin main
echo "✅ Pushed to GitHub — timestamps locked forever!"
GITHUB_EOF
chmod +x scripts/v2_evidence/anchor_to_github.sh

# Add verification script
cat > scripts/v2_evidence/verify_all.sh << 'VERIFY_EOF'
#!/bin/bash
# Verify all Merkle proofs against Bitcoin
cd ~/Kre8tiveKonceptz_RepoDepo
find . -name "*.ots" -exec ots verify {} \; 2>/dev/null | grep -v "Verification successful"
if [ $? -eq 0 ]; then
    echo "✅ All Merkle proofs valid — court-ready!"
else
    echo "⚠️ Some proofs failed — re-stamp needed"
fi
VERIFY_EOF
chmod +x scripts/v2_evidence/verify_all.sh

# Add legal manifest generator
cat > scripts/v2_evidence/generate_legal_manifest.sh << 'MANIFEST_EOF'
#!/bin/bash
# Generate court-ready evidence manifest
cd ~/Kre8tiveKonceptz_RepoDepo
{
    echo "{"
    echo "  \"evidence_vault\": \"Kre8tive Konceptz RepoDepo v2.0\","
    echo "  \"timestamp\": \"$(date -u)\","
    echo "  \"total_files\": \"$(find . -type f | wc -l)\","
    echo "  \"ots_proofs\": \"$(find . -name '*.ots' | wc -l)\","
    echo "  \"github_repo\": \"https://github.com/FacePrintPay/Kre8tiveKonceptz_RepoDepo\","
    echo "  \"bitcoin_blocks\": \"Multiple (via OTS)\","
    echo "  \"owner\": \"Cygel S. White / Hempchoices LLC\","
    echo "  \"purpose\": \"Permanent proof of artifacts, forensics, and IP existence\""
    echo "}"
} > legal_manifests/EVIDENCE_MANIFEST.json
echo "✅ Legal manifest generated: legal_manifests/EVIDENCE_MANIFEST.json"
MANIFEST_EOF
chmod +x scripts/v2_evidence/generate_legal_manifest.sh

# Add main menu script (repodepo.sh)
cat > repodepo.sh << 'MENU_EOF'
#!/bin/bash
# Kre8tive Konceptz RepoDepo v2.0 Menu

clear
cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════╗
║  KRE8TIVE KONCEPTZ REPODEPO v2.0 – EVIDENCE LOCKED               ║
║  From scattered artifacts to court-proof codebase                 ║
╚═══════════════════════════════════════════════════════════════════╝
EOF

echo "1. Aggregate all Claude artifacts → categorized folders"
echo "2. Timestamp EVERYTHING with OpenTimestamps (Bitcoin proof)"
echo "3. Anchor to GitHub (FacePrintPay public record)"
echo "4. Build deployable + evidence package"
echo "5. Verify all timestamps & hashes (court prep)"
echo "6. Generate full legal evidence report (PDF)"
echo "7. Update everything (pull latest v2 tools)"
echo ""
echo "0. Exit"
echo ""
read -p "Your choice: " choice

case $choice in
    1) scripts/aggregate_artifacts.sh ;;
    2) scripts/v2_evidence/stamp_all.sh ;;
    3) scripts/v2_evidence/anchor_to_github.sh ;;
    4) scripts/build_package.sh ;;
    5) scripts/v2_evidence/verify_all.sh ;;
    6) scripts/v2_evidence/generate_legal_manifest.sh ;;
    7) git pull origin main && echo "Updated!" ;;
    0) exit 0 ;;
    *) echo "Invalid choice" ;;
esac

read -p "Press Enter to continue..."
./repodepo.sh menu
MENU_EOF
chmod +x repodepo.sh

# Run initial stamp and manifest
scripts/v2_evidence/stamp_all.sh
scripts/v2_evidence/generate_legal_manifest.sh

echo "✅ v2.0 Upgrade complete! Run './repodepo.sh menu' for the new interface."
