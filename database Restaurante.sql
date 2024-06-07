create database dbrestaurante;

use dbrestaurante;

CREATE TABLE `tb_cliente` (
  `id_cliente` int NOT NULL AUTO_INCREMENT,
  `cpf_cliente` varchar(14) NOT NULL,
  `nome_cliente` varchar(150) NOT NULL,
  `email_cliente` varchar(45) DEFAULT NULL,
  `telefone_cliente` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id_cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=128 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;




CREATE TABLE `tb_mesa` (
  `codigo_mesa` int NOT NULL AUTO_INCREMENT,
  `id_cliente` int NOT NULL,
  `num_pessoa_mesa` int NOT NULL DEFAULT '1',
  `data_hora_entrada` datetime DEFAULT NULL,
  `data_hora_saida` datetime DEFAULT NULL,
  PRIMARY KEY (`codigo_mesa`),
  KEY `fk_cliente_idx` (`id_cliente`),
  CONSTRAINT `fk_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `tb_cliente` (`id_cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=16384 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `tb_tipo_prato` (
  `codigo_tipo_prato` int NOT NULL AUTO_INCREMENT,
  `nome_tipo_prato` varchar(45) NOT NULL,
  PRIMARY KEY (`codigo_tipo_prato`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `tb_situacao_pedido` (
  `codigo_situacao_pedido` int NOT NULL AUTO_INCREMENT,
  `nome_situacao_pedido` varchar(45) NOT NULL,
  PRIMARY KEY (`codigo_situacao_pedido`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `tb_prato` (
  `codigo_prato` int NOT NULL AUTO_INCREMENT,
  `codigo_tipo_prato` int NOT NULL,
  `nome_prato` varchar(45) NOT NULL,
  `preco_unitario_prato` double NOT NULL,
  PRIMARY KEY (`codigo_prato`),
  KEY `fk_tipo_prato_idx` (`codigo_tipo_prato`),
  CONSTRAINT `fk_tipo_prato` FOREIGN KEY (`codigo_tipo_prato`) REFERENCES `tb_tipo_prato` (`codigo_tipo_prato`)
) ENGINE=InnoDB AUTO_INCREMENT=1024 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `tb_pedido` (
  `codigo_mesa` int NOT NULL,
  `codigo_prato` int NOT NULL,
  `quantidade_pedido` varchar(45) NOT NULL,
  `codigo_situacao_pedido` int NOT NULL,
  KEY `fk_situacao_pedido_idx` (`codigo_situacao_pedido`),
  KEY `fk_mesa_idx` (`codigo_mesa`),
  KEY `fk_prato_idx` (`codigo_prato`),
  CONSTRAINT `fk_mesa` FOREIGN KEY (`codigo_mesa`) REFERENCES `tb_mesa` (`codigo_mesa`),
  CONSTRAINT `fk_prato` FOREIGN KEY (`codigo_prato`) REFERENCES `tb_prato` (`codigo_prato`),
  CONSTRAINT `fk_situacao_pedido` FOREIGN KEY (`codigo_situacao_pedido`) REFERENCES `tb_situacao_pedido` (`codigo_situacao_pedido`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE tb_empresa (
    codigo_empresa INT NOT NULL AUTO_INCREMENT,
    nome_empresa VARCHAR(500),
    uf_sede_empresa VARCHAR(2),
    PRIMARY KEY (codigo_empresa)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE tb_beneficio (
    codigo_funcionario INT,
    email_funcionario VARCHAR(200),
    codigo_beneficio INT,
    codigo_empresa INT,
    tipo_beneficio VARCHAR(45),
    valor_beneficio VARCHAR(45),
    FOREIGN KEY (codigo_empresa) REFERENCES tb_empresa(codigo_empresa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- cliente que mais pede em cada ano

SELECT ano, c.nome_cliente, ranked.id_cliente, total_pedidos
FROM (
    SELECT
        YEAR(m.data_hora_entrada) AS ano,
        m.id_cliente,
        COUNT(*) AS total_pedidos,
        ROW_NUMBER() OVER (PARTITION BY YEAR(m.data_hora_entrada) ORDER BY COUNT(*) DESC) AS ranking
    FROM
        tb_mesa m
    GROUP BY
        YEAR(m.data_hora_entrada), m.id_cliente
) AS ranked
JOIN tb_cliente c ON c.id_cliente = ranked.id_cliente
WHERE ranking = 1;

-- cliente que mais gastou em todos os anos

SELECT 
    c.id_cliente,
    c.nome_cliente,
    SUM(pr.preco_unitario_prato * p.quantidade_pedido) AS total_gasto
FROM 
    tb_pedido p
JOIN 
    tb_prato pr ON p.codigo_prato = pr.codigo_prato
JOIN 
    tb_mesa m ON p.codigo_mesa = m.codigo_mesa
JOIN 
    tb_cliente c ON m.id_cliente = c.id_cliente
GROUP BY 
    c.id_cliente, c.nome_cliente
ORDER BY 
    total_gasto DESC
LIMIT 1;

-- cliente que trouxe mais pessoas

SELECT 
    YEAR(m.data_hora_entrada) AS ano,
    c.nome_cliente,
    m.id_cliente,
    SUM(m.num_pessoa_mesa) AS total_pessoas
FROM 
    tb_mesa m
JOIN 
    tb_cliente c ON m.id_cliente = c.id_cliente
GROUP BY 
    YEAR(m.data_hora_entrada),
    m.id_cliente,
    c.nome_cliente
ORDER BY 
    YEAR(m.data_hora_entrada) DESC,
    total_pessoas DESC
LIMIT 1;

-- empresa que tem mais funcionarios clientes

SELECT
    e.nome_empresa,
    COUNT(c.email_cliente) AS total_funcionarios
FROM
    tb_cliente c
JOIN
    tb_beneficio b ON c.email_cliente = b.email_funcionario
JOIN
    tb_empresa e ON b.codigo_empresa = e.codigo_empresa
GROUP BY
    e.nome_empresa
ORDER BY
    total_funcionarios DESC
LIMIT 1;

-- empresas que mais funcionarios pedem sobremesa em cada ano

SELECT
    ano,
    nome_empresa,
    total_funcionarios_sobremesa
FROM
    (
        SELECT
            YEAR(m.data_hora_entrada) AS ano,
            e.nome_empresa,
            COUNT(DISTINCT c.email_cliente) AS total_funcionarios_sobremesa,
            ROW_NUMBER() OVER (PARTITION BY YEAR(m.data_hora_entrada) ORDER BY COUNT(DISTINCT c.email_cliente) DESC) AS ranking
        FROM
            tb_mesa m
        JOIN
            tb_cliente c ON m.id_cliente = c.id_cliente
        JOIN
            tb_pedido p ON m.codigo_mesa = p.codigo_mesa
        JOIN
            tb_prato pr ON p.codigo_prato = pr.codigo_prato
        JOIN
            tb_tipo_prato tp ON pr.codigo_tipo_prato = tp.codigo_tipo_prato
        JOIN
            tb_beneficio b ON c.email_cliente = b.email_funcionario
        JOIN
            tb_empresa e ON b.codigo_empresa = e.codigo_empresa
        WHERE
            tp.nome_tipo_prato = 'Sobremesa'
        GROUP BY
            YEAR(m.data_hora_entrada), e.nome_empresa
    ) AS ranking
WHERE
    ranking = 1;


