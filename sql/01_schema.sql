-- ========== DADOS DE REFERÊNCIA ==========
 
CREATE TABLE torres (
    id INTEGER PRIMARY KEY,
    nome TEXT NOT NULL UNIQUE,
    categoria TEXT NOT NULL,          -- Primária, Militar, Mágica, Suporte
    custo_base INTEGER NOT NULL
);