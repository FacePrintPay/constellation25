#!/usr/bin/env python3
import sqlite3
DB = "${LOCAL_DIR}/memoria.db"
class Memoria:
    def __init__(self):
        self.conn = sqlite3.connect(DB)
        self.conn.execute("CREATE TABLE IF NOT EXISTS logs (agent TEXT, content TEXT, ts DATETIME DEFAULT CURRENT_TIMESTAMP)")
    def log(self, agent, content):
        self.conn.execute("INSERT INTO logs (agent, content) VALUES (?,?)", (agent, content))
        self.conn.commit()
    def read(self):
        rows = self.conn.execute("SELECT agent, content FROM logs ORDER BY ts DESC LIMIT 5").fetchall()
        return "\n".join([f"{r[0]}: {r[1]}" for r in rows])
