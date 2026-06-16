CREATE DATABASE IF NOT EXISTS db_EPI;
USE db_EPI;

CREATE TABLE IF NOT EXISTS funcionario (
    idFuncionario INT AUTO_INCREMENT PRIMARY KEY,
    nome          VARCHAR(100),
    email         VARCHAR(100),
    departamento  VARCHAR(100),
    senha         VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS EPI (
    idEPI INT PRIMARY KEY,
    marca VARCHAR(100),
    tipo  VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS estoque (
    idEstoque   INT PRIMARY KEY,
    idEPI       INT,
    dataValidade DATE,
    FOREIGN KEY (idEPI) REFERENCES EPI(idEPI)
);

CREATE TABLE IF NOT EXISTS epi_funcionario (
    idFuncionario INT,
    idEstoque     INT,
    dataRetirada  DATE,
    dataDevolucao DATE,
    FOREIGN KEY (idFuncionario) REFERENCES funcionario(idFuncionario),
    FOREIGN KEY (idEstoque)     REFERENCES estoque(idEstoque)
);

INSERT IGNORE INTO EPI (idEPI, marca, tipo) VALUES
    (1, '3M',       'Capacete'),
    (2, 'Honeywell','Luvas'),
    (3, 'Vulcaflex', 'Botas'),
    (4, 'Delta Plus','Óculos');
