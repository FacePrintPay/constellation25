#!/data/data/com.termux/files/usr/bin/bash
DB="${HOME}/.gamma7/memory.db"
mkdir -p "$(dirname "${DB}")"
[ -f "${DB}" ] || sqlite3 "${DB}" "CREATE TABLE IF NOT EXISTS memories(id INTEGER PRIMARY KEY,content TEXT,timestamp DATETIME DEFAULT CURRENT_TIMESTAMP);"
case "${1:-}" in
store) sqlite3 "${DB}" "INSERT INTO memories(content)VALUES('${2}')"; echo "✅ Stored: ${2}" ;;
recall) sqlite3 "${DB}" "SELECT timestamp,content FROM memories WHERE content LIKE '%${2}%' ORDER BY timestamp DESC LIMIT 3" ;;
*) echo "Gamma #7 — Offline sovereign memory"; echo "Usage: \$0 store 'text' | recall 'keyword'";;
esac
