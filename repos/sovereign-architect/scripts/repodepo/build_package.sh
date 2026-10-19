#!/bin/bash
# Package Builder - Creates deployable package

REPO_ROOT="$HOME/Kre8tiveKonceptz_RepoDepo"
BUILD_DIR="$REPO_ROOT/build/deployable"
VERSION="1.0.0"
PACKAGE_NAME="kre8tive_konceptz_v${VERSION}"

echo "📦 Building deployable package..."

# Create package directory
PKG_DIR="$BUILD_DIR/$PACKAGE_NAME"
mkdir -p "$PKG_DIR"

# Copy all essential files
cp -r "$REPO_ROOT/artifacts" "$PKG_DIR/"
cp -r "$REPO_ROOT/scripts" "$PKG_DIR/"
cp -r "$REPO_ROOT/configs" "$PKG_DIR/"
cp -r "$REPO_ROOT/docs" "$PKG_DIR/"
cp "$REPO_ROOT/README.md" "$PKG_DIR/"
cp "$REPO_ROOT/MANIFEST.json" "$PKG_DIR/"

# Create installer script
cat > "$PKG_DIR/install.sh" << 'INSTALL_EOF'
#!/bin/bash
echo "Installing Kre8tive Konceptz RepoDepo..."
cp -r artifacts scripts configs docs "$HOME/"
echo "✅ Installation complete!"
INSTALL_EOF

chmod +x "$PKG_DIR/install.sh"

# Create tarball
cd "$BUILD_DIR"
tar -czf "${PACKAGE_NAME}.tar.gz" "$PACKAGE_NAME"

echo "✅ Package built: ${PACKAGE_NAME}.tar.gz"
echo "   Location: $BUILD_DIR"
