-- Tabela de usuários
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    nome VARCHAR(255) NOT NULL,
    data_nascimento DATE,
    senha_hash VARCHAR(255) NOT NULL
);

-- Tabela principal de vacas
CREATE TABLE vacas (
    id SERIAL PRIMARY KEY,
    qr_code VARCHAR(255) UNIQUE,
    numero_brinco VARCHAR(255) UNIQUE,
    nome VARCHAR(255) NOT NULL,
    data_nascimento DATE,
    raca VARCHAR(100) NOT NULL,
    usuario_id INTEGER REFERENCES usuarios(id)
);

-- Tabela de registros de peso
CREATE TABLE pesos (
    id SERIAL PRIMARY KEY,
    vaca_id INTEGER REFERENCES vacas(id),
    data_registro DATE NOT NULL,
    peso_kg DECIMAL NOT NULL
);

-- Tabela de registros de ordenha
CREATE TABLE ordenhas (
    id SERIAL PRIMARY KEY,
    vaca_id INTEGER REFERENCES vacas(id),
    data_ordenha DATE NOT NULL,
    hora_ordenha TIME NOT NULL,
    quantidade_ml INTEGER NOT NULL,
    turno VARCHAR(10) NOT NULL
);

-- Tabela de cios
CREATE TABLE cios (
    id SERIAL PRIMARY KEY,
    vaca_id INTEGER REFERENCES vacas(id),
    data_detecao DATE NOT NULL,
    hora_detecao TIME NOT NULL
);

-- Tabela de inseminações
CREATE TABLE inseminacoes (
    id SERIAL PRIMARY KEY,
    vaca_id INTEGER REFERENCES vacas(id),
    tipo VARCHAR(20) NOT NULL,
    nome_touro VARCHAR(255),
    data_inseminacao DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'realizada'
);

-- Tabela de prenhezes
CREATE TABLE prenhezes (
    id SERIAL PRIMARY KEY,
    vaca_id INTEGER REFERENCES vacas(id),
    inseminacao_id INTEGER REFERENCES inseminacoes(id),
    data_inicio DATE NOT NULL,
    data_parto DATE,
    sexo_cria VARCHAR(10)
);

-- Tabela de lactações
CREATE TABLE lactacoes (
    id SERIAL PRIMARY KEY,
    vaca_id INTEGER REFERENCES vacas(id),
    data_inicio DATE NOT NULL,
    data_fim DATE
);
