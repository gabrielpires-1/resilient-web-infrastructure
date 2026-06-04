const express = require("express");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");
const { Pool } = require("pg");
const path = require("path");

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || "dev-secret";
const pool = new Pool({
  host: process.env.DB_HOST || "db",
  port: Number(process.env.DB_PORT || 5432),
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "postgres",
  database: process.env.DB_NAME || "livrosdb"
});

const auth = (req, res, next) => {
  const token = (req.headers.authorization || "").replace("Bearer ", "");
  if (!token) return res.status(401).json({ error: "token ausente" });
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ error: "token invalido" });
  }
};

async function initDb() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS livros (
      id SERIAL PRIMARY KEY,
      nome TEXT NOT NULL,
      user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE
    );
  `);

  const email = process.env.SEED_USER_EMAIL || "admin@admin.com";
  const password = process.env.SEED_USER_PASSWORD || "123456";
  const hash = await bcrypt.hash(password, 10);

  await pool.query(
    `
      INSERT INTO users (email, password_hash)
      VALUES ($1, $2)
      ON CONFLICT (email) DO NOTHING
    `,
    [email, hash]
  );

  console.log(`Usuario seed: ${email} / ${password}`);
}

app.get("/", (req, res) => {
  console.log("=== Requisicao recebida no APP 1 ===");
  res.sendFile(path.join(__dirname, "index.html"));
});

app.get("/livros", async (_req, res) => {
  try {
    const { rows } = await pool.query(
      "SELECT id, nome FROM livros ORDER BY id ASC"
    );
    res.json(rows);
  } catch {
    res.status(500).json({ error: "erro ao listar livros" });
  }
});

app.post("/auth/login", async (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password) {
    return res.status(400).json({ error: "email e password sao obrigatorios" });
  }

  try {
    const { rows } = await pool.query(
      "SELECT id, email, password_hash FROM users WHERE email = $1",
      [email]
    );
    const user = rows[0];
    if (!user) return res.status(401).json({ error: "credenciais invalidas" });

    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) return res.status(401).json({ error: "credenciais invalidas" });

    const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, {
      expiresIn: "1h"
    });

    res.json({ token });
  } catch {
    res.status(500).json({ error: "erro no login" });
  }
});

app.get("/users/me/livros", auth, async (req, res) => {
  try {
    const { rows } = await pool.query(
      "SELECT id, nome FROM livros WHERE user_id = $1 ORDER BY id ASC",
      [req.user.id]
    );
    res.json(rows);
  } catch {
    res.status(500).json({ error: "erro ao listar seus livros" });
  }
});

app.post("/livros", auth, async (req, res) => {
  const { nome } = req.body || {};
  if (!nome) return res.status(400).json({ error: "nome e obrigatorio" });

  try {
    const { rows } = await pool.query(
      "INSERT INTO livros (nome, user_id) VALUES ($1, $2) RETURNING id, nome",
      [nome, req.user.id]
    );
    res.status(201).json(rows[0]);
  } catch {
    res.status(500).json({ error: "erro ao criar livro" });
  }
});

initDb()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`API rodando na porta ${PORT}`);
    });
  })
  .catch((err) => {
    console.error("Erro ao iniciar:", err);
    process.exit(1);
  });
