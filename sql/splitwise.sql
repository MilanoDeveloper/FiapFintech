-- ======================
-- Tabelas
-- ======================

-- Usuários
CREATE TABLE Usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Grupos
CREATE TABLE Grupo (
    id_grupo INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_criador INT,
    FOREIGN KEY (id_criador) REFERENCES Usuario(id_usuario)
);

-- Associação entre usuários e grupos
CREATE TABLE Usuario_Grupo (
    id_usuario_grupo INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_grupo INT NOT NULL,
    data_entrada DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    FOREIGN KEY (id_grupo) REFERENCES Grupo(id_grupo),
    UNIQUE KEY (id_usuario, id_grupo)
);

-- Despesas
CREATE TABLE Despesa (
    id_despesa INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    data_despesa DATE NOT NULL,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_pagador INT NOT NULL,
    id_grupo INT NOT NULL,
    FOREIGN KEY (id_pagador) REFERENCES Usuario(id_usuario),
    FOREIGN KEY (id_grupo) REFERENCES Grupo(id_grupo)
);

-- Participantes da despesa
CREATE TABLE Despesa_Participante (
    id_despesa_participante INT AUTO_INCREMENT PRIMARY KEY,
    id_despesa INT NOT NULL,
    id_usuario INT NOT NULL,
    valor_devedor DECIMAL(10, 2) NOT NULL,
    porcentagem DECIMAL(5, 2),
    FOREIGN KEY (id_despesa) REFERENCES Despesa(id_despesa),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario),
    UNIQUE KEY (id_despesa, id_usuario)
);

-- Registro de pagamentos
CREATE TABLE Pagamento (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_despesa INT,
    id_pagador INT NOT NULL,
    id_recebedor INT NOT NULL,
    valor_pago DECIMAL(10, 2) NOT NULL,
    data_pagamento DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_despesa) REFERENCES Despesa(id_despesa),
    FOREIGN KEY (id_pagador) REFERENCES Usuario(id_usuario),
    FOREIGN KEY (id_recebedor) REFERENCES Usuario(id_usuario)
);

-- ======================
-- Índices
-- ======================

CREATE INDEX idx_usuario_grupo ON Usuario_Grupo(id_usuario, id_grupo);
CREATE INDEX idx_despesa_participante ON Despesa_Participante(id_despesa, id_usuario);
CREATE INDEX idx_despesa_grupo ON Despesa(id_grupo);
CREATE INDEX idx_despesa_pagador ON Despesa(id_pagador);
CREATE INDEX idx_pagamento_usuarios ON Pagamento(id_pagador, id_recebedor);

-- ======================
-- Dados de exemplo
-- ======================

-- Usuários
INSERT INTO Usuario (nome, email, senha) VALUES 
('Kayo Araujo', 'kayo@email.com', 'hash123'),
('Gustavo Borgo', 'gustavo@email.com', 'hash456'),
('Antonio Brito', 'carlos@email.com', 'hash789'),
('Jose Victor', 'jose@email.com', 'hash825'),
('Gabriel Milano', 'gabriel@email.com', 'hash649');

-- Grupo
INSERT INTO Grupo (nome, descricao, id_criador) VALUES 
('Amigos', 'Despesas do time da faculdade', 1);

-- Usuários no grupo
INSERT INTO Usuario_Grupo (id_usuario, id_grupo) VALUES 
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1);

-- Despesa
INSERT INTO Despesa (descricao, valor_total, data_despesa, id_pagador, id_grupo) VALUES 
('Jantar em restaurante', 200.00, '2023-11-15', 1, 1);

-- Participantes da despesa
INSERT INTO Despesa_Participante (id_despesa, id_usuario, valor_devedor, porcentagem) VALUES 
(1, 1, 40.00, 20.00),
(1, 2, 40.00, 20.00),
(1, 3, 40.00, 20.00),
(1, 4, 40.00, 20.00),
(1, 5, 40.00, 20.00);

-- Pagamento registrado
INSERT INTO Pagamento (id_despesa, id_pagador, id_recebedor, valor_pago) VALUES 
(1, 3, 1, 20.00);

-- ======================
-- Consultas úteis
-- ======================

-- 1) Saldo total de cada usuário
SELECT 
    u.id_usuario, u.nome,
    IFNULL(SUM(p.valor_pago), 0) AS total_pago,
    IFNULL(SUM(dp.valor_devedor), 0) AS total_devido,
    IFNULL(SUM(p.valor_pago), 0) - IFNULL(SUM(dp.valor_devedor), 0) AS saldo
FROM Usuario u
LEFT JOIN Pagamento p ON u.id_usuario = p.id_pagador
LEFT JOIN Despesa_Participante dp ON u.id_usuario = dp.id_usuario
GROUP BY u.id_usuario, u.nome;

-- 2) Dívidas detalhadas
SELECT 
    d.id_despesa, 
    pag.nome AS pagador,
    rec.nome AS recebedor,
    p.valor_pago,
    dp.valor_devedor
FROM Despesa d
JOIN Pagamento p ON d.id_despesa = p.id_despesa
JOIN Usuario pag ON p.id_pagador = pag.id_usuario
JOIN Usuario rec ON p.id_recebedor = rec.id_usuario
JOIN Despesa_Participante dp ON dp.id_despesa = d.id_despesa AND dp.id_usuario = rec.id_usuario;

-- 3) Listar despesas de um grupo
SELECT 
    d.id_despesa, d.descricao, d.valor_total, d.data_despesa, u.nome AS pagador_nome
FROM Despesa d
JOIN Usuario u ON d.id_pagador = u.id_usuario
WHERE d.id_grupo = 1
ORDER BY d.data_despesa DESC;

-- 4) Participantes e valores de uma despesa
SELECT 
    u.nome,
    dp.valor_devedor,
    dp.porcentagem
FROM Despesa_Participante dp
JOIN Usuario u ON dp.id_usuario = u.id_usuario
WHERE dp.id_despesa = 1;

-- 5) Pagamentos realizados
SELECT 
    p.id_pagamento,
    d.descricao,
    pag.nome AS pagador,
    rec.nome AS recebedor,
    p.valor_pago,
    p.data_pagamento
FROM Pagamento p
LEFT JOIN Despesa d ON p.id_despesa = d.id_despesa
JOIN Usuario pag ON p.id_pagador = pag.id_usuario
JOIN Usuario rec ON p.id_recebedor = rec.id_usuario
ORDER BY p.data_pagamento DESC;